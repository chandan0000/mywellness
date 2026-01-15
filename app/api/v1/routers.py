from fastapi import APIRouter
from app.api.v1.endpoints.users import user_router
from app.api.v1.endpoints.auth import auth_router
from app.api.v1.endpoints.conversations import conversation_router
from app.api.v1.endpoints.calls import call_router

api_router = APIRouter()
api_router.include_router(user_router, prefix="/users", tags=["users"])
api_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_router.include_router(conversation_router, prefix="/conversations", tags=["conversations"])
api_router.include_router(call_router, prefix="/calls", tags=["calls"])


