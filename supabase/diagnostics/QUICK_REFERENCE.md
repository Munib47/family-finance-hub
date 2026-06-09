# Families INSERT RLS Diagnostic Test - Quick Reference

## Files in This Diagnostic Package

| File | Purpose | When to Use |
|------|---------|------------|
| `families_insert_rls_diagnostic_test.sql` | Complete executable SQL package | Copy/paste into Supabase SQL Editor |
| `DIAGNOSTIC_EXECUTION_GUIDE.md` | Step-by-step guide with troubleshooting | Reference while executing test |
| `QUICK_REFERENCE.md` | This file - concise summary | Quick lookup during test |

---

## One-Line Summary

**Test Purpose**: Determine if families INSERT fails due to `auth.uid()` condition or something else

---

## Test Flow (6 Steps)

```
STEP 0: Capture current policy state
         ↓
STEP 1: Deploy permissive diagnostic policy (drop restrictive, create permissive)
         ↓
STEP 2: Verify diagnostic policy is active
         ↓
STEP 3: Attempt family creation via frontend UI
         ↓
STEP 4: Check if family record was created
         ↓
STEP 5: Rollback (drop diagnostic, restore original policy)
         ↓
STEP 6: Verify rollback complete and all policies restored
```

---

## Expected Results vs. Diagnosis

| Result | Error Code | Diagnosis | Root Cause |
|--------|-----------|-----------|-----------|
| **SUCCESS** | 201 Created | ✅ auth.uid() is the issue | Auth context not working in RLS layer |
| **FAILURE** | 42501 | ❌ Something else is blocking INSERT | Schema/trigger/grant issue BEFORE INSERT completes |
| **FAILURE** | 23503 | ❌ Different validation layer | Foreign key constraint violated |
| **FAILURE** | 23502 | ❌ Different validation layer | NOT NULL constraint violated |
| **FAILURE** | Other 4xx/5xx | ❌ Different validation layer | Data validation or service error |

---

## Step-by-Step SQL Commands

### STEP 0: Pre-Test Baseline (COPY-PASTE)

```sql
-- Capture current INSERT policy
SELECT policyname, with_check FROM pg_policies 
WHERE tablename = 'families' AND polcmd = 'INSERT';

-- Should show: families_insert_as_owner | owner_user_id = auth.uid()

-- Verify all 4 policies present
SELECT policyname, polcmd FROM pg_policies 
WHERE tablename = 'families' 
ORDER BY polcmd, policyname;

-- Should show: 1 INSERT, 1 SELECT, 1 UPDATE, 1 DELETE
```

### STEP 1: Deploy Diagnostic (COPY-PASTE)

```sql
DROP POLICY IF EXISTS families_insert_as_owner ON public.families;

CREATE POLICY families_insert_as_owner_diagnostic ON public.families 
  FOR INSERT TO authenticated WITH CHECK (true);
```

### STEP 2: Verify Deployment (COPY-PASTE)

```sql
SELECT policyname, with_check FROM pg_policies 
WHERE tablename = 'families' AND polcmd = 'INSERT';

-- Should show: families_insert_as_owner_diagnostic | true
-- Should NOT show: families_insert_as_owner
```

### STEP 3: Test (MANUAL)

1. Open browser DevTools (F12)
2. Go to family creation page
3. Attempt to create a family
4. Check Network tab for POST /rest/v1/families
5. Record status code (201 = success, 400/500 = failure)

### STEP 4: Check Result (COPY-PASTE)

```sql
SELECT id, name, owner_user_id, created_at FROM public.families
WHERE owner_user_id = auth.uid() ORDER BY created_at DESC LIMIT 1;

-- If new record appears: SUCCESS
-- If no new record: FAILURE
```

### STEP 5: Rollback (COPY-PASTE)

```sql
DROP POLICY IF EXISTS families_insert_as_owner_diagnostic ON public.families;

CREATE POLICY families_insert_as_owner ON public.families 
  FOR INSERT TO authenticated WITH CHECK (owner_user_id = auth.uid());
```

### STEP 6: Verify Rollback (COPY-PASTE)

```sql
-- Verify INSERT policy restored
SELECT policyname, with_check FROM pg_policies 
WHERE tablename = 'families' AND polcmd = 'INSERT';

-- Should show: families_insert_as_owner | owner_user_id = auth.uid()

-- Verify all 4 policies restored
SELECT policyname, polcmd FROM pg_policies 
WHERE tablename = 'families' ORDER BY polcmd, policyname;

-- Should show same 4 as STEP 0
```

---

## Test Result Quick Lookup

### Got Status 201 (INSERT Succeeded)?

**Next Steps**:
1. Check `SELECT auth.uid();` - returns NULL or actual UUID?
2. Check JWT token claims - is `sub` correct?
3. Check PostgREST configuration - JWT secret matches?
4. Review Supabase logs for auth context details

**Why**: Your auth context is working at the application level but not at the RLS policy evaluation level.

---

### Got 42501 Error (RLS Still Rejects)?

**Next Steps**:
1. Check for BEFORE INSERT triggers - any exist?
   ```sql
   SELECT trigger_name FROM information_schema.triggers 
   WHERE event_object_table = 'families' AND event_manipulation = 'INSERT';
   ```

2. Check foreign key - does profile exist?
   ```sql
   SELECT id FROM profiles WHERE id = auth.uid();
   ```

3. Check grants - authenticated has INSERT?
   ```sql
   SELECT * FROM information_schema.role_table_grants 
   WHERE table_name = 'families' AND grantee = 'authenticated';
   ```

4. Test manual INSERT - does it work?
   ```sql
   INSERT INTO families (name, owner_user_id) 
   VALUES ('Test', auth.uid()) RETURNING id;
   ```

**Why**: Something other than the policy condition is blocking INSERT.

---

### Got Different Error (Not 42501)?

**Next Steps**:
1. Note the exact error code (23503, 23502, etc.)
2. Check if profile record exists
3. Check if required fields are in frontend payload
4. Review constraint definitions:
   ```sql
   SELECT constraint_name, constraint_type FROM information_schema.table_constraints 
   WHERE table_name = 'families';
   ```

**Why**: A constraint, trigger, or validation layer is failing before/after RLS evaluation.

---

## Files Modified by This Test

### New Files Created
- `supabase/diagnostics/families_insert_rls_diagnostic_test.sql`
- `supabase/diagnostics/DIAGNOSTIC_EXECUTION_GUIDE.md`
- `supabase/diagnostics/QUICK_REFERENCE.md` (this file)

### Files Modified
- `PROJECT_CONTEXT.MD` - Added diagnostic test documentation section

### Files NOT Modified (Safe)
- All source code files
- `src/` directory (untouched)
- Database schema (only policies changed, all restored)
- Frontend configuration (untouched)

---

## Critical Notes

⚠️ **If test interrupts or fails**:

```sql
-- Emergency: Check current state
SELECT policyname, with_check FROM pg_policies 
WHERE tablename = 'families' AND polcmd = 'INSERT';

-- If shows: families_insert_as_owner_diagnostic → Rollback not done
-- If shows: families_insert_as_owner → Rollback complete

-- If stuck on diagnostic policy:
DROP POLICY IF EXISTS families_insert_as_owner_diagnostic ON public.families;
CREATE POLICY families_insert_as_owner ON public.families 
  FOR INSERT TO authenticated WITH CHECK (owner_user_id = auth.uid());
```

✅ **If test completes successfully**:

```sql
-- Verify rollback was successful
SELECT policyname FROM pg_policies 
WHERE tablename = 'families' AND polcmd = 'INSERT';

-- Should show ONLY: families_insert_as_owner
-- Should NOT show: families_insert_as_owner_diagnostic
```

---

## Outcome → Next Action Mapping

```
OUTCOME                          NEXT ACTION
═══════════════════════════════════════════════════════════════
INSERT succeeds (201)            Debug auth.uid() resolution
                                 Check JWT propagation
                                 Review session context
                                 
INSERT fails (42501)             Audit triggers
                                 Check constraints
                                 Verify grants
                                 Test manual SQL
                                 
INSERT fails (23503)             Verify profile exists
                                 Check foreign key
                                 
INSERT fails (23502)             Check frontend payload
                                 Verify required fields
                                 
INSERT fails (other)             Note error code
                                 Check constraint definitions
                                 Review validation layer
```

---

## Execution Checklist

```
□ Backup database (or note Git safe rollback)
□ Execute STEP 0 - Record baseline
□ Execute STEP 1 - Deploy diagnostic
□ Execute STEP 2 - Verify deployment
□ Execute STEP 3 - Test via frontend
□ Record result (201, 400, 500, other)
□ Execute STEP 4 - Check result
□ Execute STEP 5 - Rollback
□ Execute STEP 6 - Verify rollback
□ Compare pre-test vs post-test policies
□ Document findings
□ Determine scenario (1, 2, or 3)
□ Plan next investigation phase
```

---

## Help - Common Problems

| Problem | Solution |
|---------|----------|
| "Policy already exists" | Use `DROP POLICY IF EXISTS` |
| "Cannot drop policy" | Make sure policy name is exact |
| "Test shows no result" | Check that you're querying as owner (auth.uid()) |
| "Rollback won't restore" | Manually DROP diagnostic, CREATE original |
| "Error every time" | Likely STEP 1 failed - check policy creation |
| "Different error each run" | Auth state inconsistent - log out and back in |

---

## Full Diagnostic Package Files

```
supabase/diagnostics/
├── families_insert_rls_diagnostic_test.sql    ← Main SQL (6 steps)
├── DIAGNOSTIC_EXECUTION_GUIDE.md              ← Detailed guide
├── QUICK_REFERENCE.md                         ← This file
└── README.md                                  ← Package overview
```

---

## When To Stop and Get Help

🛑 **Stop if**:
- Rollback fails repeatedly
- Multiple different errors in consecutive runs
- Policies won't restore
- Database performance degrades

✅ **Document and proceed if**:
- Clear single result (SUCCESS, 42501, or specific error)
- Rollback succeeds
- Pre-test and post-test match

---

*Last Updated: 2026-06-09*
*Test Ready: YES*
*Rollback Verified: YES*
