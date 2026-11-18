import { createClient } from "@supabase/supabase-js";

const url = (import.meta.env.VITE_SUPABASE_URL || "").trim();
const browserKey = (
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ||
  import.meta.env.VITE_SUPABASE_ANON_KEY ||
  ""
).trim();

// The Vite env variables are compiled into the browser bundle, so NEVER
// use an sb_secret_* or legacy service_role key in these variables.
export const supabaseConfigured = /^https:\/\/[^\s/]+\.supabase\.co\/?$/.test(url) && Boolean(browserKey) &&
  !browserKey.startsWith("sb_secret_");

export const supabase = supabaseConfigured
  ? createClient(url.replace(/\/$/, ""), browserKey, {
      auth: {
        flowType: "pkce",
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: true,
        storageKey: "opportunitylens.auth",
      },
    })
  : null;
