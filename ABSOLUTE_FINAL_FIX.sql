-- ============================================================
-- ABSOLUTE FINAL FIX
-- This removes ALL possible ambiguous column references
-- ============================================================

-- Drop ALL versions of these functions
DROP FUNCTION IF EXISTS open_mystery_box(UUID);
DROP FUNCTION IF EXISTS open_mystery_box_with_exclusions(UUID, UUID[]);

-- Recreate with ZERO ambiguous references
CREATE OR REPLACE FUNCTION open_mystery_box(p_user_id UUID)
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
) AS $$
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
  -- Check balance
  SELECT users.account_balance INTO v_user_balance
  FROM public.users
  WHERE users.id = p_user_id
  FOR UPDATE;

  IF v_user_balance < v_box_price THEN
    RETURN QUERY SELECT false, 'Insufficient balance', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  -- Roll rarity
  v_rand := random();
  IF v_rand < 0.01 THEN
    v_rarity := 'ultra';
  ELSIF v_rand < 0.10 THEN
    v_rarity := 'rare';
  ELSIF v_rand < 0.40 THEN
    v_rarity := 'uncommon';
  ELSE
    v_rarity := 'common';
  END IF;

  -- Select product (fully qualified column names)
  SELECT products.id, products.name, products.sku, products.buyback_price, products.resale_value
  INTO v_product_id, v_product_name, v_product_sku, v_buyback_price, v_resale_value
  FROM public.products
  JOIN public.inventory ON products.id = inventory.product_id
  WHERE products.rarity = v_rarity
    AND inventory.quantity_available > 0
  ORDER BY random()
  LIMIT 1;

  -- Fallback if no product found
  IF v_product_id IS NULL THEN
    SELECT products.id, products.name, products.sku, products.rarity, products.buyback_price, products.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products
    JOIN public.inventory ON products.id = inventory.product_id
    WHERE inventory.quantity_available > 0
    ORDER BY random()
    LIMIT 1;
  END IF;

  -- Out of stock check
  IF v_product_id IS NULL THEN
    RETURN QUERY SELECT false, 'Out of stock', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  -- Deduct inventory (fully qualified to avoid ambiguity)
  UPDATE public.inventory
  SET quantity_available = inventory.quantity_available - 1
  WHERE inventory.product_id = v_product_id
    AND inventory.quantity_available > 0;

  -- Deduct balance
  UPDATE public.users
  SET account_balance = users.account_balance - v_box_price
  WHERE users.id = p_user_id
  RETURNING users.account_balance INTO v_new_balance;

  -- Record transaction
  INSERT INTO public.balance_transactions (user_id, amount, type, description)
  VALUES (p_user_id, -v_box_price, 'box_purchase', 'Mystery box opened');

  -- Add to user inventory (WITH SKU AND RARITY)
  INSERT INTO public.user_inventory (user_id, product_id, product_name, product_sku, rarity, buyback_price, status)
  VALUES (p_user_id, v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, 'kept')
  RETURNING id INTO v_inventory_item_id;

  -- Return success
  RETURN QUERY SELECT true, 'Success', v_product_id, v_product_name,
                      v_rarity, v_buyback_price, v_resale_value,
                      v_new_balance, v_inventory_item_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION open_mystery_box_with_exclusions(
  p_user_id UUID,
  p_excluded_ids UUID[] DEFAULT NULL
)
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
) AS $$
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
  -- Check balance
  SELECT users.account_balance INTO v_user_balance
  FROM public.users
  WHERE users.id = p_user_id
  FOR UPDATE;

  IF v_user_balance < v_box_price THEN
    RETURN QUERY SELECT false, 'Insufficient balance', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  -- Roll rarity
  v_rand := random();
  IF v_rand < 0.01 THEN
    v_rarity := 'ultra';
  ELSIF v_rand < 0.10 THEN
    v_rarity := 'rare';
  ELSIF v_rand < 0.40 THEN
    v_rarity := 'uncommon';
  ELSE
    v_rarity := 'common';
  END IF;

  -- Select product with exclusions (fully qualified)
  SELECT products.id, products.name, products.sku, products.buyback_price, products.resale_value
  INTO v_product_id, v_product_name, v_product_sku, v_buyback_price, v_resale_value
  FROM public.products
  JOIN public.inventory ON products.id = inventory.product_id
  WHERE products.rarity = v_rarity
    AND inventory.quantity_available > 0
    AND (p_excluded_ids IS NULL OR products.id != ALL(p_excluded_ids))
  ORDER BY random()
  LIMIT 1;

  -- Fallback 1
  IF v_product_id IS NULL THEN
    SELECT products.id, products.name, products.sku, products.rarity, products.buyback_price, products.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products
    JOIN public.inventory ON products.id = inventory.product_id
    WHERE inventory.quantity_available > 0
      AND (p_excluded_ids IS NULL OR products.id != ALL(p_excluded_ids))
    ORDER BY random()
    LIMIT 1;
  END IF;

  -- Fallback 2
  IF v_product_id IS NULL THEN
    SELECT products.id, products.name, products.sku, products.rarity, products.buyback_price, products.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products
    JOIN public.inventory ON products.id = inventory.product_id
    WHERE inventory.quantity_available > 0
    ORDER BY random()
    LIMIT 1;
  END IF;

  -- Out of stock check
  IF v_product_id IS NULL THEN
    RETURN QUERY SELECT false, 'Out of stock', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  -- Deduct inventory (fully qualified)
  UPDATE public.inventory
  SET quantity_available = inventory.quantity_available - 1
  WHERE inventory.product_id = v_product_id
    AND inventory.quantity_available > 0;

  -- Deduct balance
  UPDATE public.users
  SET account_balance = users.account_balance - v_box_price
  WHERE users.id = p_user_id
  RETURNING users.account_balance INTO v_new_balance;

  -- Record transaction
  INSERT INTO public.balance_transactions (user_id, amount, type, description)
  VALUES (p_user_id, -v_box_price, 'box_purchase', 'Mystery box opened');

  -- Add to user inventory (WITH SKU AND RARITY)
  INSERT INTO public.user_inventory (user_id, product_id, product_name, product_sku, rarity, buyback_price, status)
  VALUES (p_user_id, v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, 'kept')
  RETURNING id INTO v_inventory_item_id;

  -- Return success
  RETURN QUERY SELECT true, 'Success', v_product_id, v_product_name,
                      v_rarity, v_buyback_price, v_resale_value,
                      v_new_balance, v_inventory_item_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ============================================================
-- DONE - Every single column reference is now fully qualified
-- ============================================================
