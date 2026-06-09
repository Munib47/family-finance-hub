# Reference Documents

Project Flow Diagram:

docs/app-flow/project-flow-v1.png

This diagram represents the approved UX flow and business requirements for:

- Authentication
- Expense Management
- Want To Buy
- Budget Management
- Money Distribution
- Permissions Management
- Notifications
- Theme Customization

Future AI sessions must use this diagram as a source of truth together with PROJECT_CONTEXT.md.

# PROJECT_CONTEXT.md

# Family Expense Management Application

## Project Overview

A mobile-first Family Expense Management Application built using:

* React 19
* Vite
* Tailwind CSS
* Supabase
* React Router DOM
* Context API

The application is designed for a small family group (maximum 10 users) where one Owner manages finances and permissions while other users can track expenses and create shopping requests.

The application must be mobile-first and desktop responsive.

---

# Business Requirements

The application contains two primary modules:

1. Expense Management
2. Want To Buy

After login, users see these two options and select one to continue.

Month selection is the primary navigation mechanism throughout the application.

---

# User Types

## Owner

Full system access.

Owner can:

* View all expenses
* View all spending
* Add budgets
* Add money distributions
* Manage users
* Grant permissions
* View notifications
* Customize themes
* View activity logs
* Manage Want To Buy items

Owner automatically receives all permissions.

---

## Regular User

Default user type.

Can:

* Create expenses
* Edit own expenses
* View own expenses
* Create Want To Buy items
* Edit own Want To Buy items
* View shared Want To Buy list

Has no elevated permissions.

---

## Authorized User

Regular user with individually assigned permissions.

Permissions are granted by Owner.

Authorized users can receive any combination of:

* add_budget
* view_total_spending
* add_money
* view_transactions
* view_notifications
* manage_users
* manage_want_to_buy
* customize_theme

---

# Permission System

Permissions are managed individually.

Owner Workflow:

Owner
-> Settings
-> Users
-> Select User
-> Permission Toggles

Permissions:

* add_budget
* view_total_spending
* add_money
* view_transactions
* view_notifications
* manage_users
* manage_want_to_buy
* customize_theme

Database Tables:

* permission_definitions
* member_permission_grants
* role_default_permissions

Owner receives all permissions automatically.

---

# Application Flow

## First-Time User Experience

New authenticated users must create a family before accessing the application.

Login
-> No Active Family
-> /family/setup
-> Create Family (Auto Owner)
-> Dashboard
-> Select Module

---

## Family Creation

When a new user logs in without an active family:

1. User is redirected to /family/setup
2. User enters family name (2-100 characters)
3. System creates:
   - families record (user becomes owner)
   - family_members record (owner role, active status)
4. Auth state refreshes (loads family, role, permissions)
5. User redirected to dashboard

Family Name Rules:

* Required
* Minimum 2 characters
* Maximum 100 characters
* One family per user (Phase 3)

Creator automatically becomes:

* Role: Owner
* Status: Active member
* Permissions: All permissions automatically granted

---

## Standard Application Flow (After Family Setup)

Login
-> Dashboard
-> Select Module

Option A:
Expense Management

Option B:
Want To Buy

---

# Expense Management Flow

Expense Management
-> Select Month
-> Expense List
-> Add / Edit Expense

Expense Fields:

* Title
* Amount
* Description
* Category
* Date
* Month

Each expense:

* Has edit option
* Has audit history
* Generates activity logs
* Creates notifications when updated

Users:

* See own expenses

Owner:

* Sees all family expenses

Users with view_transactions permission:

* Can view expense transactions

---

# Expense Update History

Requirement:

When a user edits an expense:

Old Value
-> New Value
-> Store History
-> Notify Owner

Database:

expense_updates

Stores:

* old_data
* new_data
* updated_by_user_id

---

# Want To Buy Flow

Want To Buy
-> Select Month
-> Item List

Each item contains:

* Item Name
* Quantity
* Completed Checkbox
* Edit
* Delete

Example:

Soap | Qty 5
Milk | Qty 2
Rice | Qty 1

All family members can view list.

Owner can manage all items.

Users can edit their own items.

---

# Budget Management

Owner can create monthly budgets.

Authorized users with add_budget permission can:

* Create budgets
* Update budgets

Everyone can view budgets.

Database:

monthly_budgets

Linked to:

months

---

# Month-Based Architecture

The application is month-centric.

Database Table:

months

Example:

* June 2026
* July 2026
* August 2026

Referenced by:

* expenses
* monthly_budgets
* want_to_buy_items

Month selection occurs before viewing module data.

---

# Money Distribution

Owner can distribute money.

Workflow:

Owner
-> Select User
-> Enter Amount
-> Enter Purpose
-> Save

Database:

* money_sources
* money_source_transactions
* money_distributions
* money_distribution_lines

Authorized users with add_money permission can also manage distributions.

---

# Notifications

System-generated notifications.

Examples:

* Expense Updated
* Budget Updated
* Permission Granted
* Money Distributed

Database:

notifications

Users:

* See own notifications only

Owner:

* Receives expense update notifications

---

# Activity Logs

Every important action is recorded.

Examples:

* Expense Created
* Expense Updated
* Budget Updated
* Permission Granted
* Permission Revoked
* Money Distributed

Database:

activity_logs

Activity logs are append-only.

---

# Theme Customization

Owner only.

Customizable:

* Background Color
* Text Color
* Button Color
* Primary Color
* Checkbox Color
* Delete Button Color

Changes affect Owner account only.

Database:

* family_theme_settings
* user_theme_overrides

---

# Database Status

Status:
Complete

Database implementation milestones:

* ✅ Supabase project created
* ✅ Database migration executed successfully
* ✅ All tables created
* ✅ Seed data inserted
* ✅ Indexes created
* ✅ RLS policies configured
* ✅ Functions created
* ✅ Triggers created
* ✅ Permissions system configured

Core Tables:

* profiles
* families
* family_members
* family_invitations
* expenses
* expense_updates
* expense_categories
* expense_attachments
* expense_tags
* expense_tag_map
* monthly_budgets
* budget_alerts
* months
* notifications
* notification_preferences
* permission_definitions
* member_permission_grants
* role_default_permissions
* money_sources
* money_source_transactions
* money_distributions
* money_distribution_lines
* activity_logs
* family_theme_settings
* user_theme_overrides
* want_to_buy_items

Database architecture is complete and must not be modified without approval.

---

# Security Architecture

Supabase RLS enabled.

Rules:

Owner:

* Full family access

Regular User:

* Own data only

Authorized User:

* Permission-based access

Protected Tables:

* expense_updates
* activity_logs
* notifications

Cannot be modified directly by users.

System functions perform writes.

---

# Authentication Requirements

Use Supabase Auth.

Required Features:

* Register
* Login
* Logout
* Forgot Password
* Session Persistence

After login:

1. Load Profile
2. Load Family Membership
3. Load Role
4. Load Permissions

---

# Recommended Frontend Structure

src/

components/
pages/
layouts/
contexts/
hooks/
routes/
services/
lib/
utils/
assets/

features/

auth/
dashboard/
expenses/
budgets/
want-to-buy/
notifications/
permissions/
settings/

---

# Current Folder Structure

Current repository structure:

* src/
* src/assets/
* src/assets/icons/
* src/assets/images/
* src/components/
* src/components/common/
* src/components/forms/
* src/components/layout/
* src/components/ui/
* src/constants/
* src/context/
* src/features/
* src/features/auth/
* src/features/auth/components/
* src/features/auth/context/
* src/features/auth/hooks/
* src/features/auth/routes/
* src/features/auth/services/
* src/hooks/
* src/layouts/
* src/lib/
* src/pages/
* src/pages/auth/
* src/pages/budget/
* src/pages/expenses/
* src/pages/notifications/
* src/pages/settings/
* src/pages/want-to-buy/
* src/routes/
* src/services/
* src/styles/
* src/utils/
* supabase/
* supabase/migrations/
* public/

Current implemented frontend files:

* src/main.jsx
* src/App.jsx
* src/index.css
* src/App.css
* src/lib/supabase.js
* src/routes/AppRoutes.jsx
* src/features/auth/index.js
* src/features/auth/components/AuthButton.jsx
* src/features/auth/components/AuthCard.jsx
* src/features/auth/components/AuthErrorState.jsx
* src/features/auth/components/AuthInput.jsx
* src/features/auth/components/AuthLayout.jsx
* src/features/auth/components/AuthLoadingScreen.jsx
* src/features/auth/context/AuthContext.jsx
* src/features/auth/hooks/useAuth.js
* src/features/auth/routes/ProtectedRoute.jsx
* src/features/auth/routes/PublicRoute.jsx
* src/features/auth/services/authBootstrapService.js
* src/features/auth/services/authService.js
* src/pages/auth/ForgotPassword.jsx
* src/pages/auth/Login.jsx
* src/pages/auth/Register.jsx

Current database file:

* supabase/migrations/migration_001_initial_schema.sql

Notes:

* Phase 1B authentication foundation is implemented.
* Phase 2 authentication UI implementation is complete.
* Current frontend structure includes the approved auth feature module.

---

# Repository Information

Repository status:

* ✅ Git initialized
* ✅ GitHub repository created
* ✅ Initial code pushed to GitHub
* Repository connected to GitHub
* Initial commit completed
* Safe rollback available through Git
* Future development should happen through commits per phase

Repository includes:

* React Vite application
* Supabase migration
* Project documentation
* AI development rules
* Environment-based Supabase connection

---

# Current Repository State

* Repository connected to GitHub
* Initial commit completed
* Safe rollback available through Git
* Future development should happen through commits per phase

---

# Infrastructure Status

Completed:

* ✅ React Vite project initialized
* ✅ Tailwind CSS installed
* ✅ React Router DOM installed
* ✅ Supabase project created
* ✅ Supabase connected to application
* ✅ Environment variables configured
* ✅ Database migration executed successfully
* ✅ PROJECT_CONTEXT.md created
* ✅ AI_DEVELOPMENT_RULES.md created
* ✅ Git initialized
* ✅ GitHub repository created
* ✅ Initial code pushed to GitHub

Application infrastructure:

* Vite configured through vite.config.js
* Tailwind CSS configured through @tailwindcss/vite
* Supabase client configured in src/lib/supabase.js
* React Router DOM configured in src/routes/AppRoutes.jsx
* Environment variables configured through .env

---

# Development Environment

Runtime and tooling:

* React 19
* Vite
* Tailwind CSS
* Supabase JavaScript client
* React Router DOM
* React Hook Form
* React Hot Toast

---

# # Development Roadmap

Phase 1
Authentication ✅

---

* AuthContext
* Login
* Register
* Protected Routes

Phase 2
Authentication UI ✅

* Auth Layout
* Auth Components

---

# Project Status

Project State:
Database Complete
Authentication UI Complete

Completed milestones:

* ✅ React Vite project initialized
* ✅ Tailwind CSS installed
* ✅ React Router DOM installed
* ✅ Supabase project created
* ✅ Supabase connected to application
* ✅ Environment variables configured
* ✅ Database migration executed successfully
* ✅ All tables created
* ✅ Seed data inserted
* ✅ RLS policies configured
* ✅ Functions created
* ✅ Triggers created
* ✅ Permissions system configured
* ✅ PROJECT_CONTEXT.md created
* ✅ AI_DEVELOPMENT_RULES.md created
* ✅ Git initialized
* ✅ GitHub repository created
* ✅ Initial code pushed to GitHub

* Phase 1A Authentication Architecture approved
* Phase 1B Authentication Foundation completed
* Phase 2 Authentication UI Implementation completed

Current module status:

Database:
Complete

Tables:
Complete

Indexes:
Complete

Functions:
Complete

Triggers:
Complete

Seed Data:
Complete

RLS:
Complete

Authentication:
UI Complete

Frontend:
Authentication Complete

Family Creation:
Complete

Dashboard:
Not Started

Expense Module:
Not Started

Want To Buy:
Not Started

Permissions UI:
Not Started

Notifications UI:
Not Started

Theme Settings UI:
Not Started

---

# Development Progress

Completed:

* Database Architecture
* Security Architecture
* Permissions Architecture
* Phase 1A Authentication Architecture
* Phase 1B Authentication Foundation
* Phase 2 Authentication UI Implementation
* Supabase Setup
* Supabase Client Connection
* Environment Configuration
* React Vite Setup
* Tailwind CSS Setup
* React Router DOM Setup
* Git Setup
* GitHub Repository Setup
* Initial Documentation

In Progress:

* Phase 4 - Dashboard

Not Started:

* Dashboard
* Expense Management UI
* Want To Buy UI
* Permissions UI
* Budget UI
* Money Distribution UI
* Notifications UI
* Theme Customization UI

---

# Current Frontend Status

Status:
Starting

Completed:

* React app entry point created
* Main App component created
* Basic route file created
* Supabase client hardened with auth persistence settings
* AuthContext created
* AuthProvider created
* useAuth hook created
* Auth bootstrap service created
* Auth service created
* Session persistence foundation implemented
* Auth state listener implemented
* Loading state management implemented
* Error state management implemented
* Profile loading implemented
* Family membership loading implemented
* Role loading implemented
* Permission loading implemented through existing has_permission RPC
* ProtectedRoute created
* PublicRoute created
* AuthLayout shared component created
* AuthCard shared component created
* AuthInput shared component created
* AuthButton shared component created
* Login page implemented with React Hook Form validation
* Register page implemented with React Hook Form validation
* Forgot Password page implemented with React Hook Form validation
* Authentication loading states implemented
* Authentication error states implemented
* Forgot Password success state implemented
* Auth pages implemented with mobile-first white UI matching approved flow
* Temporary protected dashboard placeholder created
* Supabase client file created
* Tailwind CSS imported

Current routes:

* / -> Login
* /login -> Login
* /register -> Register
* /forgot-password -> Forgot Password
* /dashboard -> Protected authentication-ready placeholder

Missing:

* User-facing logout placement outside temporary placeholder
* Family onboarding
* Production dashboard
* Module selection
* Month selector
* Expense pages
* Want To Buy pages
* Settings pages
* Permissions pages
* Notification pages
* Theme customization pages

---

# Current Development Phase

Current Phase:

Phase 4 - Dashboard

Status:
IN PROGRESS

Completed:

* Database Architecture
* Security Architecture
* Permissions Architecture
* Git Setup
* Phase 1A Authentication Architecture
* AuthContext
* AuthProvider
* useAuth
* ProtectedRoute
* PublicRoute
* Session Persistence Foundation
* Auth State Listener
* Loading State Management
* Error State Management
* Profile Loading
* Family Membership Loading
* Role Loading
* Permission Loading
* Login Form
* Register Form
* Forgot Password Form
* Auth Shared UI Components
* React Hook Form Validation
* Form Loading States
* Form Error States

Next:

* Phase 3 - Family Creation
* Create Family
* Become Owner
* Owner Membership Creation
* Family Setup Route
* Redirect authenticated users without active family to family setup

---

# # Next Development Phase

Next implementation target:

Phase 4 - Dashboard

Implementation Order:

1. Create production Dashboard page.
2. Replace the temporary authentication-ready placeholder screen.
3. Create Dashboard layout (mobile-first).
4. Display current family information.
5. Display current user role.
6. Add Month Selector component.
7. Add Module Selection cards:

   * Expense Management
   * Want To Buy
8. Create dashboard navigation structure.
9. Connect dashboard to existing AuthContext data.
10. Preserve existing database architecture and RLS policies.
11. Ensure owner, authorized user, and regular user visibility rules are respected.
12. Add loading and error states.
13. Maintain responsive mobile-first design.

Dashboard Requirements:

* Show active family name.
* Show current user role.
* Show month selector.
* Show Expense Management module card.
* Show Want To Buy module card.
* Support future expansion for:

  * Budgets
  * Money Distribution
  * Notifications
  * Permissions
  * Theme Settings

Database Changes:

* No database schema changes allowed.
* No RLS policy changes allowed.
* Use existing AuthContext and loaded membership data.

Completion Criteria:

* User logs in successfully.
* User is redirected to dashboard.
* Dashboard displays family information.
* Dashboard displays module selection.
* Dashboard supports month-based navigation.
* Temporary authentication-ready placeholder is removed.

Phase 3 - Family Creation Status:

✅ Complete

Verified:

* Family creation works.
* Owner membership creation works.
* Auth refresh works.
* Dashboard access works.
* RLS policies work correctly.
* User onboarding flow is complete.

---

# AI Collaboration Rules

1. Read PROJECT_CONTEXT.md before every task.
2. Read AI_DEVELOPMENT_RULES.md before implementation.
3. Never modify database schema without approval.
4. Never create new tables without approval.
5. Use existing Supabase tables only.
6. Use existing RLS policies only.
7. Build one phase at a time.
8. Do not generate the entire application at once.
9. Follow existing Supabase architecture.
10. Follow existing permissions system.
11. Follow existing RLS security model.
12. Keep Owner permissions separate from Authorized User permissions.
13. Mobile-first UI only.
14. Use SVG icons only.
15. Use React 19.
16. Use Vite.
17. Use Tailwind CSS.
18. Use Context API.
19. Use React Router DOM.
20. Use JavaScript / JSX unless TypeScript is installed later with approval.
21. All forms must include loading and error states.
22. Use reusable components.
23. Do not create code outside the requested scope.
24. Generate complete files, not partial snippets.
25. Follow existing folder structure.
26. Month selection must remain the primary navigation method.
27. All important actions must generate activity logs.
28. Expense edits must create history and notifications through existing database behavior.

---

# Important Development Rules

1. Do not modify database architecture without approval.

2. Keep mobile-first design.

3. Use SVG icons only.

4. Use Context API.

5. Use React Router DOM.

6. Use Supabase Auth.

7. Keep Owner permissions separate from Authorized User permissions.

8. Month selection must remain the primary navigation method.

9. All important actions must generate activity logs.

10. Expense edits must create history and notifications.

---

# Rules For Future AI Sessions

1. Read PROJECT_CONTEXT.md first.
2. Read AI_DEVELOPMENT_RULES.md second.
3. Never modify database schema without approval.
4. Never generate the entire application at once.
5. Build one phase at a time.
6. Follow existing Supabase architecture.
7. Follow existing permissions system.
8. Follow existing RLS security model.
9. Mobile-first UI only.
10. Use SVG icons only.

---

# Last Updated

Project State:
Database Complete
Authentication UI Complete
Family Creation Complete

Ready For:
Dashboard Implementation

---

# Phase 3 Family Creation Completion Report

## Completion Date

2026-06-09

## Status

✅ COMPLETE

---

## Problem Encountered

Family creation initially failed with:

```text
42501
new row violates row-level security policy for table "families"
```

and later:

```text
PGRST116
Cannot coerce the result to a single JSON object
```

---

## Root Cause Analysis

The issue was caused by a family bootstrap dependency:

```text
User creates family
↓
Application attempts to SELECT newly created family
↓
families SELECT policy requires active family membership
↓
family_members record does not exist yet
↓
SELECT returns 0 rows
↓
Owner membership creation never executes
```

This created a circular dependency between:

* families RLS policies
* family_members RLS policies
* Auth bootstrap flow

---

## Solution Implemented

A database RPC function was created:

```sql
public.create_family_with_owner_member(
  p_name text,
  p_owner_user_id uuid
)
```

Implementation:

```sql
SECURITY DEFINER
SET search_path = public
SET row_security = off
```

The RPC performs:

1. Create family
2. Create owner membership
3. Set base_role = owner
4. Set membership_status = active
5. Set joined_at = now()
6. Return family_id

---

## Frontend Changes

familyService.js was updated to:

* Call create_family_with_owner_member RPC
* Stop querying families immediately after insert
* Refresh AuthContext after success

FamilySetup.jsx remains responsible for:

* Collecting family name
* Calling createFamily()
* Refreshing auth state
* Redirecting to dashboard

---

## Verification Results

Verified Successfully:

✅ User registration

✅ Login

✅ Logout

✅ Session persistence

✅ Profile loading

✅ Family creation

✅ Owner membership creation

✅ Permission loading

✅ Family loading

✅ Dashboard access

✅ RLS compliance

---

## Current Auth Bootstrap Flow

Login
↓
Load Profile
↓
Load Family Membership
↓
Load Family
↓
Load Permissions
↓
Dashboard

---

## Current User State

Owner User:
Munib Ahmad

Family:
My Family - Home A51

Role:
owner

Membership Status:
active

Authentication:
working

Family Creation:
working

Dashboard Access:
working

---

## Recommended Cleanup

Before next phase:

* Remove debugging console logs
* Remove investigation code
* Keep RPC migration in repository
* Delete duplicate test family records
* Commit changes to GitHub

Suggested Commit:

fix: resolve family onboarding RLS bootstrap issue using RPC

---

## Next Development Phase

Phase 4 - Dashboard

Implementation Order:

1. Dashboard layout
2. Module selection
3. Expense Management card
4. Want To Buy card
5. Month selector
6. Dashboard navigation

Family onboarding is now complete.

---

## Step 3: Test INSERT on families Table

### Frontend Test: Attempt to Create a Family

**Purpose**: Execute the exact same INSERT that was failing, now with the diagnostic policy

**Steps**:
1. Open browser developer tools (F12)
2. Navigate to the family creation page
3. Attempt to create a family via the UI
4. Observe Network tab for the POST request to `/rest/v1/families`
5. Record the response status and body

**Expected Outcomes**:

**Outcome A (SUCCESS)**:
- Status: 201 Created
- Response body: Family record created with your owner_user_id
- Error: None

**Outcome B (FAILURE - 42501)**:
- Status: 400 Bad Request
- Error code: 42501
- Error message: "new row violates row-level security policy"

**Outcome C (FAILURE - OTHER)**:
- Status: 400 or 500
- Error code: Something other than 42501
- Error message: [Record exact message]

**Record**:
- Test timestamp
- Response status code
- Error code (if present)
- Error message (full text)
- Whether record was created (check Supabase dashboard)

---

## Step 4: Query Families Table (Check Test Result)

### Query: Verify If Family Was Created During Diagnostic Test

**Purpose**: Confirm whether INSERT succeeded or failed

**Execute in Supabase SQL Editor**:

```sql
-- ============================================================================
-- STEP 4: CHECK TEST RESULT
-- ============================================================================

SELECT 
  id,
  name,
  owner_user_id,
  default_currency,
  status,
  created_at
FROM public.families
ORDER BY created_at DESC
LIMIT 5;

-- If INSERT succeeded: You will see your family record
-- If INSERT failed: You will NOT see a new family record (or see existing ones only)
```

**Record Output**: Did a new family record appear?

---

## Step 5: Rollback - Restore Original Policy

### SQL: Drop Diagnostic Policy & Restore Original Policy

**Purpose**: Restore the system to its original state

**Execute in Supabase SQL Editor**:

```sql
-- ============================================================================
-- STEP 5: ROLLBACK - DROP DIAGNOSTIC POLICY
-- Timestamp: [INSERT CURRENT TIMESTAMP]
-- ============================================================================

-- Step 5A: Drop the diagnostic policy
DROP POLICY IF EXISTS families_insert_as_owner_diagnostic ON public.families;

-- Step 5B: Restore the original restrictive policy
CREATE POLICY families_insert_as_owner ON public.families 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (owner_user_id = auth.uid());

-- Confirmation message:
-- NOTICE: DROP POLICY completed
-- NOTICE: CREATE POLICY completed
```

**Expected Result**: Both commands complete without error

---

## Step 6: Verify Rollback Completion

### Query: Confirm Original INSERT Policy Is Restored

**Purpose**: Verify that the system has been restored to its original state

**Execute in Supabase SQL Editor**:

```sql
-- ============================================================================
-- STEP 6: VERIFY ROLLBACK COMPLETION
-- ============================================================================

SELECT 
  policyname,
  event_type,
  permissive,
  roles::text[] as policy_roles,
  qual as using_condition,
  with_check as check_condition
FROM pg_policies 
WHERE tablename = 'families' 
  AND event_type = 'INSERT'
ORDER BY policyname;

-- Expected Output (POST-ROLLBACK):
-- | policyname               | event_type | permissive | policy_roles | using_condition | check_condition         |
-- | families_insert_as_owner | INSERT     | true       | {authenticated} | (null)          | owner_user_id = auth.uid() |
```

**Record Output**: Verify that:
- `families_insert_as_owner` policy is PRESENT
- `families_insert_as_owner_diagnostic` policy is ABSENT
- `with_check` condition is `owner_user_id = auth.uid()`

---

### Query: Verify All families Policies Are Unchanged (POST-TEST)

**Purpose**: Confirm that SELECT, UPDATE, DELETE policies remain untouched

**Execute in Supabase SQL Editor**:

```sql
-- ============================================================================
-- VERIFY: All families Policies (Post-Test - Must Match Pre-Test)
-- ============================================================================

SELECT 
  policyname,
  event_type,
  permissive,
  roles::text[] as policy_roles,
  CASE 
    WHEN qual IS NOT NULL THEN 'HAS USING'
    ELSE 'NO USING'
  END as has_using,
  CASE 
    WHEN with_check IS NOT NULL THEN 'HAS WITH_CHECK'
    ELSE 'NO WITH_CHECK'
  END as has_with_check
FROM pg_policies 
WHERE tablename = 'families' 
ORDER BY event_type, policyname;

-- Expected Output (POST-ROLLBACK - MUST MATCH PRE-TEST):
-- | policyname                     | event_type | permissive | policy_roles      | has_using    | has_with_check  |
-- | families_insert_as_owner       | INSERT     | true       | {authenticated}   | NO USING     | HAS WITH_CHECK  |
-- | families_select_active_members | SELECT     | true       | {authenticated}   | HAS USING    | NO WITH_CHECK   |
-- | families_update_owner          | UPDATE     | true       | {authenticated}   | HAS USING    | HAS WITH_CHECK  |
-- | families_delete_owner          | DELETE     | true       | {authenticated}   | HAS USING    | NO WITH_CHECK   |
```

**Record Output**: Compare to PRE-TEST output. If identical, rollback is complete and successful.

---

## SCENARIO 2: INSERT Fails with 42501 (RLS Rejection)

**What Happened**:
- Family record was NOT created
- RLS policy rejected the INSERT
- Even with permissive `WITH CHECK (true)` policy, INSERT still failed

**Root Cause Diagnosis**:
✅ The failure is NOT caused by `owner_user_id = auth.uid()` condition

❌ The failure is NOT an auth context issue

**Specific Root Cause (one of)**:
1. An undiscovered BEFORE INSERT trigger that references auth.uid() or other auth functions is failing
2. A DEFAULT value or generated column is raising an error before RLS evaluation
3. A foreign key constraint is blocking the INSERT
4. A CHECK constraint is blocking the INSERT
5. Missing or incorrect database grants at table level
6. Missing or incorrect grants for `authenticated` role
7. A rewrite rule or view logic is interfering
8. PostgREST layer configuration is rejecting the request before database evaluation

**Next Steps**:
1. Check for BEFORE INSERT triggers on families table:
   ```sql
   SELECT trigger_name, action_statement FROM information_schema.triggers 
   WHERE event_object_table = 'families' AND event_object_schema = 'public' 
   AND event_manipulation = 'INSERT' AND action_timing = 'BEFORE';
   ```

2. Check for DEFAULT values or generated columns:
   ```sql
   SELECT column_name, column_default, is_generated, generation_expression 
   FROM information_schema.columns WHERE table_name = 'families';
   ```

3. Check table and schema ACLs:
   ```sql
   SELECT * FROM information_schema.role_table_grants 
   WHERE table_name = 'families' AND grantee = 'authenticated';
   ```

4. Test manual INSERT as authenticated user in SQL Editor
5. Check PostgREST error logs in Supabase dashboard
6. Review Supabase PostgreSQL logs for detailed error context

**Action Priority**: HIGH - Schema object or grant misconfiguration

---

## SCENARIO 3: INSERT Fails with Different Error (NOT 42501)

**What Happened**:
- Family record was NOT created
- RLS was bypassed by permissive policy
- A different error occurred (4xx, 5xx, or specific error code)

**Possible Error Codes**:
- `23502`: NOT NULL constraint violation
- `23503`: Foreign key constraint violation
- `23505`: Unique constraint violation
- `23514`: CHECK constraint violation
- `42P01`: Table/column does not exist
- `42883`: Function does not exist
- `42P02`: Insufficient privilege
- Other HTTP 5xx: Server/database error

**Root Cause Diagnosis**:
✅ RLS policy is not the issue

✅ Auth context is working (policy evaluated and passed)

❌ Database schema or data integrity issue

**Specific Root Cause (by error code)**:

### `23502` - NOT NULL Violation
- A required column is missing from INSERT payload
- Check: `owner_user_id`, `name`, `default_currency`, `status` all present

### `23503` - Foreign Key Violation
- `owner_user_id` does not reference a valid profile
- Solution: Ensure profile exists in profiles table

### `23505` - Unique Constraint Violation
- Duplicate value in unique column (unlikely for families, but possible if composite unique exists)
- Solution: Check constraint definitions

### `23514` - CHECK Constraint Violation
- A value violates a CHECK constraint
- Solution: Review constraints on table columns

### Other Errors
- Investigate specific error message and PostgreSQL logs

**Next Steps**:
1. Capture exact error code and message
2. Check PostgreSQL constraint definitions:
   ```sql
   SELECT constraint_name, constraint_type 
   FROM information_schema.table_constraints 
   WHERE table_name = 'families' AND table_schema = 'public';
   ```

3. Test manual INSERT with same payload in SQL Editor
4. Check Supabase PostgreSQL logs for detailed error
5. Verify all required fields are present in frontend payload
6. Verify foreign key references are valid

**Action Priority**: MEDIUM - Data validation issue, recoverable

---

# Current Known Issue

Status:
Open

Issue:

After successful authentication and family onboarding, users are shown the temporary authentication-ready placeholder instead of the production dashboard.

Current Screen Shows:

* User Name
* Family Name
* User Role
* Sign Out Button

Expected Behavior:

* Dashboard Layout
* Module Selection
  * Expense Management
  * Want To Buy
* Month Selector
* Navigation Structure

Root Cause:

Dashboard implementation has not yet been built.

Priority:
High

Target Phase:
Phase 4 - Dashboard