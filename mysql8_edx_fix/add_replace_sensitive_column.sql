USE edxapp;

SET @column_exists := (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = 'edxapp'
    AND table_name = 'enterprise_enterprisecustomer'
    AND column_name = 'replace_sensitive_sso_username'
);

SET @ddl := IF(
  @column_exists = 0,
  'ALTER TABLE enterprise_enterprisecustomer ADD COLUMN replace_sensitive_sso_username TINYINT(1) DEFAULT 0;',
  'SELECT "Column already exists";'
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
