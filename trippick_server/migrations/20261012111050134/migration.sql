BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "trip" (
    "id" bigserial PRIMARY KEY,
    "deviceId" text NOT NULL,
    "title" text NOT NULL,
    "area" text NOT NULL,
    "days" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "trip_device_idx" ON "trip" USING btree ("deviceId");


--
-- MIGRATION VERSION FOR trippick
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('trippick', '20261012111050134', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261012111050134', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();


COMMIT;
