-- Run this to see all versions of the box open functions
SELECT
  proname as function_name,
  pronargs as num_args,
  pg_get_function_identity_arguments(oid) as arguments
FROM pg_proc
WHERE proname IN ('open_mystery_box', 'open_mystery_box_with_exclusions')
ORDER BY proname, pronargs;
