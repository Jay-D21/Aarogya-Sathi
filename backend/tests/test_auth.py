"""Auth endpoint tests."""

import pytest


@pytest.mark.asyncio
async def test_register_success(client):
    resp = await client.post("/api/v1/auth/register", json={
        "email": "new@aarogya.com",
        "phone": "+919876543211",
        "password": "Secure123!",
        "first_name": "Priya",
    })
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "success"
    assert data["data"]["email"] == "new@aarogya.com"
    assert data["data"]["first_name"] == "Priya"
    assert "id" in data["data"]


@pytest.mark.asyncio
async def test_register_duplicate_email(client):
    payload = {
        "email": "dup@aarogya.com",
        "phone": "+919876543212",
        "password": "Secure123!",
        "first_name": "Test",
    }
    await client.post("/api/v1/auth/register", json=payload)
    resp = await client.post("/api/v1/auth/register", json=payload)
    assert resp.status_code == 400


@pytest.mark.asyncio
async def test_login_success(client):
    await client.post("/api/v1/auth/register", json={
        "email": "login@aarogya.com",
        "phone": "+919876543213",
        "password": "Login123!",
        "first_name": "Login",
    })
    resp = await client.post("/api/v1/auth/login", json={
        "email": "login@aarogya.com",
        "password": "Login123!",
    })
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "Bearer"


@pytest.mark.asyncio
async def test_login_wrong_password(client):
    await client.post("/api/v1/auth/register", json={
        "email": "wrong@aarogya.com",
        "phone": "+919876543214",
        "password": "Correct123!",
        "first_name": "Wrong",
    })
    resp = await client.post("/api/v1/auth/login", json={
        "email": "wrong@aarogya.com",
        "password": "WrongPassword!",
    })
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_me_authenticated(client, auth_headers):
    resp = await client.get("/api/v1/auth/me", headers=auth_headers)
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["email"] == "test@aarogya.com"
    assert data["first_name"] == "Raj"


@pytest.mark.asyncio
async def test_me_no_token(client):
    resp = await client.get("/api/v1/auth/me")
    assert resp.status_code == 403  # HTTPBearer returns 403 when no credentials
