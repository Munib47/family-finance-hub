# Authentication Plan

## Phase

Phase 1A

Status:
Approved

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
