# SkyBook Flight API - Quick Start Guide

A comprehensive mock flight booking API for testing iOS applications.

## 🚀 Quick Start

### 1. Get Your API Key

First, create an API key:

```bash
curl -X POST http://localhost:3000/api/v1/keys \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your@email.com",
    "name": "Your Name"
  }'
```

**Response:**
```json
{
  "data": {
    "token": "sk_abc123...",
    "email": "your@email.com",
    "name": "Your Name",
    "created_at": "2026-06-18T12:00:00Z"
  }
}
```

Save your `token` - you'll need it for all API requests!

### 2. Search for Flights

```bash
curl http://localhost:3000/api/v1/flights?origin=LAX&destination=JFK \
  -H "Authorization: Bearer sk_abc123..."
```

### 3. Book a Flight

```bash
curl -X POST http://localhost:3000/api/v1/bookings \
  -H "Authorization: Bearer sk_abc123..." \
  -H "Content-Type: application/json" \
  -d '{
    "flight_id": "flight-uuid-here",
    "seat_id": "seat-uuid-here",
    "passenger_name": "John Smith"
  }'
```

---

## 📚 Complete API Reference

### Authentication

All endpoints (except `/api/v1/keys`) require authentication via Bearer token:

```bash
Authorization: Bearer YOUR_API_KEY_HERE
```

---

## 🔑 API Keys

### Create API Key

**Endpoint:** `POST /api/v1/keys`

**No authentication required**

**Request:**
```json
{
  "email": "user@example.com",
  "name": "John Doe"  // optional
}
```

**Success Response (201):**
```json
{
  "data": {
    "token": "sk_1234567890abcdef",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2026-06-18T12:00:00Z"
  }
}
```

**Error Response (409 - Email already exists):**
```json
{
  "error": "duplicate_email",
  "message": "An API key already exists for this email. Use /keys/recover to retrieve it.",
  "code": "DUPLICATE_EMAIL"
}
```

---

### Recover API Key

**Endpoint:** `POST /api/v1/keys/recover`

**No authentication required**

Sends your API key to your email if it exists.

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "message": "If this email is on file, we've sent the API key to it."
}
```

Note: Response is always the same for security (doesn't reveal if email exists).

---

## ✈️ Flights

### Search Flights

**Endpoint:** `GET /api/v1/flights`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `origin` | string | Yes | Origin airport code (3 letters) | `LAX` |
| `destination` | string | Yes | Destination airport code | `JFK` |
| `date` | date | No | Departure date (YYYY-MM-DD) | `2026-06-20` |
| `status` | string | No | Filter by status | `on_time`, `delayed`, `cancelled` |

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/flights?origin=LAX&destination=JFK&date=2026-06-20" \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "flight_number": "UA1234",
      "status": "on_time",
      "departure": {
        "airport": {
          "code": "LAX",
          "name": "Los Angeles International",
          "city": "Los Angeles",
          "weather": {
            "temperature": 72,
            "condition": "sunny",
            "icon": "☀️"
          }
        },
        "scheduled_at": "2026-06-20T08:00:00Z",
        "actual_at": null,
        "terminal": "5",
        "gate": "52A"
      },
      "arrival": {
        "airport": {
          "code": "JFK",
          "name": "John F. Kennedy International",
          "city": "New York",
          "weather": {
            "temperature": 68,
            "condition": "partly_cloudy",
            "icon": "⛅"
          }
        },
        "scheduled_at": "2026-06-20T16:30:00Z",
        "actual_at": null,
        "terminal": "4",
        "gate": "B12"
      },
      "aircraft": {
        "model": "Boeing 777-200",
        "total_seats": 304,
        "economy_seats": 224,
        "first_seats": 16,
        "business_seats": 64
      },
      "duration_minutes": 330,
      "pricing": {
        "economy": "$299.00",
        "comfort_plus": "$449.00",
        "business": "$1,799.00",
        "first": null
      },
      "available_seats": 187
    }
  ],
  "meta": {
    "count": 1,
    "origin": "LAX",
    "destination": "JFK",
    "date": "2026-06-20"
  }
}
```

---

### Get Flight Details

**Endpoint:** `GET /api/v1/flights/:id`

**Authentication:** Required

**Example Request:**
```bash
curl http://localhost:3000/api/v1/flights/550e8400-e29b-41d4-a716-446655440000 \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
Same structure as search results, but returns a single flight object in `data`.

**Error Response (404):**
```json
{
  "error": "not_found",
  "message": "Flight not found",
  "code": "NOT_FOUND"
}
```

---

## 💺 Seats

### Get Seat Map

**Endpoint:** `GET /api/v1/flights/:flight_id/seats`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `seat_class` | string | No | Filter by class: `economy`, `comfort_plus`, `business`, `first` |
| `seat_type` | string | No | Filter by type: `window`, `aisle`, `middle` |
| `available` | boolean | No | Filter by availability: `true`, `false` |

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/flights/550e8400.../seats?seat_class=economy&available=true" \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "seat-uuid-123",
      "seat_number": "12A",
      "row": 12,
      "column": "A",
      "deck": "main",
      "seat_class": "economy",
      "seat_type": "window",
      "is_available": true,
      "features": [],
      "price": "$299.00"
    },
    {
      "id": "seat-uuid-456",
      "seat_number": "12B",
      "row": 12,
      "column": "B",
      "deck": "main",
      "seat_class": "economy",
      "seat_type": "middle",
      "is_available": true,
      "features": [],
      "price": "$299.00"
    }
  ],
  "meta": {
    "total_seats": 224,
    "available_seats": 187,
    "flight_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

---

### Get Seat Details

**Endpoint:** `GET /api/v1/flights/:flight_id/seats/:id`

**Authentication:** Required

**Example Request:**
```bash
curl http://localhost:3000/api/v1/flights/550e8400.../seats/seat-uuid-123 \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
Returns a single seat object in `data`.

---

## 📋 Bookings

### List Your Bookings

**Endpoint:** `GET /api/v1/bookings`

**Authentication:** Required

**Example Request:**
```bash
curl http://localhost:3000/api/v1/bookings \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "booking-uuid-123",
      "confirmation_code": "ABC123",
      "status": "confirmed",
      "passenger_name": "John Smith",
      "created_at": "2026-06-18T12:00:00Z",
      "flight": {
        "id": "flight-uuid-123",
        "flight_number": "UA1234",
        "departure": {
          "airport_code": "LAX",
          "scheduled_at": "2026-06-20T08:00:00Z"
        },
        "arrival": {
          "airport_code": "JFK",
          "scheduled_at": "2026-06-20T16:30:00Z"
        }
      },
      "seat": {
        "id": "seat-uuid-123",
        "seat_number": "12A",
        "seat_class": "economy"
      }
    }
  ]
}
```

---

### Create Booking

**Endpoint:** `POST /api/v1/bookings`

**Authentication:** Required

**Request:**
```json
{
  "flight_id": "550e8400-e29b-41d4-a716-446655440000",
  "seat_id": "seat-uuid-123",
  "passenger_name": "John Smith"
}
```

**Success Response (201):**
```json
{
  "data": {
    "id": "booking-uuid-123",
    "confirmation_code": "ABC123",
    "status": "confirmed",
    "passenger_name": "John Smith",
    "created_at": "2026-06-18T12:00:00Z",
    "flight": { /* flight details */ },
    "seat": { /* seat details */ }
  }
}
```

**Error Responses:**

**409 - Seat Unavailable:**
```json
{
  "error": "seat_unavailable",
  "message": "This seat is no longer available",
  "code": "SEAT_UNAVAILABLE"
}
```

**422 - Validation Error:**
```json
{
  "error": "validation_error",
  "message": "Flight is cancelled or diverted",
  "code": "VALIDATION_ERROR"
}
```

---

### Get Booking Details

**Endpoint:** `GET /api/v1/bookings/:id`

**Authentication:** Required

**Example Request:**
```bash
curl http://localhost:3000/api/v1/bookings/booking-uuid-123 \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
Returns booking details (same structure as create).

---

### Cancel Booking

**Endpoint:** `DELETE /api/v1/bookings/:id`

**Authentication:** Required

**Example Request:**
```bash
curl -X DELETE http://localhost:3000/api/v1/bookings/booking-uuid-123 \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
```json
{
  "message": "Booking cancelled successfully"
}
```

---

## ✈️ Airlines

### List All Airlines

**Endpoint:** `GET /api/v1/airlines`

**Authentication:** Not required

**Example Request:**
```bash
curl http://localhost:3000/api/v1/airlines
```

**Success Response (200):**
```json
{
  "data": [
    {
      "code": "AX",
      "name": "Aerolux",
      "country": "USA",
      "airline_type": "legacy",
      "logo": {
        "svg": "http://localhost:3000/airline-logos/01_aerolux.svg",
        "png": "http://localhost:3000/airline-logos/01_aerolux@3x.png"
      },
      "created_at": "2026-06-18T21:07:19Z"
    }
  ]
}
```

---

### Get Airline Details

**Endpoint:** `GET /api/v1/airlines/:code`

**Authentication:** Not required

**Example Request:**
```bash
curl http://localhost:3000/api/v1/airlines/AX
```

**Success Response (200):**
Returns a single airline object in `data`.

---

### Airlines List

The API includes **12 airlines** across three categories:

**Legacy Carriers (5):**
- AX - Aerolux
- PL - Polaris
- AL - ALTAIR
- MD - Meridian
- AR - Aurora

**Low-Cost Carriers (4):**
- NB - Nimbus Air
- SB - SKYBOUND
- ZP - Zephyr
- ST - Solstice

**Regional Carriers (3):**
- VX - VERTEX
- CS - Cascade
- NW - NORTHWIND

---

## 🌍 Weather

### Get Weather Forecast

**Endpoint:** `GET /api/v1/weather`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `airport` | string | Yes | Airport code (e.g., `LAX`) |
| `date` | date | No | Forecast date (defaults to today) |

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/weather?airport=LAX&date=2026-06-20" \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
```json
{
  "data": {
    "airport": {
      "code": "LAX",
      "name": "Los Angeles International",
      "city": "Los Angeles"
    },
    "forecast_date": "2026-06-20",
    "temperature_f": 72,
    "condition": "sunny",
    "icon": "☀️",
    "humidity_percent": 45,
    "wind_speed_mph": 8,
    "wind_direction": "W",
    "precipitation_chance": 5,
    "visibility_miles": 10
  }
}
```

---

### Get Multi-Day Forecast

**Endpoint:** `GET /api/v1/weather/forecast`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `airport` | string | Yes | Airport code |
| `days` | integer | No | Number of days (1-7, default: 7) |

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/weather/forecast?airport=LAX&days=3" \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
```json
{
  "data": [
    {
      "forecast_date": "2026-06-18",
      "temperature_f": 70,
      "condition": "sunny",
      "icon": "☀️"
    },
    {
      "forecast_date": "2026-06-19",
      "temperature_f": 72,
      "condition": "partly_cloudy",
      "icon": "⛅"
    },
    {
      "forecast_date": "2026-06-20",
      "temperature_f": 68,
      "condition": "cloudy",
      "icon": "☁️"
    }
  ],
  "meta": {
    "airport": "LAX",
    "days": 3
  }
}
```

---

## 🚨 Live Flight Tracking

### Get Live Flights

**Endpoint:** `GET /api/v1/live/flights`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by status: `boarding`, `in_flight`, `landed` |
| `airport` | string | No | Filter by airport code |

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/live/flights?status=in_flight" \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "flight-uuid-123",
      "flight_number": "UA1234",
      "status": "in_flight",
      "origin": "LAX",
      "destination": "JFK",
      "scheduled_departure": "2026-06-18T08:00:00Z",
      "actual_departure": "2026-06-18T08:05:00Z",
      "scheduled_arrival": "2026-06-18T16:30:00Z",
      "estimated_arrival": "2026-06-18T16:40:00Z",
      "current_location": {
        "latitude": 40.7128,
        "longitude": -74.0060,
        "altitude_ft": 35000
      }
    }
  ]
}
```

---

### Live Flight Stats

**Endpoint:** `GET /api/v1/live/stats`

**Authentication:** Required

**Example Request:**
```bash
curl http://localhost:3000/api/v1/live/stats \
  -H "Authorization: Bearer sk_abc123..."
```

**Success Response (200):**
```json
{
  "data": {
    "total_flights_today": 1234,
    "on_time": 892,
    "delayed": 198,
    "cancelled": 12,
    "diverted": 3,
    "in_flight": 456,
    "landed": 689,
    "scheduled": 89,
    "on_time_percentage": 72.3
  }
}
```

---

## 📊 Available Airports

### Domestic US (40 airports)

**Tier 1 Hubs (Major):**
- ATL - Atlanta
- ORD - Chicago O'Hare
- DFW - Dallas/Fort Worth
- LAX - Los Angeles
- DEN - Denver
- JFK - New York JFK
- SFO - San Francisco
- SEA - Seattle
- LAS - Las Vegas
- MCO - Orlando

**Tier 2 Hubs (Regional):**
- PHX - Phoenix
- IAH - Houston
- CLT - Charlotte
- MIA - Miami
- EWR - Newark
- MSP - Minneapolis
- BOS - Boston
- DTW - Detroit
- PHL - Philadelphia
- LGA - New York LaGuardia

**Tier 3 Hubs (Spoke Cities):**
- SLC - Salt Lake City
- BWI - Baltimore
- TPA - Tampa
- SAN - San Diego
- PDX - Portland
- STL - St. Louis
- MDW - Chicago Midway
- HOU - Houston Hobby
- OAK - Oakland
- BNA - Nashville
- AUS - Austin
- RDU - Raleigh-Durham
- SMF - Sacramento
- SJC - San Jose
- MCI - Kansas City
- IND - Indianapolis
- CLE - Cleveland
- PIT - Pittsburgh
- CMH - Columbus
- MKE - Milwaukee

### International (30 airports)

**Europe:**
- LHR - London Heathrow
- CDG - Paris Charles de Gaulle
- FRA - Frankfurt
- AMS - Amsterdam Schiphol
- MAD - Madrid
- FCO - Rome Fiumicino
- MUC - Munich
- ZRH - Zurich
- VIE - Vienna
- CPH - Copenhagen

**Asia:**
- NRT - Tokyo Narita
- HND - Tokyo Haneda
- HKG - Hong Kong
- SIN - Singapore Changi
- ICN - Seoul Incheon
- PVG - Shanghai Pudong
- PEK - Beijing Capital
- BKK - Bangkok
- KUL - Kuala Lumpur
- DEL - New Delhi

**Other Regions:**
- DXB - Dubai
- SYD - Sydney
- MEL - Melbourne
- YYZ - Toronto
- YVR - Vancouver
- MEX - Mexico City
- GRU - São Paulo
- EZE - Buenos Aires
- JNB - Johannesburg
- CAI - Cairo

---

## ⚠️ Error Codes

All error responses follow this format:

```json
{
  "error": "error_type",
  "message": "Human-readable error message",
  "code": "ERROR_CODE"
}
```

### Common Error Codes

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 401 | `UNAUTHORIZED` | Missing or invalid API key |
| 404 | `NOT_FOUND` | Resource not found |
| 409 | `DUPLICATE_EMAIL` | Email already has an API key |
| 409 | `SEAT_UNAVAILABLE` | Seat already booked |
| 422 | `VALIDATION_ERROR` | Invalid request data |
| 429 | `RATE_LIMITED` | Too many requests |

---

## 🛡️ Rate Limits

The API uses rate limiting to ensure fair usage:

| Endpoint | Limit |
|----------|-------|
| API Key Creation | 10 per hour per IP |
| Key Recovery | 5 per hour per IP |
| Bookings | 50 per hour per API key |
| Complex Searches | 30 per hour per API key |
| General API | 500 per hour per API key |
| Unauthenticated | 100 per hour per IP |

**Rate Limit Headers:**
```
X-RateLimit-Limit: 500
X-RateLimit-Remaining: 499
X-RateLimit-Reset: 1718712000
```

**Rate Limit Error (429):**
```json
{
  "error": "rate_limited",
  "message": "Too many requests. Please try again later.",
  "code": "RATE_LIMITED",
  "retry_after_seconds": 3600,
  "limit": 500
}
```

---

## 🔄 Scheduled Resets

The API automatically resets data for consistent testing:

| Task | Schedule | Description |
|------|----------|-------------|
| Daily Reset | Every day at 00:00 UTC | Resets flight statuses |
| Weekly Reset | Sunday at 00:00 UTC | Resets seat availability and pricing |
| Weather Refresh | Every day at 01:00 UTC | Generates new 7-day forecasts |

---

## 🧪 Testing Tips

### 1. Predictable Data
- Flights are generated for the next 7 days
- Weather is climate-based (consistent per location)
- Seat availability resets every Sunday

### 2. Edge Cases
- Search for cancelled flights: `?status=cancelled`
- Book seats on full flights to test errors
- Try booking the same seat twice

### 3. Realistic Scenarios
- Morning flights tend to be cheaper
- International flights have business class, domestic have first class
- A380 aircraft have premium pricing

---

## 🌐 Base URLs

**Development:**
```
http://localhost:3000
```

**Production:**
```
https://your-production-url.com
```

---

## 📖 Additional Resources

- **Interactive API Docs:** Visit `/api-docs` when server is running
- **Postman Collection:** Import `docs/SkyBook_API.postman_collection.json`
- **Mockoon File:** Import `docs/SkyBook_API.mockoon.json`

---

## 💡 Quick Examples

### Full Booking Flow

```bash
# 1. Get API Key
curl -X POST http://localhost:3000/api/v1/keys \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# 2. Search Flights
curl "http://localhost:3000/api/v1/flights?origin=LAX&destination=JFK" \
  -H "Authorization: Bearer sk_your_key"

# 3. Get Seat Map
curl "http://localhost:3000/api/v1/flights/FLIGHT_ID/seats?available=true" \
  -H "Authorization: Bearer sk_your_key"

# 4. Create Booking
curl -X POST http://localhost:3000/api/v1/bookings \
  -H "Authorization: Bearer sk_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "flight_id": "FLIGHT_ID",
    "seat_id": "SEAT_ID",
    "passenger_name": "John Smith"
  }'

# 5. View Your Bookings
curl http://localhost:3000/api/v1/bookings \
  -H "Authorization: Bearer sk_your_key"
```

---

## 🆘 Support

For issues or questions:
- Check the interactive docs at `/api-docs`
- Review error messages - they include specific codes and details
- Ensure your API key is valid and included in the Authorization header

---

**Last Updated:** June 2026
**API Version:** v1
