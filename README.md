# Hannun Travel (한눈에여행)

**Everything about the place you're visiting, at a glance.**
*Hannun* (한눈) means "at a glance" in Korean.

Hannun Travel is a travel companion built with **Flutter** and **Serverpod**. Open it anywhere and it shows the sights, food and things to do around you, each with a three-line AI summary in Korean and English:

- **At a glance**: highlights, things to know (closing days, parking, fees) and a tip, summarized from official tourism data and Wikipedia.
- **Review summary**: once a place has three or more reviews written in the app, an AI summary of pros, cons and a tip appears and refreshes with every new review.

Built for the Serverpod *Build Something Real* hackathon.

## Features

- **Nearby, anywhere**: uses your location, a featured area, or any hotel, address or place you search for (e.g. around the hotel you booked), and lists places within 6 km, nearest first. The first visit to a new area collects its places on the fly.
- **Korea and the rest of the world**: Korea uses the Korea Tourism Organization's official TourAPI (with photos and visitor info) plus Kakao Local, which also adds indoor fun (arcades, bowling, escape rooms, kids' cafés, indoor racing) that TourAPI barely lists. Everywhere else uses OpenStreetMap and Wikipedia.
- **Filter by kind**: each category has a second row of filters, e.g. History or Museums & culture for sights, Korean or Cafés for food, Water sports or Indoor fun for activities.
- **Taste-based ranking**: pick Relaxing, Active, Foodie or Photo spots, and places tagged for that taste come first.
- **AI that cannot invent places**: places only come from TourAPI, Kakao or OpenStreetMap. The AI only summarizes the text it is given, is told to write "No info" rather than guess, and its tags are checked against a fixed list.
- **Reviews**: star rating and text; the server recalculates the average and regenerates the review summary.
- **Route planner**: pick saved places, a travel mode (car, walking, transit) and a start time, and get up to three visiting orders: one that fits opening hours (waits out break times, warns about closing days), one that puts restaurants at meal times, and one with the least travel. Each shows arrival times, parking in car mode and an estimated cost per person, and opens in Kakao Map or Google Maps for directions.
- **Map view** with place cards, **saved places**, and a **Korean / English** switch.

## How Serverpod is used

| Piece | What it does |
| --- | --- |
| `PlaceEndpoint.nearby(lat, lng)` | Returns places around a point; collects a new area the first time it is requested |
| `PlaceEndpoint.searchLocation(query, language)` | Finds a hotel, address or place to explore around (Kakao in Korea, OpenStreetMap Nominatim elsewhere) |
| `PlaceEndpoint.regionName(lat, lng, language)` | Neighborhood name for the header (Kakao in Korea, OpenStreetMap Nominatim elsewhere) |
| `ReviewEndpoint.add / list` | Stores reviews, updates ratings and regenerates the AI review summary |
| `RouteEndpoint.plan(placeIds, mode, ...)` | Gets travel times between all stops from the Mapbox Matrix API (or estimates them), parses opening hours, break times, closing days and fees, and compares every visiting order |
| Models (`.spy.yaml`) | `Place`, `ReviewSummary`, `UserReview`, `CollectedArea` with Postgres tables and migrations, plus `LocationHit` for search results and `RoutePlan` / `RouteStop` for routes |
| Background sync | On start and after each new area, a background session fills official details, Wikipedia text, place kinds and AI summaries, skipping finished work (areas collected earlier also get newly added kinds, such as indoor fun) |
| Passwords | API keys live in `config/passwords.yaml` locally and in Serverpod Cloud passwords, never in code |

The Flutter app talks to the server through the generated client (`client.place.nearby(...)`, `client.review.add(...)`).

## Architecture

```
Flutter app (web / iOS / Android)
   │  generated Serverpod client
   ▼
Serverpod server ── Postgres (places, reviews, collected areas)
   ├─ Korea:    TourAPI (KTO) + Kakao Local
   ├─ Overseas: OpenStreetMap Overpass + Wikipedia / Wikidata
   ├─ Routes:   Mapbox Matrix API (travel times)
   └─ AI:       Groq (OpenAI-compatible) for KO/EN summaries
```

## Running locally

Requirements: Flutter 3.44+ and the Serverpod CLI (`dart install serverpod_cli`). Docker is not needed; Serverpod runs an embedded Postgres.

1. Add API keys to `trippick_server/config/passwords.yaml` under `shared:`:
   ```yaml
   shared:
     kakaoRestKey: ''      # Kakao Developers REST API key
     tourApiKey: ''        # data.go.kr TourAPI (KorService2), "Decoding" key
     groqApiKey: ''        # console.groq.com
     mapboxToken: ''       # account.mapbox.com (no card needed); routes fall back to estimates without it
   ```
   Every key is optional: the server skips whatever it cannot do. Places outside Korea need no keys; AI summaries need the Groq key.
2. From the project root:
   ```bash
   serverpod start
   ```
   This starts the server and opens the Flutter web app.

Server tests (stop `serverpod start` first, since they use their own embedded database):

```bash
cd trippick_server && dart test
```

## Data sources and attribution

- Tourism information: Korea Tourism Organization (한국관광공사) TourAPI, KOGL Type 1
- Places in Korea (including indoor fun): Kakao Local API
- Places outside Korea and map tiles: © OpenStreetMap contributors (ODbL)
- Descriptions and photos outside Korea: Wikipedia / Wikimedia Commons (CC BY-SA)
- Route travel times: Mapbox Matrix API
- AI summaries: generated with models served by Groq

## Project layout

```
trippick_server/   Serverpod server: endpoints, models, data sync (lib/src/places)
trippick_client/   Generated client
trippick_flutter/  Flutter app: screens, widgets, theme, ko/en strings
```
