-- Check if function exists and show its full source code
SELECT
  proname as function_name,
  prosrc as source_code
FROM pg_proc
WHERE proname = 'open_mystery_box';
