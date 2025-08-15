from re import S
import token
from app.logger import logging
from fastapi import APIRouter, Depends, HTTPException, status

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError
from app.core.security import hash_password, verify_password , create_access_token
from app.core.database import  get_async_db
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin
from app.utils.helpers import ErrorResponse, SuccessResponse
from app.crud.auth_crud import AuthCRUD

auth_router = APIRouter()


@auth_router.post("/login", status_code=status.HTTP_200_OK  ,)
async def login(user: UserLogin, db: AsyncSession=Depends(get_async_db),):

    auth_crud = AuthCRUD(db)

    db_user = await auth_crud.get_user_by_email(user.email)

    if not db_user or not verify_password(user.password, db_user.password):
        raise ErrorResponse(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials", message="Authentication failed")
    token = create_access_token(data={"sub": db_user.id})
    if not token:
        raise ErrorResponse(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Token creation failed", message="Internal Server Error")
    
    return SuccessResponse(
        detail={"access_token": token, "token_type": "bearer", "user_id": db_user.id, "email": db_user.email},
        status_code=status.HTTP_200_OK,
        message="Login successful"
    )


@auth_router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user: UserCreate, db: AsyncSession=Depends(get_async_db)):
    try:
        hash_pwd = hash_password(user.password)
        user.password = hash_pwd

        auth_crud = AuthCRUD(db)
        new_user = await auth_crud.create_user(user)
        return SuccessResponse(
            detail={"user_id": new_user.id, "email": new_user.email},
            status_code=status.HTTP_201_CREATED,
            message="User registered successfully"
        )
    
    except IntegrityError as e:
        await db.rollback()
        err_msg = str(e.orig).lower()
    
        if "ix_users_email" in err_msg:
            raise ErrorResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this email already exists",
                message="Registration failed"
            )
        elif "ix_users_phone_number" in err_msg:
            raise ErrorResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this phone number already exists",
                message="Registration failed"
            )
        elif "duplicate key value violates unique constraint" in err_msg:
            raise ErrorResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Some thing went wrong",
                message="Registration failed"
            )
        raise ErrorResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Some thing went wrong",
            message="Internal Server Error"
        )

    except Exception as e:
        await db.rollback()
        logging.error(f"Error registering user: {e}")
        raise ErrorResponse(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Some thing went wrong", message="Internal Server Error")
