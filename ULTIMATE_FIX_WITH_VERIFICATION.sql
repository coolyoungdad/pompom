-- ============================================================
-- ULTIMATE FIX WITH VERIFICATION
-- This will fix the function AND verify it worked
-- ============================================================

-- Step 1: Drop old functions
DROP FUNCTION IF EXISTS open_mystery_box(UUID) CASCADE;
DROP FUNCTION IF EXISTS open_mystery_box_with_exclusions(UUID, UUID[]) CASCADE;

-- Step 2: Create new function WITH RARITY
CREATE FUNCTION open_mystery_box(p_user_id UUID)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  product_id UUID,
  product_name TEXT,
  rarity rarity_tier,
  buyback_price DECIMAL(10, 2),
  resale_value DECIMAL(10, 2),
  new_balance DECIMAL(10, 2),
  inventory_item_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_box_price DECIMAL(10, 2) := 25.00;
  v_user_balance DECIMAL(10, 2);
  v_new_balance DECIMAL(10, 2);
  v_rarity rarity_tier;
  v_product_id UUID;
  v_product_name TEXT;
  v_product_sku TEXT;
  v_buyback_price DECIMAL(10, 2);
  v_resale_value DECIMAL(10, 2);
  v_inventory_item_id UUID;
  v_rand DECIMAL;
BEGIN
  SELECT users.account_balance INTO v_user_balance
  FROM public.users WHERE users.id = p_user_id FOR UPDATE;

  IF v_user_balance < v_box_price THEN
    RETURN QUERY SELECT false, 'Insufficient balance', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  v_rand := random();
  IF v_rand < 0.01 THEN v_rarity := 'ultra';
  ELSIF v_rand < 0.10 THEN v_rarity := 'rare';
  ELSIF v_rand < 0.40 THEN v_rarity := 'uncommon';
  ELSE v_rarity := 'common';
  END IF;

  SELECT products.id, products.name, products.sku, products.buyback_price, products.resale_value
  INTO v_product_id, v_product_name, v_product_sku, v_buyback_price, v_resale_value
  FROM public.products
  JOIN public.inventory ON products.id = inventory.product_id
  WHERE products.rarity = v_rarity AND inventory.quantity_available > 0
  ORDER BY random() LIMIT 1;

  IF v_product_id IS NULL THEN
    SELECT products.id, products.name, products.sku, products.rarity, products.buyback_price, products.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products
    JOIN public.inventory ON products.id = inventory.product_id
    WHERE inventory.quantity_available > 0
    ORDER BY random() LIMIT 1;
  END IF;

  IF v_product_id IS NULL THEN
    RETURN QUERY SELECT false, 'Out of stock', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  UPDATE public.inventory SET quantity_available = inventory.quantity_available - 1
  WHERE inventory.product_id = v_product_id AND inventory.quantity_available > 0;

  UPDATE public.users SET account_balance = users.account_balance - v_box_price
  WHERE users.id = p_user_id RETURNING users.account_balance INTO v_new_balance;

  INSERT INTO public.balance_transactions (user_id, amount, type, description)
  VALUES (p_user_id, -v_box_price, 'box_purchase', 'Mystery box opened');

  -- CRITICAL LINE: Insert with BOTH product_sku AND rarity
  INSERT INTO public.user_inventory (user_id, product_id, product_name, product_sku, rarity, buyback_price, status)
  VALUES (p_user_id, v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, 'kept')
  RETURNING id INTO v_inventory_item_id;

  RETURN QUERY SELECT true, 'Success', v_product_id, v_product_name,
                      v_rarity, v_buyback_price, v_resale_value,
                      v_new_balance, v_inventory_item_id;
END;
$$;

-- Step 3: Create second function
CREATE FUNCTION open_mystery_box_with_exclusions(p_user_id UUID, p_excluded_ids UUID[] DEFAULT NULL)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  product_id UUID,
  product_name TEXT,
  rarity rarity_tier,
  buyback_price DECIMAL(10, 2),
  resale_value DECIMAL(10, 2),
  new_balance DECIMAL(10, 2),
  inventory_item_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_box_price DECIMAL(10, 2) := 25.00;
  v_user_balance DECIMAL(10, 2);
  v_new_balance DECIMAL(10, 2);
  v_rarity rarity_tier;
  v_product_id UUID;
  v_product_name TEXT;
  v_product_sku TEXT;
  v_buyback_price DECIMAL(10, 2);
  v_resale_value DECIMAL(10, 2);
  v_inventory_item_id UUID;
  v_rand DECIMAL;
BEGIN
  SELECT users.account_balance INTO v_user_balance
  FROM public.users WHERE users.id = p_user_id FOR UPDATE;

  IF v_user_balance < v_box_price THEN
    RETURN QUERY SELECT false, 'Insufficient balance', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  v_rand := random();
  IF v_rand < 0.01 THEN v_rarity := 'ultra';
  ELSIF v_rand < 0.10 THEN v_rarity := 'rare';
  ELSIF v_rand < 0.40 THEN v_rarity := 'uncommon';
  ELSE v_rarity := 'common';
  END IF;

  SELECT products.id, products.name, products.sku, products.buyback_price, products.resale_value
  INTO v_product_id, v_product_name, v_product_sku, v_buyback_price, v_resale_value
  FROM public.products
  JOIN public.inventory ON products.id = inventory.product_id
  WHERE products.rarity = v_rarity AND inventory.quantity_available > 0
    AND (p_excluded_ids IS NULL OR products.id != ALL(p_excluded_ids))
  ORDER BY random() LIMIT 1;

  IF v_product_id IS NULL THEN
    SELECT products.id, products.name, products.sku, products.rarity, products.buyback_price, products.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products
    JOIN public.inventory ON products.id = inventory.product_id
    WHERE inventory.quantity_available > 0
      AND (p_excluded_ids IS NULL OR products.id != ALL(p_excluded_ids))
    ORDER BY random() LIMIT 1;
  END IF;

  IF v_product_id IS NULL THEN
    SELECT products.id, products.name, products.sku, products.rarity, products.buyback_price, products.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products
    JOIN public.inventory ON products.id = inventory.product_id
    WHERE inventory.quantity_available > 0
    ORDER BY random() LIMIT 1;
  END IF;

  IF v_product_id IS NULL THEN
    RETURN QUERY SELECT false, 'Out of stock', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  UPDATE public.inventory SET quantity_available = inventory.quantity_available - 1
  WHERE inventory.product_id = v_product_id AND inventory.quantity_available > 0;

  UPDATE public.users SET account_balance = users.account_balance - v_box_price
  WHERE users.id = p_user_id RETURNING users.account_balance INTO v_new_balance;

  INSERT INTO public.balance_transactions (user_id, amount, type, description)
  VALUES (p_user_id, -v_box_price, 'box_purchase', 'Mystery box opened');

  -- CRITICAL LINE: Insert with BOTH product_sku AND rarity
  INSERT INTO public.user_inventory (user_id, product_id, product_name, product_sku, rarity, buyback_price, status)
  VALUES (p_user_id, v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, 'kept')
  RETURNING id INTO v_inventory_item_id;

  RETURN QUERY SELECT true, 'Success', v_product_id, v_product_name,
                      v_rarity, v_buyback_price, v_resale_value,
                      v_new_balance, v_inventory_item_id;
END;
$$;

-- Step 4: VERIFICATION - This will show you if it worked
SELECT
  'VERIFICATION: Function has rarity in INSERT' as status,
  CASE
    WHEN prosrc LIKE '%product_sku, rarity, buyback_price%' THEN '✅ CORRECT - Has rarity!'
    ELSE '❌ FAILED - Missing rarity!'
  END as result
FROM pg_proc
WHERE proname = 'open_mystery_box';

-- ============================================================
-- After running, you should see:
-- Row 1: "✅ CORRECT - Has rarity!"
-- If you see "❌ FAILED" something is very wrong
-- ============================================================
