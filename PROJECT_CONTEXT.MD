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
→ Settings
→ Users
→ Select User
→ Permission Toggles

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
↓
Dashboard
↓
Select Module

Option A:
Expense Management

Option B:
Want To Buy

---

# Expense Management Flow

Expense Management
↓
Select Month
↓
Expense List
↓
Add / Edit Expense

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
↓
New Value
↓
Store History
↓
Notify Owner

Database:

expense_updates

Stores:

* old_data
* new_data
* updated_by_user_id

---

# Want To Buy Flow

Want To Buy
↓
Select Month
↓
Item List

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
↓
Select User
↓
Enter Amount
↓
Enter Purpose
↓
Save

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

Completed.

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

# Current Project Status

Database:
✅ Complete

Tables:
✅ Complete

Indexes:
✅ Complete

Functions:
✅ Complete

Triggers:
✅ Complete

Seed Data:
✅ Complete

RLS:
✅ Complete

Authentication:
❌ Not Started

Frontend:
❌ Not Started

Dashboard:
❌ Not Started

Expense Module:
❌ Not Started

Want To Buy:
❌ Not Started

Permissions UI:
❌ Not Started

Notifications UI:
❌ Not Started

Theme Settings UI:
❌ Not Started

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
