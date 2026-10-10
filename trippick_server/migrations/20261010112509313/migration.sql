BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "place" ADD COLUMN "subcategory" text;
ALTER TABLE "place" ADD COLUMN "images" json;
ALTER TABLE "place" ADD COLUMN "factsEn" json;
ALTER TABLE "place" ADD COLUMN "summaryVersion" bigint NOT NULL DEFAULT 0;

--
-- MIGRATION VERSION FOR trippick
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('trippick', '20261010112509313', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261010112509313', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();


COMMIT;
