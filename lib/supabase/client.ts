import { createBrowserClient } from "@supabase/ssr";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || "https://tymnlkwwkwbmollyecxv.supabase.co";
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5bW5sa3d3a3dibW9sbHllY3h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyOTIyMTgsImV4cCI6MjA4Njg2ODIxOH0.oqHjxGvSP-iQn2_seQfCiHdsCQeWeDo1ti37mveBZN4";

export function createClient() {
  return createBrowserClient(SUPABASE_URL, SUPABASE_ANON_KEY);
}
