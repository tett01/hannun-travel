BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "place" (
    "id" bigserial PRIMARY KEY,
    "sourceId" text NOT NULL,
    "name" text NOT NULL,
    "nameEn" text,
    "category" text NOT NULL,
    "address" text NOT NULL,
    "lat" double precision NOT NULL,
    "lng" double precision NOT NULL,
    "tel" text,
    "imageUrl" text,
    "overview" text,
    "facts" json,
    "highlightKo" json,
    "highlightEn" json,
    "reviewSummaryKo" json,
    "reviewSummaryEn" json,
    "reviewSummaryBasis" bigint NOT NULL DEFAULT 0,
    "reviewCount" bigint NOT NULL DEFAULT 0,
    "ratingAvg" double precision,
    "tags" json,
    "detailFetchedAt" timestamp without time zone,
    "summarizedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "place_source_id_idx" ON "place" USING btree ("sourceId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_review" (
    "id" bigserial PRIMARY KEY,
    "placeId" bigint NOT NULL,
    "author" text NOT NULL,
    "rating" bigint NOT NULL,
    "text" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "user_review_place_idx" ON "user_review" USING btree ("placeId");


--
-- MIGRATION VERSION FOR trippick
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('trippick', '20261010021612159', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261010021612159', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();


COMMIT;
