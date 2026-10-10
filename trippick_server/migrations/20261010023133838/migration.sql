BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "collected_area" (
    "id" bigserial PRIMARY KEY,
    "lat" double precision NOT NULL,
    "lng" double precision NOT NULL,
    "collectedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);


--
-- MIGRATION VERSION FOR trippick
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('trippick', '20261010023133838', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261010023133838', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();


COMMIT;
