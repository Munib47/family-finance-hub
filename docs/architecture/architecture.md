# Application Architecture

## Technology Stack

Frontend:

* React 19
* Vite
* Tailwind CSS
* React Router DOM
* Context API

Backend:

* Supabase

Database:

* PostgreSQL (Supabase)

Authentication:

* Supabase Auth

## Architecture Style

Feature-based architecture.

Structure:

src/
├── components/
├── layouts/
├── routes/
├── lib/
├── hooks/
├── contexts/
├── services/
├── utils/
│
└── features/
├── auth/
├── dashboard/
├── expenses/
├── budgets/
├── want-to-buy/
├── notifications/
├── permissions/
└── settings/

## Core Modules

### Authentication

Responsibilities:

* Login
* Register
* Logout
* Forgot Password
* Session Persistence
* Role Loading
* Permission Loading

### Expense Management

Responsibilities:

* Month Selection
* Expense CRUD
* Expense History
* Owner Notifications

### Want To Buy

Responsibilities:

* Shared Shopping List
* Quantity Management
* Item Completion

### Budget Management

Responsibilities:

* Monthly Budgets
* Budget Visibility
* Budget Tracking

### Permissions

Responsibilities:

* Grant Access
* Revoke Access
* Permission Management

### Notifications

Responsibilities:

* Realtime Notifications
* Read Status
* Notification History

## Security

Supabase RLS is the source of truth.

Frontend permission checks improve UX.

Backend RLS provides actual security.

## Database Status

Database architecture completed.

No schema changes allowed without approval.
