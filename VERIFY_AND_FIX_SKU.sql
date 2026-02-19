-- ============================================================
-- VERIFICATION AND FIX FOR SKU ISSUE
-- Run these queries in Supabase SQL Editor ONE BY ONE
-- ============================================================

-- STEP 1: Check if products have SKU values
-- Copy this query, run it, and tell me what you see
SELECT id, name, sku, rarity
FROM products
LIMIT 10;

-- EXPECTED: You should see SKU values like "SKU-001", "SKU-002", etc.
-- IF SKU COLUMN IS NULL OR EMPTY, that's the problem!

-- ============================================================

-- STEP 2: If SKUs are NULL, run this to generate them
-- (Only run this if Step 1 showed NULL/empty SKUs)
UPDATE products
SET sku = 'SKU-' || LPAD(ROW_NUMBER() OVER (ORDER BY created_at)::TEXT, 3, '0')
WHERE sku IS NULL OR sku = '';

-- ============================================================

-- STEP 3: Verify the functions were actually updated
-- Run this to see the current function definition
SELECT prosrc
FROM pg_proc
WHERE proname = 'open_mystery_box';

-- Look for "v_product_sku" in the output - if you DON'T see it,
-- the migration didn't actually update the function

-- ============================================================

-- STEP 4: If the function wasn't updated, force-drop and recreate
-- (Only run this if Step 3 showed the old function without v_product_sku)

DROP FUNCTION IF EXISTS open_mystery_box(UUID);
DROP FUNCTION IF EXISTS open_mystery_box_with_exclusions(UUID, UUID[]);

-- Then run migration 009 again

-- ============================================================

-- STEP 5: After everything, test with this query
-- This simulates what the function does
SELECT p.id, p.name, p.sku, p.buyback_price, p.resale_value
FROM products p
JOIN inventory i ON p.id = i.product_id
WHERE p.rarity = 'common'
  AND i.quantity_available > 0
LIMIT 1;

-- EXPECTED: You should see a row with a SKU value (not NULL)
-- If SKU is NULL here, the products table still needs SKU values

-- ============================================================
