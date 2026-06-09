# Families INSERT RLS Diagnostic Test - Execution Guide

## Quick Start

1. **Open**: `supabase/diagnostics/families_insert_rls_diagnostic_test.sql` in Supabase SQL Editor
2. **Execute Steps in Order**: 0 → 1 → 2 → Test → 4 → 5 → 6
3. **Record Results**: Fill in the test execution log below
4. **Interpret**: Match your result to the interpretation guide
5. **Next Steps**: Follow the appropriate scenario path

---

## What This Test Does

**Problem**: 
- Families INSERT fails with error code `42501` (row-level security policy violation)
- JWT and payload values are correct
- Profile and auth context appear valid

**Solution**:
- Temporarily replace the restrictive INSERT policy with a permissive one
- Determine if the failure is caused by `owner_user_id = auth.uid()` condition
- Isolate whether the root cause is auth context or something else

**Expected Outcome**:
- Learn the specific failure cause
- Plan next investigation or fix

---

## Test Execution Log

Fill this out as you execute each step:

```
TEST EXECUTION LOG
==================

Test Timestamp: _____________________ (ISO 8601, when you execute Step 0)

STEP 0: PRE-TEST CAPTURE
- Step 0A Query Status: [ ] EXECUTED, [ ] RECORDED
- Step 0A Output: 
  - Original INSERT Policy Name: _____________________
  - WITH CHECK Condition: _____________________
- Step 0B Query Status: [ ] EXECUTED, [ ] RECORDED
- Step 0B Output:
  - Total Policies Found: _____ (should be 4)
  - Policy Names: ___________________________________________________________
  - All SELECT/UPDATE/DELETE policies present: [ ] YES, [ ] NO

STEP 1: DEPLOY DIAGNOSTIC POLICY
- Step 1A (DROP): [ ] EXECUTED, [ ] NO ERRORS
- Step 1B (CREATE): [ ] EXECUTED, [ ] NO ERRORS
- Deployment Timestamp: _____________________

STEP 2: VERIFY DEPLOYMENT
- Query Status: [ ] EXECUTED, [ ] RECORDED
- Diagnostic Policy Name: families_insert_as_owner_diagnostic (confirm: [ ] YES)
- WITH CHECK Condition: true (confirm: [ ] YES)
- Original Policy Absent: (confirm: [ ] YES)

STEP 3: FRONTEND TEST
- Test Timestamp: _____________________
- Frontend Action: Attempted family creation via /family/setup
- Network Tab Response Status: _____ (e.g., 201, 400, 500)
- Error Code (if failed): _____ (e.g., 42501, 23503, 23502)
- Error Message: _________________________________________________________________
- Request Method/Endpoint: POST /rest/v1/families (confirm: [ ] YES)
- Authorization Header Present: [ ] YES, [ ] NO
- JWT Role: _____________________ (should be: authenticated)

STEP 4: TEST RESULT CHECK
- Query Status: [ ] EXECUTED, [ ] RECORDED
- New Family Records Found: [ ] YES (count: _____), [ ] NO
- Family Created By Test: [ ] YES, [ ] NO, [ ] UNCERTAIN
- Record Details (if created):
  - Family ID: _____________________
  - Family Name: _____________________
  - Owner User ID: _____________________
  - Status: _____________________
  - Created At: _____________________

TEST RESULT DETERMINATION
- INSERT Via Diagnostic Policy: [ ] SUCCESS, [ ] FAILURE
- Error Code (if failed): _____
- Error Message (if failed): _________________________________________________________________

STEP 5: ROLLBACK - DROP & RESTORE
- Step 5A (DROP): [ ] EXECUTED, [ ] NO ERRORS
- Step 5B (CREATE): [ ] EXECUTED, [ ] NO ERRORS
- Rollback Timestamp: _____________________

STEP 6: VERIFY ROLLBACK
- Step 6A Query Status: [ ] EXECUTED, [ ] RECORDED
- Original Policy Name: families_insert_as_owner (confirm: [ ] YES)
- WITH CHECK Condition: owner_user_id = auth.uid() (confirm: [ ] YES)
- Diagnostic Policy Absent: (confirm: [ ] YES)
- Step 6B Query Status: [ ] EXECUTED, [ ] RECORDED
- Total Policies Present: _____ (should be 4, matching Step 0B)
- Comparison to Pre-Test: [ ] IDENTICAL, [ ] DIFFERENT

TEST CONCLUSION
===============
Matching Scenario: [ ] SCENARIO 1 (SUCCESS), [ ] SCENARIO 2 (42501), [ ] SCENARIO 3 (OTHER ERROR)
Root Cause Category: [ ] Auth Context Issue, [ ] Schema/Grant Issue, [ ] Data Validation Issue
Next Action: ___________________________________________________________________
```

---

## Result Interpretation Matrix

### SCENARIO 1: INSERT Succeeded (Status 201)

**What You'll See**:
- Step 2: Diagnostic policy deployed successfully
- Step 3: Network tab shows 201 Created response
- Step 4: New family record visible in query results
- No error messages

**Root Cause**:
✅ **YES** - The failure IS caused by `owner_user_id = auth.uid()` condition

**Why**:
- Permissive diagnostic policy allowed INSERT
- Original restrictive policy was blocking INSERT
- Something about the auth.uid() evaluation is failing

**Specific Issue (one of these)**:
1. `auth.uid()` returns NULL during policy evaluation
2. `auth.uid()` returns different UUID than owner_user_id
3. JWT sub claim not propagated to policy context
4. PostgREST not setting Supabase session variables
5. Database role permissions preventing auth.uid() resolution

**Next Steps**:
```
PRIORITY: URGENT (Auth context broken)

1. Enable Supabase Auth Debug Logging
   - Supabase Dashboard → Settings → Logs
   - Filter for JWT/auth errors

2. Capture JWT Token
   - Browser DevTools → Network → POST /rest/v1/families
   - Copy Authorization header value
   - Decode JWT (jwt.io) and verify sub claim

3. Test auth.uid() Directly
   - Run in SQL Editor: SELECT auth.uid();
   - Must return your UUID
   - If NULL, auth context not initialized

4. Check JWT Propagation
   - Run in SQL Editor: SELECT current_user, session_user;
   - Should return 'authenticated'

5. Verify PostgREST Configuration
   - Check Supabase project settings
   - Verify JWT secret matches auth provider
   - Check API URL is correct

6. Review PostgreSQL Logs
   - Supabase Dashboard → Logs → Database
   - Search for families INSERT failures
   - Look for auth context clues
```

---

### SCENARIO 2: INSERT Failed with 42501 (RLS Rejection)

**What You'll See**:
- Step 2: Diagnostic policy deployed successfully
- Step 3: Network tab shows 400 Bad Request
- Step 3: Error code 42501 in response
- Step 4: NO new family record in query results
- Error: "new row violates row-level security policy"

**Root Cause**:
❌ **NO** - The failure is NOT caused by `owner_user_id = auth.uid()` condition

✅ **YES** - The failure IS caused by something else in the INSERT path

**Why**:
- Even with permissive policy, INSERT failed
- RLS evaluation happens, passes, but something else blocks INSERT
- Root cause is before or after RLS evaluation

**Specific Issue (one of these)**:
1. BEFORE INSERT trigger references auth functions and fails
2. DEFAULT value or generated column computation fails
3. Foreign key constraint validation fails
4. CHECK constraint validation fails
5. NOT NULL constraint violated
6. Missing or incorrect table/schema grants
7. Missing execute permission for auth helper functions
8. Database role cannot access profiles table (FK validation)

**Next Steps**:
```
PRIORITY: HIGH (Schema/constraint blocking INSERT)

1. Check for BEFORE INSERT Triggers
   SQL:
   SELECT trigger_name, action_statement, action_timing 
   FROM information_schema.triggers 
   WHERE event_object_table = 'families' 
     AND event_object_schema = 'public' 
     AND event_manipulation = 'INSERT';
   
   If triggers exist:
   - Review trigger logic
   - Look for auth.uid() or auth.jwt() references
   - Test trigger logic separately

2. Check DEFAULT Values and Generated Columns
   SQL:
   SELECT 
     column_name, 
     column_default, 
     is_generated, 
     generation_expression,
     data_type
   FROM information_schema.columns 
   WHERE table_name = 'families' 
     AND table_schema = 'public';
   
   If defaults exist:
   - Verify defaults don't reference auth functions
   - Test default values with test data

3. Test Manual INSERT in SQL Editor
   - Run: INSERT INTO families (name, owner_user_id, default_currency, status)
         VALUES ('Test', auth.uid(), 'USD', 'active');
   - Result: Success or specific error?
   - If succeeds: PostgREST/API layer issue
   - If fails: Database layer issue

4. Check Foreign Key on owner_user_id
   SQL:
   SELECT constraint_name, constraint_type 
   FROM information_schema.table_constraints 
   WHERE table_name = 'families' 
     AND table_schema = 'public';
   
   SQL:
   SELECT * FROM profiles WHERE id = auth.uid();
   
   - If profile doesn't exist: Create profile first
   - If exists: FK should be satisfied

5. Check Table and Role Grants
   SQL:
   SELECT * FROM information_schema.role_table_grants 
   WHERE table_name = 'families' 
     AND grantee = 'authenticated';
   
   Required grants:
   - INSERT privilege
   - SELECT privilege (for RLS checks)
   
   - If INSERT missing: GRANT INSERT ON public.families TO authenticated;
   - If SELECT missing: GRANT SELECT ON public.families TO authenticated;

6. Check Schema Grants
   SQL:
   SELECT * FROM information_schema.role_usage_grants 
   WHERE grantee = 'authenticated' 
     AND object_schema = 'public';
   
   - USAGE privilege on public schema required

7. Review PostgreSQL Logs
   - Supabase Dashboard → Logs → Database
   - Search for exact families INSERT timestamp
   - Look for constraint/trigger error details
```

---

### SCENARIO 3: INSERT Failed with Different Error (NOT 42501)

**What You'll See**:
- Step 2: Diagnostic policy deployed successfully
- Step 3: Network tab shows 400 or 500 error
- Step 3: Error code is NOT 42501 (e.g., 23502, 23503, 23505, 42P02)
- Step 4: Result may vary depending on error

**Root Cause**:
✅ **YES** - RLS is NOT the issue (policy evaluated, passed, then failed)

✅ **YES** - Auth context IS working (policy evaluated correctly)

❌ **NO** - Database schema or data validation IS the issue

**Error Code Reference**:

**23502: NOT NULL Constraint Violation**
- Missing required column value
- Check: owner_user_id, name, default_currency all provided
- Solution: Frontend payload must include all required fields

**23503: Foreign Key Constraint Violation**
- owner_user_id doesn't reference valid profile
- Solution: Ensure profile exists with same UUID

**23505: Unique Constraint Violation**
- Duplicate value in unique column
- Solution: Check if family name or other unique column already used

**23514: CHECK Constraint Violation**
- Value violates CHECK constraint (e.g., fiscal_month_start_day = 1-31)
- Solution: Check column constraints and provide valid values

**42P02: Insufficient Privilege**
- Authenticated role lacks permission for specific column/function
- Solution: Review grants on profiles table and related functions

**42P01: Table/Column Does Not Exist**
- Frontend referring to wrong table/column name
- Solution: Verify table schema vs frontend code

**Other 4xx/5xx**:
- Supabase service error
- Solution: Check Supabase status, review dashboard logs

**Next Steps**:
```
PRIORITY: MEDIUM (Data validation or constraint issue)

1. Record Exact Error Code
   - Note the specific error code: _____
   - Note the full error message: _____

2. Check Table Constraints
   SQL:
   SELECT 
     constraint_name, 
     constraint_type,
     check_clause
   FROM information_schema.table_constraints 
   WHERE table_name = 'families' 
     AND table_schema = 'public';

3. Verify Frontend Payload
   - Browser DevTools → Network → POST /rest/v1/families
   - Check request body
   - Verify all required fields present:
     * name (required, text, 2-100 chars)
     * owner_user_id (required, UUID matching auth.uid())
     * default_currency (optional, default USD)
     * fiscal_month_start_day (optional, default 1)
     * status (optional, default 'active')

4. Test Manual INSERT in SQL Editor
   SQL:
   INSERT INTO families (name, owner_user_id, default_currency, status)
   VALUES ('Test Family', auth.uid(), 'USD', 'active')
   RETURNING *;
   
   - If succeeds: API/PostgREST issue
   - If fails: Database layer issue with same error

5. Verify Profile Exists
   SQL:
   SELECT id, display_name, email FROM profiles 
   WHERE id = auth.uid();
   
   - If no result: Profile doesn't exist (23503 FK error)
   - Create profile before creating family

6. Review Supabase PostgreSQL Logs
   - Supabase Dashboard → Logs → Database
   - Filter by timestamp of your test
   - Look for detailed error message

7. Based on Error Code:
   - 23502: Ensure all fields provided in payload
   - 23503: Create profile with matching UUID first
   - 23505: Change family name to unique value
   - 23514: Adjust values to meet CHECK constraints
   - 42P02: Verify authentication and session setup
   - 42P01: Check for typos in column names
```

---

## Troubleshooting Common Issues

### "Cannot drop non-existent policy"
- **Cause**: families_insert_as_owner already deleted or renamed
- **Fix**: Skip DROP, go directly to CREATE diagnostic policy
- **Prevention**: Record Step 0 output before making changes

### "Duplicate policy name"
- **Cause**: Diagnostic policy not dropped before re-running test
- **Fix**: Drop families_insert_as_owner_diagnostic manually first
- **SQL**: `DROP POLICY IF EXISTS families_insert_as_owner_diagnostic ON public.families;`

### "Cannot restore original policy - already exists"
- **Cause**: Rollback interrupted, policy already restored
- **Fix**: Skip Step 5B CREATE, verify with Step 6 query
- **Prevention**: Complete rollback without interruption

### "Test shows different error each time"
- **Cause**: Multiple issues present or inconsistent auth state
- **Fix**: Run test multiple times, record all results
- **Pattern**: If error changes, likely race condition or auth cache issue

### "No family record after successful INSERT"
- **Cause**: RLS SELECT policy preventing visibility
- **Fix**: Test with profile user, not owner
- **Prevention**: Use Step 4 query as owner (auth.uid())

### "Query hangs or times out"
- **Cause**: Lock contention or auth context blocking
- **Fix**: Cancel query (Ctrl+C), try again
- **Prevention**: Ensure no concurrent writes to families table

---

## Important Notes

⚠️ **Do NOT**:
- Modify SELECT, UPDATE, or DELETE policies
- Create new policies or functions
- Change frontend code
- Modify database schema
- Run test without recording pre-test state
- Skip Step 0 (baseline capture)
- Execute Steps out of order

✅ **DO**:
- Record all outputs at each step
- Compare pre-test and post-test states
- Save this log for reference
- Execute rollback even if test fails
- Verify rollback completion with Step 6
- Document findings in session memory

---

## Test Result Summary Template

```
TEST RESULT SUMMARY
===================

Test Date: _____________________
Test Status: COMPLETED

Scenario Matched: [ ] Scenario 1 (SUCCESS), [ ] Scenario 2 (42501), [ ] Scenario 3 (OTHER)

Root Cause: _____________________________________________________________________

Test Finding: ___________________________________________________________________

Specific Issue Identified: _______________________________________________________

Next Investigation Phase: _______________________________________________________

Blocking Factor: ________________________________________________________________

Recommended Action: _____________________________________________________________

Expected Timeline: ______________________________________________________________

Dependencies: ___________________________________________________________________

Related Tickets/Issues: _________________________________________________________
```

---

## Questions?

- **Policy stuck?** Check Step 6 - If mismatch, manually restore
- **Auth context unclear?** Test `SELECT auth.uid()` in SQL Editor
- **Result confusing?** Review your specific scenario section above
- **Need help?** Document exact step and error, check troubleshooting section

Good luck! 🚀
