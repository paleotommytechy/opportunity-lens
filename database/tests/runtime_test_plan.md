# Supabase staging authorization test plan

To be executed by Adebanke **on staging**, after applying the migration. The automated GitHub tests do not prove real PostgreSQL RLS behavior.

1. Create two distinct test users (A and B) using normal Supabase Auth sign-in. Use the publishable key and the users' respective JWTs, never a secret key for these tests.
2. As A, INSERT a `student_profiles` row with `user_id=A`. Confirm A can SELECT and UPDATE it. As B, SELECT A's row: expect no rows. Attempt B's UPDATE/DELETE of A's row: expect no mutation. Attempt A's INSERT with B's user_id: expect RLS rejection.
3. As A, INSERT a PRIVATE `opportunities` row. Confirm B and anonymous users cannot see it. Attempt A's UPDATE to `visibility=public` / `verified_at`: expect RLS rejection. Admin may publish a separate verified row through trusted SQL credentials; then both users and anonymous visitors may read it.
4. As B, try to create a bookmark, eligibility assessment or application referencing A's private opportunity UUID: expect RLS rejection. As A, same operation should succeed.
5. As A, create an application and checklist item. As B, try to insert a checklist item with A's `application_id` and B's own `user_id`: expect composite foreign-key rejection. B cannot read/update A's items.
6. As anonymous visitor, SELECT active `opportunity_sources` rows and published verified `opportunities`: allowed. Anonymous INSERT/UPDATE/DELETE on all seven tables should fail.
7. Delete A's test user in staging and verify user-owned rows cascade as expected. Do not perform this test in production.
8. Run `database/tests/verify_deployed_security.sql` in the Supabase SQL Editor and inspect findings with Supabase Security and Performance Advisors.

Before production: confirm Data API exposure/GRANT behavior, project Auth URL redirects, backups, and expected migration history. Log results in the review PR; do not commit any keys or personal student data.
