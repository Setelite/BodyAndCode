# Supabase Setup

1. Create a project in Supabase.
2. Open SQL Editor and run:
   - `ProjectFiles/supabase/001_initial_schema.sql`
   - `ProjectFiles/supabase/002_role_gender_segmentation.sql`
3. In Authentication settings, enable Email/Password.
4. In your app target build settings add:
   - `INFOPLIST_KEY_SUPABASE_URL = https://<your-project-ref>.supabase.co`
   - `INFOPLIST_KEY_SUPABASE_ANON_KEY = <your-anon-key>`
5. Rebuild the app.

After setup:
- Login/Register in app uses cloud auth.
- Coaches list loads from `coach_social_feed`.
- Users are segmented in DB by `role` and `gender` (`public.profiles`).
- If config is missing, app falls back to local mock data.
