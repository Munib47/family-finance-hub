# Authentication Plan

## Phase

Phase 1A

Status:
Approved

## Current Implementation Status

Phase 1A:
Authentication Architecture Approved

Phase 1B:
Authentication Foundation Complete

Phase 2:
Authentication UI Implementation Complete

## Authentication Provider

AuthProvider

Responsibilities:

* Session Management
* User State
* Profile Loading
* Family Loading
* Role Loading
* Permission Loading

## Context

AuthContext

Provides:

* user
* profile
* family
* role
* permissions
* session
* loading
* error

## Hook

useAuth()

Single source of truth.

All components must consume auth through useAuth().

## Route Protection

PublicRoute

Routes:

* Login
* Register
* Forgot Password

ProtectedRoute

Routes:

* Dashboard
* Expenses
* Want To Buy
* Budgets
* Notifications
* Settings

## Session Flow

App Start
↓
Restore Session
↓
Load Profile
↓
Load Family
↓
Load Role
↓
Load Permissions
↓
Application Ready

## Permission Strategy

Owner:
Receives all permissions automatically.

Regular User:
No permissions by default.

Authorized User:
Permissions loaded through existing has_permission RPC.

Direct reads from member_permission_grants are prohibited.

## Phase 2 UI Decisions

Authentication screens follow the approved app flow diagram:

* Clean white background
* Black primary text
* Mobile-first centered card
* Stacked form inputs
* Black primary action button
* Simple text links between Login, Register, and Forgot Password
* Loading states on all submit actions
* Inline validation and server error states
* Forgot Password success message after reset email request

## Phase 2 Completed Files

Created:

* src/features/auth/components/AuthLayout.jsx
* src/features/auth/components/AuthCard.jsx
* src/features/auth/components/AuthInput.jsx
* src/features/auth/components/AuthButton.jsx

Modified:

* src/features/auth/index.js
* src/pages/auth/Login.jsx
* src/pages/auth/Register.jsx
* src/pages/auth/ForgotPassword.jsx
* PROJECT_CONTEXT.MD
* docs/roadmap/roadmap.md
* docs/decisions/auth-plan.md

## Next Recommendation

Next Phase:
Phase 3 - Family Creation

Recommended scope:

* Create Family page
* Family creation service
* Owner membership creation
* Redirect authenticated users without active family to family setup
* Refresh AuthProvider state after family creation
* Keep database schema, functions, triggers, and RLS unchanged

---

## Phase 3 Family Creation

Status:
Complete

### Implementation Decisions

* Creator always becomes Owner
* Family name required (2-100 characters)
* No notifications in Phase 3
* No deletion functionality
* No invitation functionality
* One family per user (current design)
* Creator auto-receives all permissions

### First-Time User Redirect Flow

Unauthenticated User
  ↓
  Login
  ↓
  Authenticated + No Family
  ↓
  /family/setup (PublicRoute redirects)
  ↓
  Create Family
  ↓
  Refresh Auth State
  ↓
  /dashboard

### Route Changes

Public Routes:
* /login → Login (no family required)
* /register → Register (no family required)
* /forgot-password → ForgotPassword (no family required)

Protected Routes (requireFamily=false):
* /family/setup → FamilySetup (authentication required, family not required)

Protected Routes (requireFamily=true):
* /dashboard → Dashboard (authentication required, family required)

### Public Route Enhancement

When authenticated user arrives at public route:

1. Check if user has active family
2. If no family → redirect to /family/setup
3. If has family → redirect to /dashboard

### Auth State Refresh

After successful family creation:

1. familyService.createFamily() returns family and member objects
2. FamilySetup page calls refreshAuthState()
3. AuthContext re-runs bootstrapAuthState()
4. bootstrapAuthState loads:
   - Profile (already loaded)
   - Active family membership (NEW)
   - Permission definitions
   - Permissions (ALL for owner)
5. AuthContext updates hasFamily to true
6. User redirected to /dashboard

### Phase 3 Completed Files

Created:

* src/features/family/index.js
* src/features/family/components/FamilySetupForm.jsx
* src/features/family/components/FamilySetupCard.jsx
* src/features/family/services/familyService.js
* src/pages/family/FamilySetup.jsx

Modified:

* src/routes/AppRoutes.jsx
* src/features/auth/routes/PublicRoute.jsx
* PROJECT_CONTEXT.MD
* docs/roadmap/roadmap.md
* docs/decisions/auth-plan.md

### Database Operations

createFamily(familyName, userId):

1. Validation:
   - familyName required
   - familyName 2-100 characters
   - userId required

2. Create families record:
   - name: familyName (trimmed)
   - owner_user_id: userId
   - default_currency: USD
   - fiscal_month_start_day: 1
   - status: active

3. Create family_members record:
   - family_id: created family ID
   - user_id: userId
   - base_role: owner
   - membership_status: active
   - joined_at: NOW()

4. Return family and member objects

### Next Phase

Next Phase:
Phase 4 - Dashboard (Expense Management + Want To Buy selector)

Prerequisites:
- Phase 1A: Authentication Architecture (Complete)
- Phase 1B: Authentication Foundation (Complete)
- Phase 2: Authentication UI (Complete)
- Phase 3: Family Creation (Complete)

Estimated Work:
- 3-5 components
- 1 main dashboard page
- Basic month selector
- Module selection UI

