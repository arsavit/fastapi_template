import uvicorn
from fastapi import FastAPI

app = FastAPI(title="Title")


@app.on_event("startup")
async def startup_event() -> None:
    print("start----------")


@app.on_event("shutdown")
async def shutdown_event() -> None:
    print("shutdown")


if __name__ == "__main__":
    uvicorn.run("main:app")
