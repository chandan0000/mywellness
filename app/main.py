from fastapi import FastAPI
from logger import logger
from app.api.v1.routers import api_router
from contextlib2 import asynccontextmanager
from app.core.database import create_db_and_tables
from app.services.socket_io_service import socket_app


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting application...")
    await create_db_and_tables()
    yield
    logger.info("Shutting down application...",)


app = FastAPI(title="MyWellness", lifespan=lifespan)
app.mount("/socket.io", socket_app)
app.include_router(api_router, prefix="/api/v1")


@app.get("/")
def read_root():
    return {"message": "Welcome to the API"}


