-- ============================================================================
-- FAMILIES INSERT RLS DIAGNOSTIC TEST - COMPLETE SQL PACKAGE
-- ============================================================================
-- Purpose: Isolate the root cause of families INSERT 42501 failures
-- Test Date: 2026-06-09
-- Author: PostgreSQL Architect
-- ============================================================================
-- EXECUTION STEPS:
-- 1. Execute "STEP 0" queries to capture current state
-- 2. Execute "STEP 1" to deploy diagnostic policy
-- 3. Execute "STEP 2" to verify deployment
-- 4. Attempt family creation via frontend UI
-- 5. Execute "STEP 4" to check test result
-- 6. Execute "STEP 5" to rollback
-- 7. Execute "STEP 6" to verify rollback
-- ============================================================================

-- ============================================================================
-- STEP 0: CAPTURE CURRENT STATE (EXECUTE FIRST)
-- ============================================================================
-- Query 0A: Capture Current families INSERT Policy
-- Purpose: Document exact current policy before modifications
-- ============================================================================

SELECT 
  'PRE-TEST BASELINE - STEP 0A' as step,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles::text[] as policy_roles,
  qual as using_condition,
  with_check as check_condition,
  NOW()::text as captured_at
FROM pg_policies 
WHERE tablename = 'families' 
  AND polcmd = 'INSERT'
ORDER BY policyname;

-- Expected Output:
-- policyname: families_insert_as_owner
-- check_condition: owner_user_id = auth.uid()
-- ============================================================================

-- ============================================================================
-- STEP 0B: Verify All families Policies (Pre-Test Baseline)
-- Purpose: Establish baseline for all policies before test
-- ============================================================================

SELECT 
  'PRE-TEST BASELINE - STEP 0B' as step,
  policyname,
  CASE 
    WHEN polcmd = 'INSERT' THEN 'INSERT'
    WHEN polcmd = 'SELECT' THEN 'SELECT'
    WHEN polcmd = 'UPDATE' THEN 'UPDATE'
    WHEN polcmd = 'DELETE' THEN 'DELETE'
    ELSE polcmd::text
  END as event_type,
  permissive,
  roles::text[] as policy_roles,
  CASE WHEN qual IS NOT NULL THEN 'HAS USING' ELSE 'NO USING' END as has_using,
  CASE WHEN with_check IS NOT NULL THEN 'HAS WITH_CHECK' ELSE 'NO WITH_CHECK' END as has_with_check,
  NOW()::text as captured_at
FROM pg_policies 
WHERE tablename = 'families' 
ORDER BY 
  CASE 
    WHEN polcmd = 'INSERT' THEN 1
    WHEN polcmd = 'SELECT' THEN 2
    WHEN polcmd = 'UPDATE' THEN 3
    WHEN polcmd = 'DELETE' THEN 4
    ELSE 5
  END,
  policyname;

-- Expected Output (must have exactly these 4 policies):
-- 1. families_insert_as_owner (INSERT, HAS_WITH_CHECK: owner_user_id = auth.uid())
-- 2. families_select_active_members (SELECT, HAS USING)
-- 3. families_update_owner (UPDATE, HAS USING + HAS WITH_CHECK)
-- 4. families_delete_owner (DELETE, HAS USING)

-- ============================================================================
-- STEP 1: DEPLOY DIAGNOSTIC POLICY
-- ============================================================================
-- Step 1A: Drop the existing restrictive INSERT policy
-- ============================================================================

-- EXECUTE THIS BLOCK ONLY AFTER RECORDING STEP 0 OUTPUTS

DROP POLICY IF EXISTS families_insert_as_owner ON public.families;

-- ============================================================================
-- Step 1B: Create temporary permissive diagnostic policy
-- ============================================================================

CREATE POLICY families_insert_as_owner_diagnostic ON public.families 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (true);

-- ============================================================================
-- STEP 2: VERIFY DIAGNOSTIC POLICY DEPLOYMENT
-- ============================================================================
-- Purpose: Confirm diagnostic policy replaced original policy
-- ============================================================================

SELECT 
  'POST-DEPLOY VERIFICATION - STEP 2' as step,
  policyname,
  CASE 
    WHEN polcmd = 'INSERT' THEN 'INSERT'
    WHEN polcmd = 'SELECT' THEN 'SELECT'
    WHEN polcmd = 'UPDATE' THEN 'UPDATE'
    WHEN polcmd = 'DELETE' THEN 'DELETE'
    ELSE polcmd::text
  END as event_type,
  permissive,
  roles::text[] as policy_roles,
  qual as using_condition,
  with_check as check_condition,
  NOW()::text as verified_at
FROM pg_policies 
WHERE tablename = 'families' 
  AND polcmd = 'INSERT'
ORDER BY policyname;

-- Expected Output:
-- policyname: families_insert_as_owner_diagnostic
-- check_condition: true
-- Original families_insert_as_owner should be ABSENT

-- ============================================================================
-- STEP 3: TEST INSERT VIA FRONTEND
-- ============================================================================
-- MANUAL STEP: Attempt to create a family via the frontend UI
-- Monitor Network tab in browser DevTools for POST /rest/v1/families
-- Record: status code, response body, error (if present)
-- ============================================================================

-- (No SQL for this step - use frontend UI and browser DevTools)

-- ============================================================================
-- STEP 4: CHECK TEST RESULT
-- ============================================================================
-- Purpose: Verify whether INSERT succeeded or failed
-- Execute AFTER frontend test attempt
-- ============================================================================

SELECT 
  'TEST RESULT CHECK - STEP 4' as step,
  id,
  name,
  owner_user_id,
  default_currency,
  status,
  created_at,
  updated_at
FROM public.families
WHERE owner_user_id = auth.uid()
ORDER BY created_at DESC
LIMIT 10;

-- If INSERT succeeded: You will see a new family record
-- If INSERT failed: Check Supabase dashboard to see if new record exists
-- If record exists = SUCCESS SCENARIO
-- If no new record = FAILURE SCENARIO (42501 or other error)

-- ============================================================================
-- STEP 5: ROLLBACK - DROP DIAGNOSTIC POLICY & RESTORE ORIGINAL
-- ============================================================================
-- EXECUTE ONLY AFTER STEP 4 TEST RESULT IS RECORDED
-- ============================================================================

-- Step 5A: Drop the diagnostic policy
DROP POLICY IF EXISTS families_insert_as_owner_diagnostic ON public.families;

-- Step 5B: Restore the original restrictive policy
CREATE POLICY families_insert_as_owner ON public.families 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (owner_user_id = auth.uid());

-- ============================================================================
-- STEP 6: VERIFY ROLLBACK COMPLETION
-- ============================================================================
-- Purpose: Confirm original policy is restored and other policies unchanged
-- ============================================================================

-- Query 6A: Verify INSERT Policy Restored
SELECT 
  'POST-ROLLBACK VERIFICATION - STEP 6A' as step,
  policyname,
  CASE 
    WHEN polcmd = 'INSERT' THEN 'INSERT'
    WHEN polcmd = 'SELECT' THEN 'SELECT'
    WHEN polcmd = 'UPDATE' THEN 'UPDATE'
    WHEN polcmd = 'DELETE' THEN 'DELETE'
    ELSE polcmd::text
  END as event_type,
  permissive,
  roles::text[] as policy_roles,
  qual as using_condition,
  with_check as check_condition,
  NOW()::text as verified_at
FROM pg_policies 
WHERE tablename = 'families' 
  AND polcmd = 'INSERT'
ORDER BY policyname;

-- Expected Output:
-- policyname: families_insert_as_owner
-- check_condition: owner_user_id = auth.uid()
-- Diagnostic policy should be ABSENT

-- ============================================================================
-- Query 6B: Verify All families Policies (Post-Test - Must Match PRE-TEST)
-- ============================================================================

SELECT 
  'POST-ROLLBACK VERIFICATION - STEP 6B' as step,
  policyname,
  CASE 
    WHEN polcmd = 'INSERT' THEN 'INSERT'
    WHEN polcmd = 'SELECT' THEN 'SELECT'
    WHEN polcmd = 'UPDATE' THEN 'UPDATE'
    WHEN polcmd = 'DELETE' THEN 'DELETE'
    ELSE polcmd::text
  END as event_type,
  permissive,
  roles::text[] as policy_roles,
  CASE WHEN qual IS NOT NULL THEN 'HAS USING' ELSE 'NO USING' END as has_using,
  CASE WHEN with_check IS NOT NULL THEN 'HAS WITH_CHECK' ELSE 'NO WITH_CHECK' END as has_with_check,
  NOW()::text as verified_at
FROM pg_policies 
WHERE tablename = 'families' 
ORDER BY 
  CASE 
    WHEN polcmd = 'INSERT' THEN 1
    WHEN polcmd = 'SELECT' THEN 2
    WHEN polcmd = 'UPDATE' THEN 3
    WHEN polcmd = 'DELETE' THEN 4
    ELSE 5
  END,
  policyname;

-- Expected Output (MUST MATCH STEP 0B OUTPUT):
-- 1. families_insert_as_owner (INSERT, HAS_WITH_CHECK: owner_user_id = auth.uid())
-- 2. families_select_active_members (SELECT, HAS USING)
-- 3. families_update_owner (UPDATE, HAS USING + HAS WITH_CHECK)
-- 4. families_delete_owner (DELETE, HAS USING)

-- ============================================================================
-- EXECUTION COMPLETE
-- ============================================================================
-- Test Results Summary:
-- - Original policy captured: [RECORD FROM STEP 0A]
-- - Diagnostic policy deployed: [CONFIRM STEP 2 SUCCESS]
-- - Frontend INSERT attempted: [RECORD RESULT FROM DEVTOOLS]
-- - Test result: [RECORD FROM STEP 4]
-- - Rollback completed: [CONFIRM STEP 6 SUCCESS]
-- 
-- Interpretation:
-- - If Step 4 shows NEW family record = SUCCESS (auth.uid() is the issue)
-- - If Step 4 shows NO new record = FAILURE (root cause elsewhere)
-- - If Step 4 shows different error = DIFFERENT ERROR (schema/grant issue)
-- 
-- ============================================================================
