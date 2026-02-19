-- Run this to see if the function has rarity in the INSERT
SELECT prosrc
FROM pg_proc
WHERE proname = 'open_mystery_box'
AND prosrc LIKE '%rarity%';

-- If this returns NO ROWS, the function is still broken
-- If it returns a row, the function includes rarity
