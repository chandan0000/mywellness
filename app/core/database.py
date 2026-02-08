from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.core.db_base import Base
from app.logger import logger

# Synchronous Database Configuration
engine = create_engine(settings.DATABASE_SYNC_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Asynchronous Database Configuration
async_engine: AsyncEngine = create_async_engine(settings.DATABASE_ASYNC_URL, echo=True)

AsyncSessionLocal = sessionmaker(
    async_engine, class_=AsyncSession, expire_on_commit=False
)


async def get_async_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()


async def create_db_and_tables():
    async with async_engine.begin() as conn:
        logger.info("Creating database tables...")  # type: ignore
        await conn.run_sync(Base.metadata.create_all)
