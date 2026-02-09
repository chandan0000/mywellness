import asyncio
from collections.abc import AsyncGenerator, Generator

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

from app.core.config import settings
from app.core.database import get_async_db
from app.core.db_base import Base
from app.main import app

# Use a separate test database
# Ensure this matches your local setup
# We replace the database name in the async URL
if settings.DATABASE_ASYNC_URL is None:
    raise ValueError("DATABASE_ASYNC_URL is not set")
TEST_DATABASE_URL = settings.DATABASE_ASYNC_URL.replace(
    "/mywellness", "/mywellness_test"
)

engine = create_async_engine(TEST_DATABASE_URL, poolclass=NullPool)
TestingSessionLocal = async_sessionmaker(
    autocommit=False, autoflush=False, bind=engine, class_=AsyncSession
)


@pytest.fixture(scope="session")
def event_loop(request) -> Generator:
    """Create an instance of the default event loop for each test case."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture(scope="session", autouse=True)
async def prepare_database():
    # Patch the async_engine in the application to use our test engine
    # This ensures that the lifespan event (which calls create_db_and_tables)
    # uses the test database, not the main one.
    from app import main
    from app.core import database

    # Save original engines to restore later if needed (optional for session scope)
    original_db_engine = database.async_engine
    original_main_engine = main.async_engine

    database.async_engine = engine
    main.async_engine = engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)

    yield

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    # Restore (good practice)
    database.async_engine = original_db_engine
    main.async_engine = original_main_engine


@pytest_asyncio.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    async with TestingSessionLocal() as session:
        yield session


@pytest_asyncio.fixture
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    async def override_get_async_db():
        yield db_session

    app.dependency_overrides[get_async_db] = override_get_async_db
    # Using ASGITransport is the modern way to test FastAPI apps with httpx
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        yield c
    app.dependency_overrides.clear()
