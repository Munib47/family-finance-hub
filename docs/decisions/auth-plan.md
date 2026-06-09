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
