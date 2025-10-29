from fastapi import FastAPI, Response, HTTPException, Request
import httpx, os, time, hmac, hashlib, base64

OWNER = os.getenv("Axiliyz")         # yourname
REPO  = os.getenv("SenseFlowApp")          # senseflow
GHTOK = os.getenv("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")  # PAT read-only
SECRET= os.getenv("LINK_SECRET", "781h23y8ug1i231y2oeh12ileg128oe12")  # секрет для подписи ссылок

app = FastAPI(title="SenseFlow Private Latest")

def make_sig(q: str) -> str:
    d = hmac.new(SECRET.encode(), q.encode(), hashlib.sha256).digest()
    return base64.urlsafe_b64encode(d).decode().rstrip("=")

def verify(q: str, sig: str, ttl=900) -> bool:
    # q, например: "ts=1700000000"
    parts = dict(p.split("=",1) for p in q.split("&") if "=" in p)
    try:
        ts = int(parts.get("ts","0"))
    except ValueError:
        return False
    if abs(time.time()-ts) > ttl:  # 15 минут
        return False
    return hmac.compare_digest(make_sig(q), sig)

@app.get("/download/latest")
async def latest(req: Request, q: str, sig: str):
    if not verify(q, sig): raise HTTPException(403, "forbidden")
    headers = {
        "Authorization": f"Bearer {GHTOK}",
        "User-Agent": "senseflow-latest"
    }
    async with httpx.AsyncClient(timeout=30) as cli:
        # 1) узнаём последний релиз
        r = await cli.get(f"https://api.github.com/repos/{OWNER}/{REPO}/releases/latest", headers=headers)
        if r.status_code != 200: raise HTTPException(502, "github error")
        assets = r.json().get("assets", [])
        asset = next((a for a in assets if a["name"]=="app.zip"), None)
        if not asset: raise HTTPException(404, "asset not found")

        # 2) скачиваем ассет (ВАЖНО: Accept: octet-stream)
        url = f"https://api.github.com/repos/{OWNER}/{REPO}/releases/assets/{asset['id']}"
        s = await cli.get(url, headers={**headers, "Accept":"application/octet-stream"})
        if s.status_code != 200: raise HTTPException(502, "download error")

        return Response(
            content=s.content,
            media_type="application/zip",
            headers={
                "Cache-Control": "no-store",
                "Content-Disposition": 'attachment; filename="app.zip"'
            }
        )

# Вспомогательный эндпойнт для генерации ссылки (ограничь доступ, если оставишь)
@app.get("/make-link")
def make_link():
    ts = str(int(time.time()))
    q = f"ts={ts}"
    sig = make_sig(q)
    return {"url": f"/download/latest?q={q}&sig={sig}"}
