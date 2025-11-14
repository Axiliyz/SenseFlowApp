from fastapi import FastAPI, Response, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse, PlainTextResponse
import httpx, os, time, hmac, hashlib, base64

# ===== ENV =====
OWNER = os.getenv("OWNER") 
REPO  = os.getenv("REPO")   
GHTOK = os.getenv("GHTOK")        
SECRET= os.getenv("SECRET")      

app = FastAPI(title="SenseFlow Private Latest")

# ===== helpers =====
def _make_sig(q: str) -> str:
    d = hmac.new(SECRET.encode(), q.encode(), hashlib.sha256).digest()
    return base64.urlsafe_b64encode(d).decode().rstrip("=")

def _verify(q: str, sig: str, ttl=900) -> bool:
    """Проверка подписи и срока ссылки (15 минут)"""
    try:
        parts = dict(p.split("=", 1) for p in q.split("&") if "=" in p)
        ts = int(parts.get("ts", "0"))
    except Exception:
        return False
    if abs(time.time() - ts) > ttl:
        return False
    return hmac.compare_digest(_make_sig(q), sig)

async def _get_with_redirect(cli: httpx.AsyncClient, url: str, headers: dict, max_hops: int = 5) -> httpx.Response:
    """
    GET для приватных zipball ссылок GitHub
    """
    for _ in range(max_hops):
        r = await cli.get(url, headers=headers, follow_redirects=False)
        if r.status_code in (301, 302, 303, 307, 308):
            loc = r.headers.get("Location")
            if not loc:
                return r
            url = loc
            continue
        return r
    raise HTTPException(502, "Too many redirects")

async def _get_latest_zip_info(cli: httpx.AsyncClient, headers: dict) -> tuple[str, str]:
    """
    Возвращает (zip_url, name):
      1) releases/latest - zipball_url + tag_name
      2) если 404 - /tags (последний тег) - zipball по тегу
      3) если и тегов нет - zipball по default_branch
    """
    # 1) опубликованный релиз
    r = await cli.get(f"https://api.github.com/repos/{OWNER}/{REPO}/releases/latest", headers=headers)
    if r.status_code == 200:
        data = r.json()
        zip_url = data.get("zipball_url")
        name = data.get("tag_name", "latest")
        if not zip_url:
            raise HTTPException(404, "zipball_url missing in release")
        return zip_url, name

    if r.status_code not in (404, 410):
        raise HTTPException(
            502,
            detail=f"GitHub releases/latest status={r.status_code} body={r.text[:4000]}"
        )

    # 2) последний тег
    t = await cli.get(f"https://api.github.com/repos/{OWNER}/{REPO}/tags?per_page=1", headers=headers)
    if t.status_code == 200 and t.json():
        tag = t.json()[0]["name"]
        return (f"https://api.github.com/repos/{OWNER}/{REPO}/zipball/{tag}", tag)

    # 3) дефолтная ветка
    repo = await cli.get(f"https://api.github.com/repos/{OWNER}/{REPO}", headers=headers)
    if repo.status_code != 200:
        raise HTTPException(502, detail=f"GitHub repo status={repo.status_code} body={repo.text[:4000]}")
    default_branch = repo.json().get("default_branch", "main")
    return (f"https://api.github.com/repos/{OWNER}/{REPO}/zipball/{default_branch}", default_branch)

# ===== endpoints =====
@app.get("/healthz")
def healthz():
    ok_env = all([OWNER, REPO, GHTOK, SECRET])
    return {"status": "ok", "env_ok": ok_env}

@app.get("/", response_class=RedirectResponse)
def root_redirect():
    """Автоматически генерим временную ссылку и редиректим на скачивание."""
    if not all([OWNER, REPO, GHTOK, SECRET]):
        html = """
        <h2>Env not set</h2>
        <p>Нужно задать переменные окружения OWNER, REPO, GHTOK, SECRET.</p>
        """
        return HTMLResponse(html, status_code=500)
    ts = str(int(time.time()))
    q = f"ts={ts}"
    sig = _make_sig(q)
    return RedirectResponse(url=f"/download/latest?q={q}&sig={sig}", status_code=302)

@app.get("/make-link")
def make_link():
    if not all([OWNER, REPO, GHTOK, SECRET]):
        raise HTTPException(500, "env not set")
    ts = str(int(time.time()))
    q = f"ts={ts}"
    sig = _make_sig(q)
    return {"url": f"/download/latest?q={q}&sig={sig}"}

@app.get("/download/latest")
async def download_latest(q: str, sig: str):
    if not all([OWNER, REPO, GHTOK, SECRET]):
        raise HTTPException(500, "env not set")
    if not _verify(q, sig):
        raise HTTPException(403, "forbidden")

    headers = {"Authorization": f"Bearer {GHTOK}", "User-Agent": "senseflow-latest"}

    try:
        async with httpx.AsyncClient(timeout=90) as cli:
            zip_url, name = await _get_latest_zip_info(cli, headers)
            z = await _get_with_redirect(cli, zip_url, headers)
            if z.status_code != 200:
                return PlainTextResponse(
                    f"Zip download status={z.status_code}\n{z.text}",
                    status_code=502,
                    headers={"Cache-Control": "no-store"},
                )
            fname = f"{REPO}-{name}.zip"
            return Response(
                content=z.content,
                media_type="application/zip",
                headers={
                    "Cache-Control": "no-store",
                    "Content-Disposition": f'attachment; filename="{fname}"'
                }
            )
    except HTTPException:
        raise
    except Exception as e:
        return PlainTextResponse(
            f"Internal error: {type(e).__name__}: {e}",
            status_code=500,
            headers={"Cache-Control": "no-store"},
        )