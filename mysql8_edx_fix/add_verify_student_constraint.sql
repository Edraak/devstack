USE edxapp;

-- Check if the constraint already exists
SET @index_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema = 'edxapp'
    AND table_name = 'verify_student_skippedreverification'
    AND index_name = 'unique_skippedreverification'
);

-- Add the constraint only if it's missing
SET @ddl := IF(
  @index_exists = 0,
  'ALTER TABLE verify_student_skippedreverification ADD UNIQUE INDEX unique_skippedreverification (user_id, course_id);',
  'SELECT "Constraint already exists"'
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
