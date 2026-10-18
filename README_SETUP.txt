# OweNote Cloud Setup

## Files
- `owenote_cloud.html`: the cloud-connected website (Supabase Auth + database).
- `owenote_schema.sql`: creates the tables and per-user Row Level Security policies.

## Setup
1. In Supabase, open your project.
2. Open **SQL Editor** → **New query**, paste `owenote_schema.sql`, and run it.
3. Open **Project Settings → API** (the exact menu label may vary). Copy the **Project URL** and the **publishable key** (or legacy `anon` key).
4. Open `owenote_cloud.html` in a text editor and replace:
   - `YOUR_SUPABASE_PROJECT_URL`
   - `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY`
5. Save the file and open it in a browser. Internet access is required because the Supabase JavaScript library is loaded from a CDN.
6. In Supabase **Authentication → URL Configuration**, set your Site URL to the final hosted website URL. For local testing, use the appropriate local URL. Add your deployed URL to Redirect URLs if you use email confirmation/password reset.
7. In **Authentication → Providers → Email**, review whether email confirmation is enabled. If enabled, new users must verify their email before signing in.

## Security
- The HTML uses only the public publishable/anon key. This key is designed for browser use when Row Level Security is enabled.
- NEVER place the `service_role` key or database password in HTML, JavaScript, GitHub, or any public repository.
- The SQL enables Row Level Security and restricts records by `auth.uid()`.
- Keep the project database password private.
- Export JSON backups periodically.

## Existing local OweNote data
This cloud version does not automatically migrate records from the older localStorage-only website. Do not delete the old version or clear its browser storage until a migration/import feature is added and verified.

## Current MVP limitations
- Browser notifications are best-effort while the page is open; they are not reliable background push notifications when the browser is closed.
- WhatsApp messages are prefilled for manual review and sending.
- For production-grade background reminders, add a service worker plus a push service/backend and schedule due-date checks.
- Use HTTPS hosting for deployment and test signup, email verification, login, password reset, RLS, partial repayments, and export before relying on the app.
