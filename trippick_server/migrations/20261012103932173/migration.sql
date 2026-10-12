BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "place_report" (
    "id" bigserial PRIMARY KEY,
    "placeId" bigint NOT NULL,
    "kind" text NOT NULL,
    "note" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "place_report_place_idx" ON "place_report" USING btree ("placeId");


--
-- MIGRATION VERSION FOR trippick
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('trippick', '20261012103932173', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261012103932173', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();


COMMIT;
