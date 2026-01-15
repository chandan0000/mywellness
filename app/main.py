from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.logger import logger
from app.api.v1.routers import api_router
from contextlib2 import asynccontextmanager
from app.core.database import create_db_and_tables, async_engine , engine
from app.services.socket_io_service import socket_app
import uvicorn


import base64
import json
import os
from pydantic import BaseModel
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.ciphers.aead import AESGCM


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

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

app.mount("/socket.io", socket_app)
app.include_router(api_router, prefix="/api/v1")
 
if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",   
        host="0.0.0.0",
        port=9000,
        reload=True,    
        workers=1
    )
    