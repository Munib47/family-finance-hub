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
* src/features/auth/components/AuthErrorState.jsx
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
* Auth pages are still placeholder screens and will be implemented in the next phase.
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

# Development Roadmap

Phase 1
Authentication

* AuthContext
* Login
* Register
* Protected Routes

Phase 2
Family Creation

* Create Family
* Become Owner

Phase 3
Dashboard

* Expense Management
* Want To Buy

Phase 4
Expense Management

* Month Selector
* Expense List
* Add Expense
* Edit Expense

Phase 5
Want To Buy

* Item CRUD
* Quantity
* Completion Status

Phase 6
Permissions

* User List
* Permission Toggles

Phase 7
Budgets

* Monthly Budget Management

Phase 8
Money Distribution

* Add Funds
* Distribution Tracking

Phase 9
Notifications

* Notification Center

Phase 10
Theme Customization

* Owner Theme Settings

---

# Project Status

Project State:
Database Complete
Frontend Starting

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
Foundation Complete

Frontend:
Starting

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

* Phase 2 - Authentication Pages

Not Started:

* Login Form Implementation
* Register Form Implementation
* Forgot Password Flow
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
* Forgot Password route placeholder created
* Temporary protected dashboard placeholder created
* Placeholder Login page created
* Placeholder Register page created
* Supabase client file created
* Tailwind CSS imported

Current routes:

* / -> Login
* /login -> Login
* /register -> Register
* /forgot-password -> Forgot Password
* /dashboard -> Protected authentication-ready placeholder

Missing:

* Login form implementation
* Register form implementation
* Forgot Password form implementation
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

Phase 1B - Authentication Foundation

Status:
COMPLETE

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

Next:

* Phase 2 - Authentication Pages
* Login Form
* Register Form
* Forgot Password Form
* Form Loading States
* Form Error States
* Post-auth Redirect UX

---

# Next Development Phase

Next implementation target:

Phase 2 - Authentication Pages

Implementation order:

1. Implement Login form using useAuth.
2. Implement Register form using useAuth.
3. Implement Forgot Password form using useAuth.
4. Add loading states to all authentication forms.
5. Add error states to all authentication forms.
6. Add successful auth redirects.
7. Preserve mobile-first layout.
8. Keep database architecture unchanged.

Authentication pages must be completed before family creation, dashboard, expenses, want-to-buy, budgets, permissions, notifications, or theme customization.

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
Frontend Starting

Ready For:
Authentication Pages Implementation
