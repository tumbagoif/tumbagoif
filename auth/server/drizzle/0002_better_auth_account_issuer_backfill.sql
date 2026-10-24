ALTER TABLE "account" ADD COLUMN IF NOT EXISTS "issuer" text;

UPDATE "account" AS a
SET
  "accountId" = CASE
    WHEN a."providerId" = 'microsoft' AND u.oid IS NOT NULL THEN u.oid
    ELSE a."accountId"
  END,
  "issuer" = CASE
    WHEN a."providerId" = 'microsoft' AND u.tid IS NOT NULL
      THEN 'https://login.microsoftonline.com/' || u.tid || '/v2.0'
    WHEN a."providerId" IN ('credential', 'siwe')
      THEN COALESCE(a."issuer", 'local:' || a."providerId")
    ELSE COALESCE(a."issuer", 'local:oauth:' || a."providerId")
  END
FROM "user" AS bu
LEFT JOIN "users" AS u
  ON u.auth_user_id = bu.id
WHERE bu.id = a."userId";

-- issuer is intentionally left nullable and non-unique; see 0003_better_auth_account_issuer_relax.sql
