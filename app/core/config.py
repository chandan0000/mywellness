# core/config.py

from pydantic_settings import BaseSettings # type: ignore


class Settings(BaseSettings):
    
    # This value MUST be provided in the .env file
    DATABASE_ASYNC_URL: str
    DATABASE_SYNC_URL: str

    class Config:

        env_file = ".env"


# Create a single, reusable instance of the settings
settings = Settings() # type: ignore

