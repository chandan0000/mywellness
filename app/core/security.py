import uuid
from datetime import UTC, datetime, timedelta

from fastapi import Depends, HTTPException, status
from fastapi.security import APIKeyHeader
from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings
from app.logger import logging

# Secret key & algorithm (use values from settings)
SECRET_KEY = settings.SECRET_KEY
ALGORITHM = settings.ALGORITHM
ACCESS_TOKEN_EXPIRE_MINUTES = settings.ACCESS_TOKEN_EXPIRE_MINUTES

# Password hashing
pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")

# Token extractor
api_key_header = APIKeyHeader(name="Authorization")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(UTC) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})

    # Ensure 'sub' is a string
    if "sub" in to_encode:
        to_encode["sub"] = str(to_encode["sub"])

    logging.info(f"Creating access token with data: {to_encode}")
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def verify_token(token: str = Depends(api_key_header)) -> uuid.UUID:
    logging.info(f"Verifying token: {token}")

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired token",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        logging.info(f"Decoded JWT payload: {payload}")

        user_id = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        return uuid.UUID(user_id)
    except JWTError as e:
        logging.error(f"JWT verification failed: {e}")
        raise credentials_exception
