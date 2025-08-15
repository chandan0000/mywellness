from fastapi import APIRouter
from app.api.v1.endpoints.users import user_router
from app.api.v1.endpoints.auth import auth_router
api_router = APIRouter()
api_router.include_router(user_router, prefix="/users", tags=["users"])
api_router.include_router(auth_router, prefix="/auth", tags=["auth"])

