// Run this to fix the database functions
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://tymnlkwwkwbmollyecxv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5bW5sa3d3a3dibW9sbHllY3h2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTI5MjIxOCwiZXhwIjoyMDg2ODY4MjE4fQ.Iu4BjsIzYD61P7q_ekN_7-HWDuzb7JLL5WN3f9nuI3o';

const supabase = createClient(supabaseUrl, supabaseKey);

async function fixFunctions() {
  console.log('Checking if products have SKUs...');

  const { data: products, error: checkError } = await supabase
    .from('products')
    .select('name, sku, rarity')
    .limit(5);

  if (checkError) {
    console.error('Error checking products:', checkError);
    return;
  }

  console.log('Sample products:', products);

  const missingSkus = products.filter(p => !p.sku);
  if (missingSkus.length > 0) {
    console.error('❌ Products are missing SKUs! This is the problem.');
    console.log('Missing SKUs on:', missingSkus);
    return;
  }

  console.log('✅ Products have SKUs');
  console.log('\nNow running the fix SQL...\n');

  const fixSQL = `
-- Force recreate the functions with SKU support
DROP FUNCTION IF EXISTS open_mystery_box(UUID);
DROP FUNCTION IF EXISTS open_mystery_box_with_exclusions(UUID, UUID[]);

-- Now recreate open_mystery_box WITH SKU
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
  SELECT account_balance INTO v_user_balance
  FROM public.users WHERE id = p_user_id FOR UPDATE;

  IF v_user_balance < v_box_price THEN
    RETURN QUERY SELECT false, 'Insufficient balance', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

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

  SELECT p.id, p.name, p.sku, p.buyback_price, p.resale_value
  INTO v_product_id, v_product_name, v_product_sku, v_buyback_price, v_resale_value
  FROM public.products p
  JOIN public.inventory i ON p.id = i.product_id
  WHERE p.rarity = v_rarity
    AND i.quantity_available > 0
  ORDER BY random()
  LIMIT 1;

  IF v_product_id IS NULL THEN
    SELECT p.id, p.name, p.sku, p.rarity, p.buyback_price, p.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products p
    JOIN public.inventory i ON p.id = i.product_id
    WHERE i.quantity_available > 0
    ORDER BY random()
    LIMIT 1;
  END IF;

  IF v_product_id IS NULL THEN
    RETURN QUERY SELECT false, 'Out of stock', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  UPDATE public.inventory
  SET quantity_available = quantity_available - 1
  WHERE product_id = v_product_id
    AND quantity_available > 0;

  UPDATE public.users
  SET account_balance = account_balance - v_box_price
  WHERE id = p_user_id
  RETURNING account_balance INTO v_new_balance;

  INSERT INTO public.balance_transactions (user_id, amount, type, description)
  VALUES (p_user_id, -v_box_price, 'box_purchase', 'Mystery box opened');

  INSERT INTO public.user_inventory (user_id, product_id, product_name, product_sku, buyback_price, status)
  VALUES (p_user_id, v_product_id, v_product_name, v_product_sku, v_buyback_price, 'kept')
  RETURNING id INTO v_inventory_item_id;

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
  SELECT account_balance INTO v_user_balance
  FROM public.users WHERE id = p_user_id FOR UPDATE;

  IF v_user_balance < v_box_price THEN
    RETURN QUERY SELECT false, 'Insufficient balance', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

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

  SELECT p.id, p.name, p.sku, p.buyback_price, p.resale_value
  INTO v_product_id, v_product_name, v_product_sku, v_buyback_price, v_resale_value
  FROM public.products p
  JOIN public.inventory i ON p.id = i.product_id
  WHERE p.rarity = v_rarity
    AND i.quantity_available > 0
    AND (p_excluded_ids IS NULL OR p.id != ALL(p_excluded_ids))
  ORDER BY random()
  LIMIT 1;

  IF v_product_id IS NULL THEN
    SELECT p.id, p.name, p.sku, p.rarity, p.buyback_price, p.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products p
    JOIN public.inventory i ON p.id = i.product_id
    WHERE i.quantity_available > 0
      AND (p_excluded_ids IS NULL OR p.id != ALL(p_excluded_ids))
    ORDER BY random()
    LIMIT 1;
  END IF;

  IF v_product_id IS NULL THEN
    SELECT p.id, p.name, p.sku, p.rarity, p.buyback_price, p.resale_value
    INTO v_product_id, v_product_name, v_product_sku, v_rarity, v_buyback_price, v_resale_value
    FROM public.products p
    JOIN public.inventory i ON p.id = i.product_id
    WHERE i.quantity_available > 0
    ORDER BY random()
    LIMIT 1;
  END IF;

  IF v_product_id IS NULL THEN
    RETURN QUERY SELECT false, 'Out of stock', NULL::UUID, NULL::TEXT,
                        NULL::rarity_tier, NULL::DECIMAL, NULL::DECIMAL,
                        v_user_balance, NULL::UUID;
    RETURN;
  END IF;

  UPDATE public.inventory AS inv
  SET quantity_available = inv.quantity_available - 1
  WHERE inv.product_id = v_product_id
    AND inv.quantity_available > 0;

  UPDATE public.users
  SET account_balance = account_balance - v_box_price
  WHERE id = p_user_id
  RETURNING account_balance INTO v_new_balance;

  INSERT INTO public.balance_transactions (user_id, amount, type, description)
  VALUES (p_user_id, -v_box_price, 'box_purchase', 'Mystery box opened');

  INSERT INTO public.user_inventory (user_id, product_id, product_name, product_sku, buyback_price, status)
  VALUES (p_user_id, v_product_id, v_product_name, v_product_sku, v_buyback_price, 'kept')
  RETURNING id INTO v_inventory_item_id;

  RETURN QUERY SELECT true, 'Success', v_product_id, v_product_name,
                      v_rarity, v_buyback_price, v_resale_value,
                      v_new_balance, v_inventory_item_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
  `;

  const { data, error } = await supabase.rpc('exec_sql', { sql: fixSQL }).catch(async () => {
    // exec_sql might not exist, try direct query
    return await supabase.from('_sql').insert({ query: fixSQL });
  }).catch(async () => {
    // Try using the PostgREST admin API
    const response = await fetch(`${supabaseUrl}/rest/v1/rpc/exec`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      },
      body: JSON.stringify({ query: fixSQL })
    });
    return { data: await response.json(), error: response.ok ? null : { message: 'Failed to execute' } };
  });

  if (error) {
    console.error('❌ Could not run SQL automatically. You need to run QUICK_FIX_RUN_THIS.sql manually in Supabase SQL Editor.');
    console.error('Error:', error);
    return;
  }

  console.log('✅ Database functions fixed!');
  console.log('Now test opening a box in your browser.');
}

fixFunctions();
