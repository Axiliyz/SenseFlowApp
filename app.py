from fastapi import FastAPI, Response, HTTPException
from fastapi.responses import HTMLResponse
import httpx, os, time, hmac, hashlib, base64

# === читаем переменные окружения ПО ИМЕНАМ ===
OWNER = os.getenv("OWNER")          # напр. "Axiliyz"
REPO  = os.getenv("REPO")           # напр. "SenseFlowApp"
GHTOK = os.getenv("GHTOK")          # твой PAT (read на репозиторий)
SECRET= os.getenv("SECRET", "change-me")  # общий секрет для подписи ссылок

app = FastAPI(title="SenseFlow Private Latest")

def make_sig(q: str) -> str:
    d = hmac.new(SECRET.encode(), q.encode(), hashlib.sha256).digest()
    return base64.urlsafe_b64encode(d).decode().rstrip("=")

def verify(q: str, sig: str, ttl=900) -> bool:
    try:
        parts = dict(p.split("=",1) for p in q.split("&") if "=" in p)
        ts = int(parts.get("ts","0"))
    except Exception:
        return False
    if abs(time.time()-ts) > ttl:
        return False
    return hmac.compare_digest(make_sig(q), sig)

@app.get("/healthz")
def healthz(): return {"status":"ok"}

@app.get("/", response_class=HTMLResponse)
def index():
    return '<a href="/make-link">Сгенерировать ссылку на последний архив</a>'

@app.get("/make-link")
def make_link():
    ts = str(int(time.time()))
    q = f"ts={ts}"
    sig = make_sig(q)
    return {"url": f"/download/latest?q={q}&sig={sig}"}

@app.get("/download/latest")
async def latest(q: str, sig: str):
    if not verify(q, sig):
        raise HTTPException(403, "forbidden")
    if not all([OWNER, REPO, GHTOK]):
        raise HTTPException(500, "env not set")

    headers = {"Authorization": f"Bearer {GHTOK}", "User-Agent": "senseflow-latest"}
    async with httpx.AsyncClient(timeout=60) as cli:
        # берём автоархив исходников последнего релиза (zipball)
        r = await cli.get(f"https://api.github.com/repos/{OWNER}/{REPO}/releases/latest", headers=headers)
        if r.status_code != 200:
            return Response(f"GitHub status={r.status_code}\n{r.text}", media_type="text/plain", status_code=502)
        data = r.json()
        zip_url = data.get("zipball_url")
        if not zip_url:
            raise HTTPException(404, "zipball_url not found in release")

        z = await cli.get(zip_url, headers=headers)
        if z.status_code != 200:
            return Response(f"Zip download status={z.status_code}\n{z.text}", media_type="text/plain", status_code=502)

        fname = f'{REPO}-{data.get("tag_name","latest")}.zip'
        return Response(z.content, media_type="application/zip",
                        headers={"Cache-Control":"no-store",
                                 "Content-Disposition": f'attachment; filename="{fname}"'})
