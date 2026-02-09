import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_register_user(client: AsyncClient):
    payload = {
        "email": "test@example.com",
        "password": "password123",
        "full_name": "Test User",
        "phone_number": "+919876543210",
    }
    response = await client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["status_code"] == 201
    assert data["message"] == "User registered successfully"
    assert "user_id" in data["detail"]
    assert data["detail"]["email"] == payload["email"]


@pytest.mark.asyncio
async def test_register_existing_email(client: AsyncClient):
    payload = {
        "email": "duplicate@example.com",
        "password": "password123",
        "full_name": "Test User",
        "phone_number": "+919876543211",
    }
    # Register first user
    response = await client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201

    # Try to register same email again
    # Change phone number to avoid phone constraint first to isolate email error
    payload["phone_number"] = "+919876543212"
    response = await client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 400
    data = response.json()
    # ErrorResponse structure puts details in a nested dictionary under 'detail'
    assert data["detail"]["detail"] == "User with this email already exists"


@pytest.mark.asyncio
async def test_login_user(client: AsyncClient):
    # Register a user first
    payload = {
        "email": "login@example.com",
        "password": "password123",
        "full_name": "Login User",
        "phone_number": "+919876543213",
    }
    register_response = await client.post("/api/v1/auth/register", json=payload)
    assert register_response.status_code == 201

    # Login
    login_payload = {"email": "login@example.com", "password": "password123"}
    response = await client.post("/api/v1/auth/login", json=login_payload)
    assert response.status_code == 200
    data = response.json()
    # SuccessResponse returns flat structure (attributes of the object)
    assert data["status_code"] == 200
    assert "access_token" in data["detail"]
    assert data["detail"]["token_type"] == "bearer"


@pytest.mark.asyncio
async def test_login_invalid_credentials(client: AsyncClient):
    login_payload = {"email": "nonexistent@example.com", "password": "wrongpassword"}
    response = await client.post("/api/v1/auth/login", json=login_payload)
    assert response.status_code == 401
    data = response.json()
    # ErrorResponse structure puts details in a nested dictionary under 'detail'
    assert data["detail"]["detail"] == "Invalid credentials"
