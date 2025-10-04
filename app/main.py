from fastapi import FastAPI
from logger import logger
from app.api.v1.routers import api_router
from contextlib2 import asynccontextmanager
from app.core.database import create_db_and_tables, async_engine , engine
from app.services.socket_io_service import socket_app
import uvicorn

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("\U0001f680 Starting application...")

    await create_db_and_tables()


    logger.info("\u2705 Database connected")

    yield 

    logger.info("\U0001f6d1 Shutting down application...")
    await async_engine.dispose()   
    engine.dispose()
    logger.info("\u2705 Database connections closed")


app = FastAPI(title="MyWellness", lifespan=lifespan)
app.mount("/socket.io", socket_app)
app.include_router(api_router, prefix="/api/v1")


@app.get("/")
def read_root():
    return {"message": "Welcome to the API"}


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",   
        host="0.0.0.0",
        port=9000,
        reload=True,    
        workers=1
    )
    