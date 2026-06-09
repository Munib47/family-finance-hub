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

# Debugging Session Notes

- Debugging session date: 2026-06-09
- RLS investigation summary:
  - Confirmed the `families` table uses a Supabase RLS INSERT policy requiring `owner_user_id = auth.uid()`.
  - Confirmed the authenticated role has `INSERT` privilege on `families`; policy is enforcing row ownership.
  - Identified the likely payload mismatch source between the frontend `owner_user_id` and the current session auth UID.
- Root cause findings:
  - `FamilySetup.jsx` passes `user.id` into `createFamily()`.
  - `familyService.createFamily()` inserts `owner_user_id` using that `user.id`.
  - When `owner_user_id !== auth.uid()` on the Supabase request, the insert is blocked by RLS and returns a 403.
- Next approved action:
  - Use the temporary debug logs in `AuthProvider`, `authBootstrapService`, `FamilySetup`, and `familyService` to capture exact runtime values.
  - Confirm if `session.user.id`, `user.id`, `profile.id`, and `owner_user_id` are identical at runtime.
  - After identifying the actual mismatch, adjust the flow or value source without changing RLS or schema.

* ESLint
* JavaScript / JSX

Available npm scripts:

* npm run dev
* npm run build
* npm run lint
* npm run preview

Environment variables:

* VITE_SUPABASE_URL
* VITE_SUPABASE_ANON_KEY

Development rules:

* Use JavaScript / JSX because TypeScript is not installed.
* Use mobile-first Tailwind CSS.
* Use Context API for app state.
* Use Supabase Auth for authentication.
* Use existing Supabase tables, functions, triggers, and RLS policies.
* Do not create or modify database schema unless explicitly approved.

---

# Current Blocker

- `families` INSERT is being rejected by RLS with `42501` despite the frontend payload and session values matching.

# Evidence Collected

- `session.user.id` matches `profile.id`.
- `session.user.id` matches the inserted `owner_user_id` payload.
- `families` table is empty and policy is `WITH CHECK (owner_user_id = auth.uid())`.
- The frontend performs the insert through `supabase.from("families").insert(...)`.
- Debug logs confirm the client has a session, but not whether the outgoing request includes `Authorization: Bearer <token>`.

# Investigation Performed

- Reviewed `src/lib/supabase.js` for Supabase client initialization.
- Reviewed `src/features/auth/context/AuthContext.jsx` for session restore and auth state bootstrapping.
- Reviewed `src/features/auth/services/authBootstrapService.js` for session-driven profile/membership load.
- Reviewed `src/features/auth/services/authService.js` for sign-in, sign-up, and current session retrieval.
- Reviewed `src/features/family/services/familyService.js` for the actual `families` insert and session verification before the request.

# Recommended Next Action

- Inspect the outgoing browser request in DevTools Network for `POST /rest/v1/families`.
- Confirm `Authorization: Bearer <jwt>` is present in the request headers.
- Verify the stored local session under `family-expense-auth` contains a valid `access_token` and `expires_at`.
- If the header is missing, the issue is JWT propagation / Supabase auth header attachment, not payload logic.
- If the header is present, capture the exact token and compare it to the current `session.access_token` and current authenticated user.

---

# # Development Roadmap

Phase 1
Authentication ✅

---

# Database Investigation Phase Round 2

- Confirmed findings from Round 1:
  - JWT Authorization header exists on `POST /rest/v1/families`.
  - JWT role is `authenticated` and sub matches `session.user.id`.
  - `owner_user_id` payload matches the authenticated user.
  - `families` INSERT policy is `WITH CHECK (owner_user_id = auth.uid())`.
  - `authenticated` has INSERT privilege and RLS is enabled.
- New hypothesis:
  - `auth.uid()` or related auth helper resolution may not be binding correctly in the database policy context.
  - Another policy or auth schema function may be interfering with the effective evaluation of `auth.uid()`.
  - The authenticated role mapping inside Postgres may differ from the JWT auth role.
- Investigation queries generated: see the SQL queries below.
- Next approved action:
  - Execute these SQL queries in Supabase SQL Editor to validate `auth.uid()`, `auth.role()`, `auth.jwt()`, and related auth helper functions.
  - Identify any auth schema objects or policy bindings that could cause the row-level security rejection.

## SQL Queries for Round 2 Investigation

1. Query Number: 1
   SQL Query:
   ```sql
   select n.nspname as schema_name, p.proname as function_name, p.prosrc as source, p.prosecdef as security_definer
   from pg_proc p
   join pg_namespace n on p.pronamespace = n.oid
   where n.nspname = 'auth'
   order by p.proname;
   ```
   What Success Looks Like: the `auth` schema exists and exposes auth helper functions such as `uid`, `role`, and `jwt`.
   What Failure Looks Like: the `auth` schema is missing, or expected auth helper functions are absent.
   Why It Matters: if the auth schema or its functions are missing, `auth.uid()` cannot resolve correctly.

2. Query Number: 2
   SQL Query:
   ```sql
   select n.nspname as schema_name, p.proname as function_name, p.prosrc as source, p.prosecdef as security_definer
   from pg_proc p
   join pg_namespace n on p.pronamespace = n.oid
   where p.proname in ('uid', 'role', 'jwt')
     and n.nspname = 'auth'
   order by p.proname;
   ```
   What Success Looks Like: functions `uid`, `role`, and `jwt` exist in schema `auth`.
   What Failure Looks Like: one or more of these functions is missing.
   Why It Matters: the policy depends on `auth.uid()` being a valid callable function.

3. Query Number: 3
   SQL Query:
   ```sql
   select p.oid, n.nspname as schema_name, p.proname as function_name, pg_get_functiondef(p.oid) as definition
   from pg_proc p
   join pg_namespace n on p.pronamespace = n.oid
   where p.proname in ('uid', 'role', 'jwt')
     and n.nspname = 'auth';
   ```
   What Success Looks Like: full definitions of auth helper functions are visible.
   What Failure Looks Like: function definitions are missing or unexpected.
   Why It Matters: verifies the exact implementation of auth helper functions.

4. Query Number: 4
   SQL Query:
   ```sql
   select polname,
          polcmd,
          polroles,
          pg_get_expr(polqual, polrelid) as using_expr,
          pg_get_expr(polwithcheck, polrelid) as with_check_expr
   from pg_policy
   where polrelid = 'public.families'::regclass
   order by polname;
   ```
   What Success Looks Like: expected `families_insert_as_owner` policy is present with `auth.uid()` in `with_check_expr`.
   What Failure Looks Like: missing or altered policy definitions, or additional policies affecting INSERT.
   Why It Matters: confirms the exact policy bound to `families` insert operations.

5. Query Number: 5
   SQL Query:
   ```sql
   select n.nspname as schema_name, p.proname as function_name, p.prosrc as source
   from pg_proc p
   join pg_namespace n on p.pronamespace = n.oid
   where p.prosrc ilike '%auth.uid()%' or p.prosrc ilike '%auth.jwt()%' or p.prosrc ilike '%auth.role()%'
   order by n.nspname, p.proname;
   ```
   What Success Looks Like: no unexpected custom functions reference `auth.uid()` or related auth helpers.
   What Failure Looks Like: custom functions or policies explicitly embedding `auth.uid()` in strange ways.
   Why It Matters: identifies hidden DB code that might override or intercept auth helper behavior.

6. Query Number: 6
   SQL Query:
   ```sql
   select rolname, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls
   from pg_roles
   where rolname = 'authenticated';
   ```
   What Success Looks Like: `authenticated` role exists and has expected role attributes.
   What Failure Looks Like: role missing or has unusual attributes like `rolbypassrls=true` or missing login.
   Why It Matters: verifies the database role mapping for JWT-authenticated users.

7. Query Number: 7
   SQL Query:
   ```sql
   select objid::regclass as object_name, deptype, refobjid::regclass as referenced_object, classid::regclass as dependent_class
   from pg_depend
   where refobjid = 'public.families'::regclass
   order by deptype, dependent_class::text;
   ```
   What Success Looks Like: dependencies are only on expected constraints, policies, and indexes.
   What Failure Looks Like: unexpected dependencies suggest hidden objects affecting insert behavior.
   Why It Matters: reveals indirect objects tied to `families` that can influence RLS or insert execution.

8. Query Number: 8
   SQL Query:
   ```sql
   select n.nspname as schema_name, p.proname as function_name, p.prosrc as source, p.prosecdef as security_definer
   from pg_proc p
   join pg_namespace n on p.pronamespace = n.oid
   where p.prosecdef = true
   order by n.nspname, p.proname;
   ```
   What Success Looks Like: list of security definer functions is limited and not directly tied to auth helpers.
   What Failure Looks Like: presence of security definer functions in public or auth namespaces that might affect auth context.
   Why It Matters: security definer functions can alter the privilege and auth context used during inserts.

9. Query Number: 9
   SQL Query:
   ```sql
   select n.nspname as schema_name, p.proname as function_name, p.prosrc as source
   from pg_proc p
   join pg_namespace n on p.pronamespace = n.oid
   where p.prosrc ilike '%auth.uid%' or p.prosrc ilike '%auth.jwt%' or p.prosrc ilike '%auth.role%'
   order by n.nspname, p.proname;
   ```
   What Success Looks Like: only standard auth-related functions or policies reference auth helpers.
   What Failure Looks Like: unusual custom code references auth helpers in conflicting ways.
   Why It Matters: confirms whether any non-standard DB logic is impacting auth helper resolution.

10. Query Number: 10
    SQL Query:
    ```sql
    select n.nspname as schema_name, cls.relname as relation_name, acl
    from pg_class cls
    join pg_namespace n on cls.relnamespace = n.oid
    where cls.relname = 'families'
      and n.nspname = 'public';
    ```
    What Success Looks Like: ACL for `families` shows expected privileges and no odd role mappings.
    What Failure Looks Like: unexpected ACL entries or missing privileges for `authenticated`.
    Why It Matters: verifies whether explicit table ACLs differ from policy expectations.

---

# Database Investigation Phase Round 3

- Confirmed evidence:
  - JWT, session, and payload all contain UUID: ab91696f-bfea-46d4-ac17-dab2d0fbee7a.
  - `families_insert_as_owner` policy exists with `WITH CHECK (owner_user_id = auth.uid())`.
  - No INSERT triggers, unexpected constraints, or ACL issues detected.
  - Error remains: `42501 new row violates row-level security policy`.
- Root cause hypothesis:
  - The PostgreSQL session executing the `families` INSERT is NOT running as the `authenticated` role.
  - OR the JWT claims are not properly propagated to the PostgreSQL context during RLS policy evaluation.
  - OR `auth.uid()` cannot access or resolve the JWT sub claim during policy evaluation.
  - OR Supabase/PostgREST request handling is not setting session variables correctly before INSERT.
- Investigation direction:
  - Determine the exact PostgreSQL role executing the families INSERT request.
  - Verify JWT claim propagation to session variables.
  - Test `auth.uid()` resolution in policy context.
  - Confirm whether PostgREST is setting `request.jwt.claims` correctly.
- Next approved action:
  - PIVOT: Auth context queries are now considered low-value. JWT, payload, and session values already confirmed matching. Instead, focus on database schema objects that could interfere with RLS policy evaluation at the REST layer.
  - Execute targeted SQL queries to inspect policy dependencies, table rules, generated columns, triggers, grants, and PostgREST-facing database objects.

## Why Auth Context Queries Are Low-Value

- JWT sub matches owner_user_id: verified
- Session user.id matches owner_user_id: verified
- Authorization header is present: verified
- The policy syntax is correct: verified
- The error is RLS rejection, not auth failure: confirmed by error code 42501

**Conclusion**: The problem is not JWT propagation or auth context. The problem is a database schema object that is:
1. Preventing the RLS policy from evaluating correctly at the REST layer, or
2. Failing some validation before RLS evaluation can complete, or
3. Interfering with PostgREST's request translation

## Investigation Pivot: Schema Objects & Policy Dependencies

The families INSERT fails at the RLS layer specifically when invoked via PostgREST, despite correct JWT/payload. This suggests:
- A trigger or constraint evaluated before RLS
- Generated columns with function defaults
- Table rules or rewrite behavior
- Schema grants preventing policy enforcement
- PostgREST-specific configuration issues
- Dependency on database objects not available in the request context

## SQL Queries for Round 3 Investigation (Revised: Schema Objects & Dependencies)

1. Query Number: R3-1 | Triggers on families Table
   SQL Query:
   ```sql
   select trigger_name, action_timing, event_manipulation, action_statement
   from information_schema.triggers
   where event_object_table = 'families'
     and event_object_schema = 'public'
   order by event_manipulation, action_timing;
   ```
   What Success Looks Like: no triggers, or only triggers that don't interfere with INSERT validation
   What Failure Looks Like: BEFORE INSERT triggers or triggers that reference auth functions
   Why It Matters: BEFORE INSERT triggers execute before RLS checks; if a trigger references auth.uid() without proper context, it could fail before RLS evaluation

2. Query Number: R3-2 | Generated Columns & Defaults on families
   SQL Query:
   ```sql
   select column_name, column_default, is_generated, generation_expression, data_type
   from information_schema.columns
   where table_name = 'families'
     and table_schema = 'public'
   order by ordinal_position;
   ```
   What Success Looks Like: defaults are simple values or timestamps, no function calls; generated columns do not reference auth functions
   What Failure Looks Like: column defaults call auth.uid() or other context-dependent functions
   Why It Matters: column defaults are evaluated before INSERT policy checks; if default calls auth.uid() before the auth context is set, it fails

3. Query Number: R3-3 | Table Rules on families
   SQL Query:
   ```sql
   select schemaname, tablename, rulename, definition
   from pg_rules
   where tablename = 'families'
     and schemaname = 'public';
   ```
   What Success Looks Like: no rules exist, or rules are standard PostgreSQL INSTEAD OF rules
   What Failure Looks Like: custom rewrite rules that intercept the INSERT
   Why It Matters: rules intercept and rewrite INSERT statements before RLS evaluation; unexpected rules could bypass or interfere with policy checks

4. Query Number: R3-4 | Policy OID & Dependencies
   SQL Query:
   ```sql
   select 
     p.oid as policy_oid,
     p.polname,
     t.oid as table_oid,
     pg_get_expr(p.polwithcheck, p.polrelid) as with_check_expr
   from pg_policy p
   join pg_class t on p.polrelid = t.oid
   where t.relname = 'families'
     and t.relnamespace = 'public'::regnamespace;
   ```
   What Success Looks Like: one row for `families_insert_as_owner` with policy_oid and valid expression
   What Failure Looks Like: multiple policies, conflicting policies, or malformed expression
   Why It Matters: confirms exact policy OID used for this INSERT and shows dependencies

5. Query Number: R3-5 | Function Dependencies via pg_depend
   SQL Query:
   ```sql
   select 
     d.deptype,
     o.relname as object_name,
     c.relkind,
     p.proname as function_name,
     p.oid as function_oid
   from pg_depend d
   join pg_class c on d.objid = c.oid
   left join pg_class o on d.refobjid = o.oid
   left join pg_proc p on d.refobjid = p.oid
   where c.relname = 'families'
     and c.relnamespace = 'public'::regnamespace
   order by d.deptype;
   ```
   What Success Looks Like: dependencies on auth functions (auth.uid) are optional; no critical missing dependencies
   What Failure Looks Like: required dependencies on functions that don't exist or cannot be resolved
   Why It Matters: missing function dependencies could cause policy evaluation to fail

6. Query Number: R3-6 | Schema Grants on families Table
   SQL Query:
   ```sql
   select grantee, privilege_type
   from information_schema.role_table_grants
   where table_name = 'families'
     and table_schema = 'public'
   order by grantee, privilege_type;
   ```
   What Success Looks Like: `authenticated` role has INSERT, SELECT grants; `anon` has no INSERT
   What Failure Looks Like: `authenticated` is missing INSERT grant, or grants are restricted
   Why It Matters: RLS policies don't override table-level grants; if `authenticated` lacks INSERT permission, RLS is never reached

7. Query Number: R3-7 | Table Ownership & Namespace
   SQL Query:
   ```sql
   select 
     t.relname as table_name,
     u.usename as owner,
     n.nspname as schema_name,
     t.relkind,
     t.relrowsecurity,
     t.relpolicy
   from pg_class t
   join pg_user u on t.relowner = u.usesysid
   join pg_namespace n on t.relnamespace = n.oid
   where t.relname = 'families'
     and n.nspname = 'public';
   ```
   What Success Looks Like: owner is postgres or service role; relrowsecurity=true; relpolicy>0
   What Failure Looks Like: owner is an unexpected role; relrowsecurity=false
   Why It Matters: table ownership affects how policies are enforced; if RLS is disabled, policy is ignored

8. Query Number: R3-8 | Constraints on families Table
   SQL Query:
   ```sql
   select constraint_name, constraint_type, column_name
   from information_schema.table_constraints tc
   left join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
   where tc.table_name = 'families'
     and tc.table_schema = 'public'
   order by constraint_type, constraint_name;
   ```
   What Success Looks Like: PK on id; FK to auth.users if present; all constraints are straightforward
   What Failure Looks Like: CHECK constraints that reference auth.uid() or other context functions
   Why It Matters: CHECK constraints are evaluated before RLS; if they fail, RLS never runs

9. Query Number: R3-9 | PostgREST-Specific Table Configuration
   SQL Query:
   ```sql
   select 
     t.relname,
     t.relkind,
     a.attname as column_name,
     t.oid,
     obj_description(t.oid, 'pg_class') as table_comment
   from pg_class t
   left join pg_attribute a on t.oid = a.attrelid and a.attnum > 0
   join pg_namespace n on t.relnamespace = n.oid
   where t.relname = 'families'
     and n.nspname = 'public'
   order by a.attnum;
   ```
   What Success Looks Like: relkind='r' (regular table); no special comments; all columns accessible
   What Failure Looks Like: relkind='v' (view); hidden columns; comments indicating restricted access
   Why It Matters: PostgREST behavior differs for views vs tables; if families is a view, different policies apply

10. Query Number: R3-10 | RLS Policy Expression Details
    SQL Query:
    ```sql
    select 
      p.polname,
      p.polcmd,
      p.polpermissive,
      array_agg(r.rolname) as roles,
      pg_get_expr(p.polqual, p.polrelid) as using_clause,
      pg_get_expr(p.polwithcheck, p.polrelid) as with_check_clause
    from pg_policy p
    left join pg_roles r on p.polroles::text::bigint[] @> array[r.oid]
    where p.polrelid = 'public.families'::regclass
    group by p.polname, p.polcmd, p.polpermissive, p.polrelid, p.polqual, p.polwithcheck
    order by p.polcmd;
    ```
    What Success Looks Like: exactly one INSERT policy with `polpermissive=true` and `with_check_clause` containing `auth.uid()`
    What Failure Looks Like: multiple conflicting policies, permissive=false on INSERT, or malformed expression
    Why It Matters: confirms the exact RLS policy bound to families INSERT and whether it should block or allow

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

# Database Investigation Phase

- Date/Time: 2026-06-09
- Current blocker: `families` INSERT is rejected by RLS with error `42501` despite valid JWT and correct payload.
- Evidence collected so far:
  - Authorization Bearer token is present on the request.
  - JWT role is `authenticated` and JWT sub matches `session.user.id`.
  - `owner_user_id` payload matches the authenticated user.
  - The `families` INSERT policy is `WITH CHECK (owner_user_id = auth.uid())`.
  - Authenticated role has INSERT privilege.
  - RLS is enabled on `families` and FORCE RLS is disabled.
- Confirmed facts:
  - Frontend payload is valid.
  - Session and JWT are aligned.
  - The rejection is coming from database row-level security or a related database object.
- Eliminated root causes:
  - Missing Authorization header.
  - Incorrect `owner_user_id` payload.
  - Bad frontend session/user mapping.
- Pending investigation queries: see the SQL queries listed in the active issue investigation.
- Next approved action:
  - Execute the exact SQL queries in the Supabase SQL Editor to inspect `families` constraints, foreign keys, triggers, policies, grants, and hidden dependencies.
  - Identify the specific database object or policy causing the rejection.

* Login UI
* Register UI
* Forgot Password UI
* React Hook Form Validation

Phase 3
Family Creation 🚀 CURRENT

* Create Family
* Become Owner
* Create Owner Membership
* Family Setup Flow
* Family Onboarding

Phase 4
Dashboard

* Module Selection
* Expense Management Card
* Want To Buy Card
* Month Selection

Phase 5
Expense Management

* Month Selector
* Expense List
* Add Expense
* Edit Expense
* Expense History

Phase 6
Want To Buy

* Item CRUD
* Quantity
* Completion Status

Phase 7
Permissions

* User List
* Permission Toggles

Phase 8
Budgets

* Monthly Budget Management

Phase 9
Money Distribution

* Add Funds
* Distribution Tracking

Phase 10
Notifications

* Notification Center

Phase 11
Theme Customization

* Owner Theme Settings

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
Ready To Start

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

* Phase 3 - Family Creation

Not Started:

* Family Creation Flow
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

Phase 3 - Family Creation

Status:
READY TO START

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

# Next Development Phase

Next implementation target:

Phase 3 - Family Creation

Implementation order:

1. Create family setup page.
2. Create family service using existing families and family_members tables.
3. Allow authenticated users without active family to create a family.
4. Insert owner family membership using existing database structure.
5. Refresh auth state after family creation.
6. Redirect users with active family to dashboard.
7. Preserve mobile-first layout.
8. Keep database architecture unchanged.

Family creation must be completed before production dashboard, expenses, want-to-buy, budgets, permissions, notifications, or theme customization.

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

Ready For:
Family Creation Implementation

---

# Diagnostic Test: Families INSERT RLS Policy Isolation

## Test Date
2026-06-09

## Reason For Test
Families INSERT operations fail with error code `42501` (row-level security policy violation) despite:
- User authentication confirmed
- JWT sub matches owner_user_id
- Profile record exists
- All payload values match session values
- Foreign key constraints valid
- Database grants correct

## Hypothesis
The failure is specifically caused by the condition `owner_user_id = auth.uid()` in the INSERT policy, OR there is another obstruction in the INSERT path unrelated to authentication.

## Test Objective
Isolate the root cause by temporarily replacing the INSERT policy with a permissive policy `WITH CHECK (true)`.

## Policy Under Test
**Current Policy Name:** `families_insert_as_owner`

**Current Policy Definition:**
```sql
CREATE POLICY families_insert_as_owner ON public.families 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (owner_user_id = auth.uid());
```

**Temporary Diagnostic Policy Definition:**
```sql
CREATE POLICY families_insert_as_owner_diagnostic ON public.families 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (true);
```

## Expected Outcomes

### Success Scenario
- INSERT on families table succeeds
- No 42501 error returned
- Family record is created with the provided owner_user_id

**Diagnosis if Success:**
The root cause IS the condition `owner_user_id = auth.uid()`. One of:
1. `auth.uid()` returns NULL during INSERT evaluation
2. `auth.uid()` returns a different UUID than owner_user_id
3. A timing or sequencing issue prevents auth context propagation
4. JWT claims are not accessible during RLS policy evaluation at the REST layer

**Next Step if Success:**
- Investigate JWT propagation to Supabase RLS context
- Verify auth.uid() resolution during REST requests
- Examine PostgREST configuration for JWT claim mapping
- Check for database role/grant misconfigurations

### Failure Scenario
- INSERT on families table still fails with 42501
- No change in error behavior from before the test

**Diagnosis if Failure:**
The root cause is NOT the condition `owner_user_id = auth.uid()`. Root cause exists elsewhere:
1. Another RLS policy is blocking INSERT (unlikely, given this is the only INSERT policy)
2. An undiscovered trigger, constraint, or validation is failing before RLS evaluation
3. Missing or incorrect database grants at table/schema level
4. PostgREST layer configuration preventing request execution
5. A dependent object or generated column is raising an error

**Next Step if Failure:**
- Investigate INSERT triggers on families table
- Audit foreign key constraints and DEFAULT values
- Inspect generated columns or computed fields
- Verify table and schema ACLs
- Check PostgREST authentication and authorization configuration

## Rollback Procedure
After test completion, the diagnostic policy must be dropped and the original policy restored:

**Step 1: Drop Diagnostic Policy**
```sql
DROP POLICY families_insert_as_owner_diagnostic ON public.families;
```

**Step 2: Restore Original Policy**
```sql
CREATE POLICY families_insert_as_owner ON public.families 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (owner_user_id = auth.uid());
```

**Step 3: Verify Restoration**
```sql
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'families' AND policyname LIKE '%insert%'
ORDER BY policyname;
```

## All Other Policies (Unchanged)
- `families_select_active_members` (SELECT)
- `families_update_owner` (UPDATE)
- `families_delete_owner` (DELETE)

These policies MUST remain untouched during the diagnostic test.

## Test Execution Authority
Only execute this test SQL in Supabase SQL Editor with explicit approval.
Do not combine with other schema changes.
Do not execute in production without backup.

## Success Criteria Checklist
- [ ] Diagnostic policy deployed
- [ ] INSERT attempt made on families table
- [ ] Result recorded (success/failure)
- [ ] Original policy restored
- [ ] Verification query confirms restoration
- [ ] No other policies modified
- [ ] No other tables affected

---

# Complete Diagnostic SQL Package

## Test Execution Log Template

**Test Timestamp**: [TO BE FILLED: ISO 8601 timestamp when SQL is executed]

**Original Policy Captured**: [TO BE FILLED: pg_policies output before test]

**Diagnostic Policy Status**: [TO BE FILLED: DEPLOYED / ROLLED BACK]

**INSERT Test Result**: [TO BE FILLED: SUCCESS / FAILED 42501 / FAILED OTHER]

**Error Message (if failed)**: [TO BE FILLED: Exact error from Supabase]

**Rollback Status**: [TO BE FILLED: COMPLETED / PENDING]

---

## Step 0: Pre-Test Verification (CAPTURE CURRENT STATE)

### Query: Capture Current families INSERT Policy Definition

**Purpose**: Document the exact current policy before any modifications

**Execute in Supabase SQL Editor**:

```sql
-- ============================================================================
-- STEP 0: CAPTURE CURRENT INSERT POLICY
-- ============================================================================
-- Query: Capture families INSERT Policy Before Test

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles::text[] as policy_roles,
  qual as using_condition,
  with_check as check_condition
FROM pg_policies 
WHERE tablename = 'families' 
  AND event_type = 'INSERT'
ORDER BY policyname;

-- Expected Output:
-- | schemaname | tablename | policyname                 | permissive | policy_roles | using_condition | check_condition                      |
-- | public     | families  | families_insert_as_owner   | true       | authenticated | (null)          | owner_user_id = auth.uid()          |
```

**Record Output**: Document the exact policy definition (capture screenshot or text)

---

### Query: Verify All families Policies (SELECT/UPDATE/DELETE Unchanged)

**Purpose**: Confirm that other policies are not modified during test

**Execute in Supabase SQL Editor**:

```sql
-- ============================================================================
-- VERIFY: All families Policies (Pre-Test Baseline)
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

-- Expected Output (PRE-TEST):
-- | policyname                     | event_type | permissive | policy_roles      | has_using    | has_with_check  |
-- | families_insert_as_owner       | INSERT     | true       | {authenticated}   | NO USING     | HAS WITH_CHECK  |
-- | families_select_active_members | SELECT     | true       | {authenticated}   | HAS USING    | NO WITH_CHECK   |
-- | families_update_owner          | UPDATE     | true       | {authenticated}   | HAS USING    | HAS WITH_CHECK  |
-- | families_delete_owner          | DELETE     | true       | {authenticated}   | HAS USING    | NO WITH_CHECK   |
```

**Record Output**: Screenshot or save output for comparison post-test

---

## Step 1: Deploy Diagnostic Policy

### SQL: Drop Current INSERT Policy & Deploy Diagnostic Policy

**Purpose**: Replace the restrictive policy with a permissive one to isolate the failure cause

**Execute in Supabase SQL Editor**:

```sql
-- ============================================================================
-- STEP 1: DEPLOY DIAGNOSTIC POLICY
-- Timestamp: [INSERT CURRENT TIMESTAMP]
-- ============================================================================

-- Step 1A: Drop the existing restrictive INSERT policy
DROP POLICY IF EXISTS families_insert_as_owner ON public.families;

-- Step 1B: Create temporary permissive diagnostic policy
CREATE POLICY families_insert_as_owner_diagnostic ON public.families 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (true);

-- Confirmation message:
-- NOTICE: DROP POLICY completed
-- NOTICE: CREATE POLICY completed
```

**Expected Result**: Both commands complete without error

---

## Step 2: Verify Diagnostic Policy Deployment

### Query: Confirm Diagnostic Policy Is Active

**Purpose**: Verify that the diagnostic policy replaced the original policy

**Execute in Supabase SQL Editor**:

```sql
-- ============================================================================
-- STEP 2: VERIFY DIAGNOSTIC POLICY DEPLOYMENT
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

-- Expected Output:
-- | policyname                          | event_type | permissive | policy_roles | using_condition | check_condition |
-- | families_insert_as_owner_diagnostic | INSERT     | true       | {authenticated} | (null)          | true            |
```

**Record Output**: Verify that:
- `families_insert_as_owner_diagnostic` policy is PRESENT
- `families_insert_as_owner` policy is ABSENT
- `with_check` condition is `true`

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

# Test Result Interpretation Guide

## SCENARIO 1: INSERT Succeeds (Status 201)

**What Happened**:
- Family record was created successfully
- No RLS rejection
- The diagnostic policy `WITH CHECK (true)` allowed the INSERT

**Root Cause Diagnosis**:
✅ The failure IS caused by the condition `owner_user_id = auth.uid()`

**Specific Root Cause (one of)**:
1. `auth.uid()` returned NULL during RLS policy evaluation
2. `auth.uid()` returned a different UUID value than `owner_user_id`
3. JWT claims were not propagated to the RLS evaluation context
4. PostgREST did not set session variables correctly before INSERT
5. Database role/permission issue preventing auth.uid() resolution

**Next Steps**:
1. Enable Supabase Auth Debug logging
2. Capture JWT token from Authorization header
3. Verify JWT sub claim matches session.user.id
4. Test `SELECT auth.uid()` directly in SQL Editor while authenticated
5. Investigate PostgREST JWT claim mapping configuration
6. Check for database role inheritance or permission gaps
7. Verify Supabase JWT secret configuration

**Action Priority**: URGENT - Auth context is not propagating to RLS layer

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

# Test Execution Checklist

**Pre-Test**:
- [ ] Read entire SQL package
- [ ] Backup Supabase database (or note safe rollback via Git)
- [ ] Have browser DevTools ready (F12)
- [ ] Have Supabase SQL Editor tab open
- [ ] Record pre-test baseline (Step 0 queries)

**Deployment**:
- [ ] Execute Step 1 SQL (deploy diagnostic policy)
- [ ] Execute Step 2 query (verify deployment)
- [ ] Record both outputs

**Test Execution**:
- [ ] Attempt family creation via frontend UI
- [ ] Record response status and error (if any)
- [ ] Check families table (Step 4 query)
- [ ] Document result

**Rollback**:
- [ ] Execute Step 5 SQL (restore original policy)
- [ ] Execute Step 6 queries (verify rollback)
- [ ] Compare pre-test and post-test policies (must match)
- [ ] Record all outputs

**Documentation**:
- [ ] Fill test execution log template above
- [ ] Record all query outputs
- [ ] Determine which scenario matches (1, 2, or 3)
- [ ] Document next steps based on scenario
- [ ] Update this section: Status: ✅ COMPLETED

**Post-Test Analysis**:
- [ ] Review interpretation guide for your scenario
- [ ] Identify specific root cause
- [ ] Plan next investigation phase
- [ ] Document findings in session memory
