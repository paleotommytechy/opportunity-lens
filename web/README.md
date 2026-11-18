# OpportunityLens web preview — Supabase integration

React/Vite frontend at https://opportunity-lens-web.vercel.app.
The original Streamlit application is unchanged.

## Local development
1. From repository root, install Python dependencies and run `uvicorn api.index:app --reload`.
2. In `web/`, run `npm ci`, then `npm run dev`.
3. To test Supabase, copy `web/.env.example` to `web/.env.local` and set:
   - `VITE_SUPABASE_URL`: URL of the dedicated OpportunityLens Supabase project.
   - `VITE_SUPABASE_PUBLISHABLE_KEY`: browser publishable key (`sb_publishable_...`).
   - Legacy alternative: `VITE_SUPABASE_ANON_KEY` for an older project's anon JWT.
4. Run `npm run test` and `npm run build` before review.

**Never enter `sb_secret_...` or the legacy service_role key in a `VITE_*` value.**
Vite exposes `VITE_*` environment values to the browser by design. Auth sessions
are persisted by Supabase's client SDK; the Google AI Studio key remains memory-only.

## Vercel — existing project
1. Open Vercel > **opportunity-lens-web** > Settings > Environment Variables.
2. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` (preferred) or `VITE_SUPABASE_ANON_KEY`. Set the variables for Production, and Preview if using the branch deployment.
3. **Redeploy** after adding or editing the environment variables: Vite captures them at build time. A running build does not dynamically read new env vars.
4. On Supabase > Authentication > URL Configuration, set the Site URL to
   `https://opportunity-lens-web.vercel.app` and allow this redirect URL.
   Add any protected Vercel preview URL separately when testing previews.
5. Enable Auth > Providers > Email (Magic Links). Supabase's default email
   service is rate limited and may require SMTP for external users.

## Database prerequisites (not automatically applied)
The developer must generate and apply the migrations from
`database/sql/01_profiles.sql` through `04_notifications.sql` to
**a dedicated OpportunityLens project** as described in `database/README.md`.
At minimum, `public.profiles` must exist with its RLS policies and grants
for profile persistence; `public.opportunities` and `public.saved_opportunities`
are needed for verified discovery and bookmarks.

Auth and public database reads use the **browser publishable key** and the
signed-in user JWT. RLS prevents cross-user access. The frontend does not
require or store a Supabase secret key. Profile writes always include the
current signed-in user's id; arbitrary client-supplied ownership must never
be treated as authorization.

## Behavior
- Without Supabase config: current guest analyzer remains available.
- Configured but no session: email sign-in is available; guest analyzer still works.
- Signed in and migrations applied: save/restore academic profile and bookmark
  a verified published opportunity.
- Database migrations missing: show a visible diagnostic instead of claiming
  persistence is working.
- Discovery displays only published, verified records returned by the
  database. Nothing is fabricated. No live ingestion or automated email alerts.
- Checklists/analysis remain session-only until a separate persistence feature
  is implemented.

## Cinematic sign-in and sign-up (2026 redesign)

The authentication experience uses an original SVG dusk landscape (no external
images or copied artwork) and a single opaque-leaning frosted form panel.
The scholarship dashboard uses darker, mostly solid surfaces with less glass.

- `/` — full-page sign-in by default
- `/login` — email/password sign-in or existing-user email link
- `/signup` — create an email/password account
- `/reset-password` — password reset landing and new-password form
- `/app` — scholarship workspace with guest access
- `/app/profile` and `/app/analyze` — existing profile and analyzer views

Routes use the History API and existing Vercel SPA rewrites. Guest analysis
is still available, and Supabase session and RLS rules remain intact.

### Supabase Auth setup

1. Enable Email under Supabase Authentication > Providers.
2. Set Site URL to https://opportunity-lens-web.vercel.app.
3. Add these Redirect URLs in Authentication > URL Configuration:
   - https://opportunity-lens-web.vercel.app/login
   - https://opportunity-lens-web.vercel.app/reset-password
4. Ensure email confirmations, recovery emails and SMTP deliver correctly
   before inviting users to register.
5. Minimum client password length is six characters. Supabase's configured
   server-side password policy is authoritative.
6. Google/Apple are not displayed by default. Configure the OAuth provider
   and its secrets in Supabase first, then set VITE_GOOGLE_AUTH_ENABLED=true
   or VITE_APPLE_AUTH_ENABLED=true on the Vercel *web* project and redeploy.
7. Do not expose a Supabase service_role or sb_secret_* key in VITE_*.

### Verification and limitations

Frontend unit tests cover credential helpers and route modes. GitHub CI
also builds the React app and runs the original Python tests. Real account
creation, email delivery, password recovery, Google/Apple OAuth and cross-user
RLS need staged end-to-end tests with the configured Supabase project.

The uploaded inspiration images were used as mood-board guidance only.
No copied reference photographs, logos, or proprietary artwork are bundled.
