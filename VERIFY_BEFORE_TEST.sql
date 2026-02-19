-- Run this to verify the function has rarity and sku in the INSERT
SELECT prosrc
FROM pg_proc
WHERE proname = 'open_mystery_box'
  AND prosrc LIKE '%product_sku, rarity%';

-- If this returns a row with the function code, it's correct
-- If it returns NO ROWS, something went wrong
