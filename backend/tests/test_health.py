"""Health tracking endpoint tests."""

import pytest
from datetime import datetime


@pytest.mark.asyncio
async def test_log_bp(client, auth_headers):
    resp = await client.post("/api/v1/health/bp-reading", headers=auth_headers, json={
        "systolic": 135,
        "diastolic": 85,
        "measured_at": "2026-04-08T10:00:00Z",
    })
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["record_type"] == "vitals"
    assert data["status"]["status"] == "Hypertension Stage 1"


@pytest.mark.asyncio
async def test_log_bp_normal(client, auth_headers):
    resp = await client.post("/api/v1/health/bp-reading", headers=auth_headers, json={
        "systolic": 115,
        "diastolic": 75,
        "measured_at": "2026-04-08T10:00:00Z",
    })
    data = resp.json()["data"]
    assert data["status"]["status"] == "Normal"


@pytest.mark.asyncio
async def test_log_sugar_diabetes(client, auth_headers):
    resp = await client.post("/api/v1/health/sugar-reading", headers=auth_headers, json={
        "glucose_value": 250,
        "reading_type": "random",
        "measured_at": "2026-04-08T10:00:00Z",
    })
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["status"]["status"] == "Diabetes"


@pytest.mark.asyncio
async def test_log_sugar_normal(client, auth_headers):
    resp = await client.post("/api/v1/health/sugar-reading", headers=auth_headers, json={
        "glucose_value": 90,
        "reading_type": "fasting",
        "measured_at": "2026-04-08T10:00:00Z",
    })
    data = resp.json()["data"]
    assert data["status"]["status"] == "Normal"


@pytest.mark.asyncio
async def test_log_weight_with_bmi(client, auth_headers):
    resp = await client.post("/api/v1/health/weight", headers=auth_headers, json={
        "weight_kg": 75,
        "measured_at": "2026-04-08T10:00:00Z",
    })
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert "weight_kg" in data["values"]


@pytest.mark.asyncio
async def test_get_records(client, auth_headers):
    # Log something first
    await client.post("/api/v1/health/bp-reading", headers=auth_headers, json={
        "systolic": 120,
        "diastolic": 80,
        "measured_at": "2026-04-08T10:00:00Z",
    })
    resp = await client.get("/api/v1/health/records?record_type=vitals", headers=auth_headers)
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert isinstance(data, list)
    assert len(data) >= 1
