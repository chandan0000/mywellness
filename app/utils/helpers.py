from typing import Any

from fastapi import HTTPException


class ErrorResponse(HTTPException):
    def __init__(self, status_code: int, detail: str, message: str):
        super().__init__(
            status_code=status_code,
            detail={"detail": detail, "status_code": status_code, "message": message},
        )


class SuccessResponse:
    def __init__(self, detail: Any, status_code: int, message: str):
        self.detail = detail
        self.status_code = status_code
        self.message = message

    class Config:
        schema_extra = {
            "example": {
                "detail": "Success detail message",
                "status_code": 200,
                "message": "Success message",
            }
        }
