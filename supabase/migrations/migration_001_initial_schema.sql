-- ============================================================================
-- migration_001_initial_schema.sql
-- Family Expense Management Application
-- ============================================================================

-- ============================================================================
-- 1. Extensions
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "citext" WITH SCHEMA "extensions";

-- ============================================================================
-- 2. Types / Enums
-- ============================================================================

CREATE TYPE public.base_role AS ENUM (
  'owner',
  'regular_user',
  'authorized_user'
);

CREATE TYPE public.membership_status AS ENUM (
  'pending',
  'active',
  'suspended',
  'removed'
);

CREATE TYPE public.family_status AS ENUM (
  'active',
  'archived',
  'deleted'
);

CREATE TYPE public.invitation_status AS ENUM (
  'pending',
  'accepted',
  'expired',
  'revoked'
);

CREATE TYPE public.expense_visibility AS ENUM (
  'family',
  'private'
);

CREATE TYPE public.want_to_buy_status AS ENUM (
  'idea',
  'approved',
  'saving',
  'purchased',
  'cancelled'
);

CREATE TYPE public.want_to_buy_priority AS ENUM (
  'low',
  'medium',
  'high'
);

CREATE TYPE public.money_source_type AS ENUM (
  'shared_pool',
  'allowance',
  'savings',
  'other'
);

CREATE TYPE public.money_transaction_type AS ENUM (
  'deposit',
  'withdrawal',
  'distribution',
  'adjustment',
  'expense_link'
);

CREATE TYPE public.distribution_status AS ENUM (
  'draft',
  'completed',
  'cancelled'
);

CREATE TYPE public.distribution_line_status AS ENUM (
  'pending',
  'completed',
  'cancelled'
);

-- ============================================================================
-- 3. Tables
-- ============================================================================

CREATE TABLE public.profiles (
  id                  UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  display_name        TEXT,
  avatar_url          TEXT,
  email               extensions.citext,
  phone               TEXT,
  locale              TEXT NOT NULL DEFAULT 'en',
  timezone            TEXT NOT NULL DEFAULT 'UTC',
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.families (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                    TEXT NOT NULL,
  owner_user_id           UUID NOT NULL REFERENCES public.profiles (id) ON DELETE RESTRICT,
  default_currency        CHAR(3) NOT NULL DEFAULT 'USD',
  fiscal_month_start_day  SMALLINT NOT NULL DEFAULT 1,
  status                  public.family_status NOT NULL DEFAULT 'active',
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.family_members (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id           UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  user_id             UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  base_role           public.base_role NOT NULL DEFAULT 'regular_user',
  membership_status   public.membership_status NOT NULL DEFAULT 'pending',
  nickname            TEXT,
  invited_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  joined_at           TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.family_invitations (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id           UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  email               extensions.citext NOT NULL,
  invited_base_role   public.base_role NOT NULL DEFAULT 'regular_user',
  token_hash          TEXT NOT NULL,
  status              public.invitation_status NOT NULL DEFAULT 'pending',
  expires_at          TIMESTAMPTZ NOT NULL,
  accepted_at         TIMESTAMPTZ,
  invited_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.permission_definitions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  permission_key  TEXT NOT NULL,
  module          TEXT NOT NULL,
  description     TEXT,
  is_assignable   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.role_default_permissions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  base_role       public.base_role NOT NULL,
  permission_id   UUID NOT NULL REFERENCES public.permission_definitions (id) ON DELETE CASCADE,
  scope           TEXT NOT NULL DEFAULT 'family',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.member_permission_grants (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_member_id    UUID NOT NULL REFERENCES public.family_members (id) ON DELETE CASCADE,
  permission_id       UUID NOT NULL REFERENCES public.permission_definitions (id) ON DELETE RESTRICT,
  granted_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  granted_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  revoked_at          TIMESTAMPTZ,
  revoked_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.months (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id     UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  month_year    INTEGER NOT NULL,
  month_number  INTEGER NOT NULL,
  month_name    TEXT NOT NULL,
  is_current    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.expense_categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id   UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  icon        TEXT,
  color       TEXT,
  is_system   BOOLEAN NOT NULL DEFAULT FALSE,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.expenses (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id           UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  category_id         UUID REFERENCES public.expense_categories (id) ON DELETE SET NULL,
  month_id            UUID REFERENCES public.months (id) ON DELETE SET NULL,
  created_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  title               TEXT NOT NULL,
  amount              NUMERIC(14, 2) NOT NULL,
  currency            CHAR(3) NOT NULL DEFAULT 'USD',
  expense_date        DATE NOT NULL DEFAULT CURRENT_DATE,
  description         TEXT,
  payment_method      TEXT,
  visibility          public.expense_visibility NOT NULL DEFAULT 'family',
  metadata            JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.expense_attachments (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_id          UUID NOT NULL REFERENCES public.expenses (id) ON DELETE CASCADE,
  storage_path        TEXT NOT NULL,
  file_name           TEXT NOT NULL,
  mime_type           TEXT,
  file_size_bytes     BIGINT,
  uploaded_by_user_id UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.expense_tags (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id   UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.expense_tag_map (
  expense_id  UUID NOT NULL REFERENCES public.expenses (id) ON DELETE CASCADE,
  tag_id      UUID NOT NULL REFERENCES public.expense_tags (id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (expense_id, tag_id)
);

CREATE TABLE public.expense_updates (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_id          UUID NOT NULL REFERENCES public.expenses (id) ON DELETE CASCADE,
  updated_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  old_data            JSONB NOT NULL,
  new_data            JSONB NOT NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.monthly_budgets (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id           UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  category_id         UUID NOT NULL REFERENCES public.expense_categories (id) ON DELETE RESTRICT,
  month_id            UUID NOT NULL REFERENCES public.months (id) ON DELETE RESTRICT,
  allocated_amount    NUMERIC(14, 2) NOT NULL,
  currency            CHAR(3) NOT NULL DEFAULT 'USD',
  notes               TEXT,
  created_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.budget_alerts (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id           UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  category_id         UUID REFERENCES public.expense_categories (id) ON DELETE CASCADE,
  threshold_percent   NUMERIC(5, 2) NOT NULL,
  is_enabled          BOOLEAN NOT NULL DEFAULT TRUE,
  created_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.want_to_buy_items (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id             UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  month_id              UUID REFERENCES public.months (id) ON DELETE SET NULL,
  title                 TEXT NOT NULL,
  description           TEXT,
  estimated_cost        NUMERIC(14, 2),
  currency              CHAR(3) NOT NULL DEFAULT 'USD',
  quantity              INTEGER NOT NULL DEFAULT 1,
  priority              public.want_to_buy_priority NOT NULL DEFAULT 'medium',
  target_date           DATE,
  status                public.want_to_buy_status NOT NULL DEFAULT 'idea',
  requested_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  approved_by_user_id   UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  purchased_at          TIMESTAMPTZ,
  linked_expense_id     UUID REFERENCES public.expenses (id) ON DELETE SET NULL,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.notifications (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id           UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  recipient_user_id   UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  type                TEXT NOT NULL,
  title               TEXT NOT NULL,
  body                TEXT,
  payload             JSONB NOT NULL DEFAULT '{}'::JSONB,
  is_read             BOOLEAN NOT NULL DEFAULT FALSE,
  read_at             TIMESTAMPTZ,
  source_module       TEXT,
  source_entity_type  TEXT,
  source_entity_id    UUID,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.notification_preferences (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id         UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  user_id           UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  notification_type TEXT NOT NULL,
  in_app_enabled    BOOLEAN NOT NULL DEFAULT TRUE,
  email_enabled     BOOLEAN NOT NULL DEFAULT FALSE,
  push_enabled      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.activity_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id       UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  actor_user_id   UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  action          TEXT NOT NULL,
  entity_type     TEXT NOT NULL,
  entity_id       UUID,
  summary         TEXT NOT NULL,
  changes         JSONB NOT NULL DEFAULT '{}'::JSONB,
  ip_address      INET,
  user_agent      TEXT,
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.money_sources (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id           UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  source_type         public.money_source_type NOT NULL DEFAULT 'shared_pool',
  balance             NUMERIC(14, 2) NOT NULL DEFAULT 0,
  currency            CHAR(3) NOT NULL DEFAULT 'USD',
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  managed_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.money_source_transactions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  money_source_id     UUID NOT NULL REFERENCES public.money_sources (id) ON DELETE CASCADE,
  family_id           UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  transaction_type    public.money_transaction_type NOT NULL,
  amount              NUMERIC(14, 2) NOT NULL,
  balance_after       NUMERIC(14, 2) NOT NULL,
  reference_type      TEXT,
  reference_id        UUID,
  created_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  notes               TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.money_distributions (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id               UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  money_source_id         UUID NOT NULL REFERENCES public.money_sources (id) ON DELETE RESTRICT,
  total_amount            NUMERIC(14, 2) NOT NULL,
  currency                CHAR(3) NOT NULL DEFAULT 'USD',
  status                  public.distribution_status NOT NULL DEFAULT 'draft',
  distributed_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  distribution_date       DATE NOT NULL DEFAULT CURRENT_DATE,
  notes                   TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.money_distribution_lines (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  distribution_id     UUID NOT NULL REFERENCES public.money_distributions (id) ON DELETE CASCADE,
  recipient_user_id   UUID NOT NULL REFERENCES public.profiles (id) ON DELETE RESTRICT,
  amount              NUMERIC(14, 2) NOT NULL,
  purpose             TEXT,
  status              public.distribution_line_status NOT NULL DEFAULT 'pending',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.family_theme_settings (
  family_id           UUID PRIMARY KEY REFERENCES public.families (id) ON DELETE CASCADE,
  primary_color       TEXT,
  accent_color        TEXT,
  background_style    TEXT,
  font_family         TEXT,
  logo_url            TEXT,
  dark_mode_default   BOOLEAN NOT NULL DEFAULT FALSE,
  custom_css_vars     JSONB NOT NULL DEFAULT '{}'::JSONB,
  updated_by_user_id  UUID REFERENCES public.profiles (id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.user_theme_overrides (
  user_id         UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  family_id       UUID NOT NULL REFERENCES public.families (id) ON DELETE CASCADE,
  theme_snapshot  JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, family_id)
);

-- ============================================================================
-- 4. Constraints
-- ============================================================================

ALTER TABLE public.families
  ADD CONSTRAINT families_fiscal_month_start_day_check
    CHECK (fiscal_month_start_day BETWEEN 1 AND 28);

ALTER TABLE public.family_members
  ADD CONSTRAINT family_members_family_user_unique UNIQUE (family_id, user_id);

ALTER TABLE public.permission_definitions
  ADD CONSTRAINT permission_definitions_permission_key_unique UNIQUE (permission_key);

ALTER TABLE public.role_default_permissions
  ADD CONSTRAINT role_default_permissions_role_permission_unique UNIQUE (base_role, permission_id);

ALTER TABLE public.months
  ADD CONSTRAINT months_family_year_month_unique UNIQUE (family_id, month_year, month_number);

ALTER TABLE public.months
  ADD CONSTRAINT months_month_number_check CHECK (month_number BETWEEN 1 AND 12);

ALTER TABLE public.expense_categories
  ADD CONSTRAINT expense_categories_family_name_unique UNIQUE (family_id, name);

ALTER TABLE public.expenses
  ADD CONSTRAINT expenses_amount_positive CHECK (amount > 0);

ALTER TABLE public.expense_tags
  ADD CONSTRAINT expense_tags_family_name_unique UNIQUE (family_id, name);

ALTER TABLE public.monthly_budgets
  ADD CONSTRAINT monthly_budgets_allocated_amount_positive CHECK (allocated_amount >= 0);

ALTER TABLE public.monthly_budgets
  ADD CONSTRAINT monthly_budgets_family_category_month_unique
    UNIQUE (family_id, category_id, month_id);

ALTER TABLE public.budget_alerts
  ADD CONSTRAINT budget_alerts_threshold_percent_check
    CHECK (threshold_percent > 0 AND threshold_percent <= 100);

ALTER TABLE public.want_to_buy_items
  ADD CONSTRAINT want_to_buy_items_estimated_cost_positive
    CHECK (estimated_cost IS NULL OR estimated_cost > 0);

ALTER TABLE public.want_to_buy_items
  ADD CONSTRAINT want_to_buy_items_quantity_positive CHECK (quantity > 0);

ALTER TABLE public.notification_preferences
  ADD CONSTRAINT notification_preferences_family_user_type_unique
    UNIQUE (family_id, user_id, notification_type);

ALTER TABLE public.money_sources
  ADD CONSTRAINT money_sources_balance_non_negative CHECK (balance >= 0);

ALTER TABLE public.money_sources
  ADD CONSTRAINT money_sources_family_name_unique UNIQUE (family_id, name);

ALTER TABLE public.money_source_transactions
  ADD CONSTRAINT money_source_transactions_amount_positive CHECK (amount > 0);

ALTER TABLE public.money_distributions
  ADD CONSTRAINT money_distributions_total_amount_positive CHECK (total_amount > 0);

ALTER TABLE public.money_distribution_lines
  ADD CONSTRAINT money_distribution_lines_amount_positive CHECK (amount > 0);

-- ============================================================================
-- 5. Indexes
-- ============================================================================

CREATE INDEX idx_families_owner_user_id ON public.families (owner_user_id);
CREATE INDEX idx_family_members_family_id ON public.family_members (family_id);
CREATE INDEX idx_family_members_user_id ON public.family_members (user_id);
CREATE INDEX idx_family_members_invited_by_user_id ON public.family_members (invited_by_user_id);
CREATE INDEX idx_family_invitations_family_id ON public.family_invitations (family_id);
CREATE INDEX idx_family_invitations_invited_by_user_id ON public.family_invitations (invited_by_user_id);
CREATE INDEX idx_role_default_permissions_permission_id ON public.role_default_permissions (permission_id);
CREATE INDEX idx_role_default_permissions_base_role ON public.role_default_permissions (base_role);
CREATE INDEX idx_member_permission_grants_family_member_id ON public.member_permission_grants (family_member_id);
CREATE INDEX idx_member_permission_grants_permission_id ON public.member_permission_grants (permission_id);
CREATE INDEX idx_member_permission_grants_granted_by_user_id ON public.member_permission_grants (granted_by_user_id);
CREATE INDEX idx_member_permission_grants_revoked_by_user_id ON public.member_permission_grants (revoked_by_user_id);
CREATE INDEX idx_months_family_id ON public.months (family_id);
CREATE INDEX idx_expense_categories_family_id ON public.expense_categories (family_id);
CREATE INDEX idx_expenses_family_id ON public.expenses (family_id);
CREATE INDEX idx_expenses_category_id ON public.expenses (category_id);
CREATE INDEX idx_expenses_created_by_user_id ON public.expenses (created_by_user_id);
CREATE INDEX idx_expenses_month_id ON public.expenses (month_id);
CREATE INDEX idx_expense_attachments_expense_id ON public.expense_attachments (expense_id);
CREATE INDEX idx_expense_attachments_uploaded_by_user_id ON public.expense_attachments (uploaded_by_user_id);
CREATE INDEX idx_expense_tags_family_id ON public.expense_tags (family_id);
CREATE INDEX idx_expense_tag_map_tag_id ON public.expense_tag_map (tag_id);
CREATE INDEX idx_expense_updates_expense_id ON public.expense_updates (expense_id);
CREATE INDEX idx_expense_updates_updated_by_user_id ON public.expense_updates (updated_by_user_id);
CREATE INDEX idx_monthly_budgets_family_id ON public.monthly_budgets (family_id);
CREATE INDEX idx_monthly_budgets_category_id ON public.monthly_budgets (category_id);
CREATE INDEX idx_monthly_budgets_month_id ON public.monthly_budgets (month_id);
CREATE INDEX idx_monthly_budgets_created_by_user_id ON public.monthly_budgets (created_by_user_id);
CREATE INDEX idx_budget_alerts_family_id ON public.budget_alerts (family_id);
CREATE INDEX idx_budget_alerts_category_id ON public.budget_alerts (category_id);
CREATE INDEX idx_budget_alerts_created_by_user_id ON public.budget_alerts (created_by_user_id);
CREATE INDEX idx_want_to_buy_items_family_id ON public.want_to_buy_items (family_id);
CREATE INDEX idx_want_to_buy_items_requested_by_user_id ON public.want_to_buy_items (requested_by_user_id);
CREATE INDEX idx_want_to_buy_items_approved_by_user_id ON public.want_to_buy_items (approved_by_user_id);
CREATE INDEX idx_want_to_buy_items_linked_expense_id ON public.want_to_buy_items (linked_expense_id);
CREATE INDEX idx_want_to_buy_items_month_id ON public.want_to_buy_items (month_id);
CREATE INDEX idx_notifications_family_id ON public.notifications (family_id);
CREATE INDEX idx_notifications_recipient_user_id ON public.notifications (recipient_user_id);
CREATE INDEX idx_notification_preferences_family_id ON public.notification_preferences (family_id);
CREATE INDEX idx_notification_preferences_user_id ON public.notification_preferences (user_id);
CREATE INDEX idx_activity_logs_family_id ON public.activity_logs (family_id);
CREATE INDEX idx_activity_logs_actor_user_id ON public.activity_logs (actor_user_id);
CREATE INDEX idx_money_sources_family_id ON public.money_sources (family_id);
CREATE INDEX idx_money_sources_managed_by_user_id ON public.money_sources (managed_by_user_id);
CREATE INDEX idx_money_source_transactions_money_source_id ON public.money_source_transactions (money_source_id);
CREATE INDEX idx_money_source_transactions_family_id ON public.money_source_transactions (family_id);
CREATE INDEX idx_money_source_transactions_created_by_user_id ON public.money_source_transactions (created_by_user_id);
CREATE INDEX idx_money_distributions_family_id ON public.money_distributions (family_id);
CREATE INDEX idx_money_distributions_money_source_id ON public.money_distributions (money_source_id);
CREATE INDEX idx_money_distributions_distributed_by_user_id ON public.money_distributions (distributed_by_user_id);
CREATE INDEX idx_money_distribution_lines_distribution_id ON public.money_distribution_lines (distribution_id);
CREATE INDEX idx_money_distribution_lines_recipient_user_id ON public.money_distribution_lines (recipient_user_id);
CREATE INDEX idx_family_theme_settings_updated_by_user_id ON public.family_theme_settings (updated_by_user_id);
CREATE INDEX idx_user_theme_overrides_family_id ON public.user_theme_overrides (family_id);

CREATE INDEX idx_expenses_family_expense_date_desc ON public.expenses (family_id, expense_date DESC);
CREATE INDEX idx_expenses_family_category_expense_date ON public.expenses (family_id, category_id, expense_date DESC);
CREATE INDEX idx_expenses_family_created_by_expense_date ON public.expenses (family_id, created_by_user_id, expense_date DESC);
CREATE INDEX idx_expenses_family_month_expense_date ON public.expenses (family_id, month_id, expense_date DESC);
CREATE INDEX idx_expenses_month_expense_date ON public.expenses (month_id, expense_date DESC);
CREATE INDEX idx_expense_categories_family_active_sort ON public.expense_categories (family_id, is_active, sort_order);
CREATE INDEX idx_expense_updates_expense_created_at_desc ON public.expense_updates (expense_id, created_at DESC);

CREATE INDEX idx_monthly_budgets_family_month_id ON public.monthly_budgets (family_id, month_id);
CREATE INDEX idx_monthly_budgets_month_category ON public.monthly_budgets (month_id, category_id);
CREATE INDEX idx_budget_alerts_family_enabled ON public.budget_alerts (family_id, is_enabled);

CREATE INDEX idx_notifications_recipient_read_created_at_desc ON public.notifications (recipient_user_id, is_read, created_at DESC);
CREATE INDEX idx_notifications_family_created_at_desc ON public.notifications (family_id, created_at DESC);
CREATE INDEX idx_notifications_unread_by_recipient ON public.notifications (recipient_user_id, created_at DESC) WHERE is_read = FALSE;

CREATE INDEX idx_family_members_family_user ON public.family_members (family_id, user_id);
CREATE INDEX idx_family_members_family_base_role ON public.family_members (family_id, base_role);
CREATE INDEX idx_family_members_active_by_family ON public.family_members (family_id, user_id) WHERE membership_status = 'active';
CREATE INDEX idx_member_permission_grants_active_by_member ON public.member_permission_grants (family_member_id) WHERE revoked_at IS NULL;
CREATE INDEX idx_member_permission_grants_active_member_permission ON public.member_permission_grants (family_member_id, permission_id) WHERE revoked_at IS NULL;
CREATE INDEX idx_permission_definitions_module ON public.permission_definitions (module);

CREATE INDEX idx_activity_logs_family_occurred_at_desc ON public.activity_logs (family_id, occurred_at DESC);
CREATE INDEX idx_activity_logs_family_entity ON public.activity_logs (family_id, entity_type, entity_id);
CREATE INDEX idx_activity_logs_actor_occurred_at_desc ON public.activity_logs (actor_user_id, occurred_at DESC);

CREATE INDEX idx_months_family_year_month ON public.months (family_id, month_year, month_number);
CREATE INDEX idx_months_family_current ON public.months (family_id) WHERE is_current = TRUE;
CREATE INDEX idx_expenses_month_id_filter ON public.expenses (month_id) WHERE month_id IS NOT NULL;
CREATE INDEX idx_monthly_budgets_month_id_filter ON public.monthly_budgets (month_id);
CREATE INDEX idx_want_to_buy_items_family_month_status ON public.want_to_buy_items (family_id, month_id, status);
CREATE INDEX idx_want_to_buy_month_priority ON public.want_to_buy_items (month_id, priority, created_at DESC);

CREATE INDEX idx_families_active ON public.families (id) WHERE status = 'active';
CREATE INDEX idx_family_invitations_pending ON public.family_invitations (family_id, email) WHERE status = 'pending';
CREATE INDEX idx_expense_categories_family_active ON public.expense_categories (family_id, sort_order) WHERE is_active = TRUE;
CREATE INDEX idx_want_to_buy_items_family_status_priority ON public.want_to_buy_items (family_id, status, priority);
CREATE INDEX idx_want_to_buy_items_family_requested_by ON public.want_to_buy_items (family_id, requested_by_user_id);
CREATE INDEX idx_money_sources_family_active ON public.money_sources (family_id, name) WHERE is_active = TRUE;
CREATE INDEX idx_money_source_transactions_source_created_at_desc ON public.money_source_transactions (money_source_id, created_at DESC);
CREATE INDEX idx_money_distributions_family_distribution_date_desc ON public.money_distributions (family_id, distribution_date DESC);
CREATE INDEX idx_money_distributions_completed_by_family ON public.money_distributions (family_id, distribution_date DESC) WHERE status = 'completed';
CREATE INDEX idx_money_distribution_lines_recipient_status ON public.money_distribution_lines (recipient_user_id, status);
CREATE INDEX idx_want_to_buy_items_open_by_family ON public.want_to_buy_items (family_id, priority, target_date) WHERE status IN ('idea', 'approved', 'saving');

-- ============================================================================
-- 6. Functions
-- ============================================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_profile_on_signup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data ->> 'display_name',
      NEW.raw_user_meta_data ->> 'full_name',
      NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), '')
    )
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.has_permission(
  p_family_id       UUID,
  p_permission_key  TEXT,
  p_user_id         UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_member            public.family_members%ROWTYPE;
  v_permission_id     UUID;
  v_has_role_default  BOOLEAN;
  v_has_grant         BOOLEAN;
BEGIN
  IF p_user_id IS NULL OR p_family_id IS NULL OR p_permission_key IS NULL THEN
    RETURN FALSE;
  END IF;

  SELECT * INTO v_member
  FROM public.family_members fm
  WHERE fm.family_id = p_family_id
    AND fm.user_id = p_user_id
    AND fm.membership_status = 'active'
  LIMIT 1;

  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF v_member.base_role = 'owner' THEN RETURN TRUE; END IF;

  SELECT pd.id INTO v_permission_id
  FROM public.permission_definitions pd
  WHERE pd.permission_key = p_permission_key AND pd.is_assignable = TRUE
  LIMIT 1;

  IF NOT FOUND THEN RETURN FALSE; END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.role_default_permissions rdp
    WHERE rdp.base_role = v_member.base_role AND rdp.permission_id = v_permission_id
  ) INTO v_has_role_default;

  IF v_has_role_default THEN RETURN TRUE; END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.member_permission_grants mpg
    WHERE mpg.family_member_id = v_member.id
      AND mpg.permission_id = v_permission_id
      AND mpg.revoked_at IS NULL
  ) INTO v_has_grant;

  RETURN v_has_grant;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_notification(
  p_family_id           UUID,
  p_recipient_user_id   UUID,
  p_type                TEXT,
  p_title               TEXT,
  p_body                TEXT DEFAULT NULL,
  p_payload             JSONB DEFAULT '{}'::JSONB,
  p_source_module       TEXT DEFAULT NULL,
  p_source_entity_type  TEXT DEFAULT NULL,
  p_source_entity_id    UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_notification_id UUID;
BEGIN
  INSERT INTO public.notifications (
    family_id, recipient_user_id, type, title, body, payload,
    source_module, source_entity_type, source_entity_id
  ) VALUES (
    p_family_id, p_recipient_user_id, p_type, p_title, p_body,
    COALESCE(p_payload, '{}'::JSONB), p_source_module, p_source_entity_type, p_source_entity_id
  ) RETURNING id INTO v_notification_id;
  RETURN v_notification_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.log_activity(
  p_family_id     UUID,
  p_actor_user_id UUID,
  p_action        TEXT,
  p_entity_type   TEXT,
  p_entity_id     UUID,
  p_summary       TEXT,
  p_changes       JSONB DEFAULT '{}'::JSONB,
  p_ip_address    INET DEFAULT NULL,
  p_user_agent    TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_activity_log_id UUID;
BEGIN
  INSERT INTO public.activity_logs (
    family_id, actor_user_id, action, entity_type, entity_id,
    summary, changes, ip_address, user_agent, occurred_at
  ) VALUES (
    p_family_id, p_actor_user_id, p_action, p_entity_type, p_entity_id,
    p_summary, COALESCE(p_changes, '{}'::JSONB), p_ip_address, p_user_agent, NOW()
  ) RETURNING id INTO v_activity_log_id;
  RETURN v_activity_log_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_expense_update_history()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_old_data JSONB; v_new_data JSONB;
BEGIN
  IF TG_OP <> 'UPDATE' THEN RETURN NEW; END IF;
  v_old_data := to_jsonb(OLD) - 'updated_at';
  v_new_data := to_jsonb(NEW) - 'updated_at';
  IF v_old_data = v_new_data THEN RETURN NEW; END IF;
  INSERT INTO public.expense_updates (expense_id, updated_by_user_id, old_data, new_data)
  VALUES (NEW.id, auth.uid(), to_jsonb(OLD), to_jsonb(NEW));
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_month_total_expenses(
  p_month_id   UUID,
  p_family_id  UUID DEFAULT NULL
)
RETURNS NUMERIC(14, 2)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE v_month_family_id UUID; v_total NUMERIC(14, 2);
BEGIN
  IF p_month_id IS NULL THEN RETURN 0; END IF;
  SELECT m.family_id INTO v_month_family_id FROM public.months m WHERE m.id = p_month_id;
  IF NOT FOUND THEN RETURN 0; END IF;
  IF p_family_id IS NOT NULL AND v_month_family_id <> p_family_id THEN
    RAISE EXCEPTION 'Month % does not belong to family %', p_month_id, p_family_id;
  END IF;
  SELECT COALESCE(SUM(e.amount), 0) INTO v_total
  FROM public.expenses e
  WHERE e.month_id = p_month_id AND e.family_id = v_month_family_id;
  RETURN v_total;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_month_budget_usage(
  p_month_id   UUID,
  p_family_id  UUID
)
RETURNS TABLE (
  budget_id UUID, category_id UUID, category_name TEXT, month_id UUID,
  allocated_amount NUMERIC(14, 2), spent_amount NUMERIC(14, 2),
  remaining_amount NUMERIC(14, 2), usage_percent NUMERIC(7, 2)
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = public
AS $$
  SELECT mb.id, mb.category_id, ec.name, mb.month_id, mb.allocated_amount,
    COALESCE(SUM(e.amount), 0)::NUMERIC(14, 2),
    (mb.allocated_amount - COALESCE(SUM(e.amount), 0))::NUMERIC(14, 2),
    CASE WHEN mb.allocated_amount = 0 THEN 0::NUMERIC(7, 2)
      ELSE ROUND((COALESCE(SUM(e.amount), 0) / mb.allocated_amount) * 100, 2)::NUMERIC(7, 2) END
  FROM public.monthly_budgets mb
  INNER JOIN public.expense_categories ec ON ec.id = mb.category_id
  LEFT JOIN public.expenses e ON e.month_id = mb.month_id AND e.category_id = mb.category_id AND e.family_id = mb.family_id
  WHERE mb.month_id = p_month_id AND mb.family_id = p_family_id
  GROUP BY mb.id, mb.category_id, ec.name, mb.month_id, mb.allocated_amount
  ORDER BY ec.name;
$$;

CREATE OR REPLACE FUNCTION public.grant_member_permission(
  p_family_member_id    UUID,
  p_permission_key      TEXT,
  p_granted_by_user_id  UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_permission_id UUID; v_family_id UUID; v_member_user_id UUID;
  v_grant_exists BOOLEAN; v_grant_id UUID;
BEGIN
  IF p_family_member_id IS NULL OR p_permission_key IS NULL OR p_granted_by_user_id IS NULL THEN
    RETURN FALSE;
  END IF;
  SELECT pd.id INTO v_permission_id FROM public.permission_definitions pd
  WHERE pd.permission_key = p_permission_key AND pd.is_assignable = TRUE LIMIT 1;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  SELECT fm.family_id, fm.user_id INTO v_family_id, v_member_user_id
  FROM public.family_members fm
  WHERE fm.id = p_family_member_id AND fm.membership_status = 'active' LIMIT 1;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  SELECT EXISTS (
    SELECT 1 FROM public.member_permission_grants mpg
    WHERE mpg.family_member_id = p_family_member_id AND mpg.permission_id = v_permission_id AND mpg.revoked_at IS NULL
  ) INTO v_grant_exists;
  IF v_grant_exists THEN RETURN FALSE; END IF;
  INSERT INTO public.member_permission_grants (family_member_id, permission_id, granted_by_user_id, granted_at)
  VALUES (p_family_member_id, v_permission_id, p_granted_by_user_id, NOW())
  RETURNING id INTO v_grant_id;
  PERFORM public.log_activity(
    v_family_id, p_granted_by_user_id, 'permission.granted', 'member_permission_grants', v_grant_id,
    format('Permission %s granted to family member %s', p_permission_key, v_member_user_id),
    jsonb_build_object('family_member_id', p_family_member_id, 'permission_key', p_permission_key,
      'permission_id', v_permission_id, 'granted_by_user_id', p_granted_by_user_id)
  );
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION public.notify_owner_on_expense_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_owner_user_id UUID; v_old_data JSONB; v_new_data JSONB;
BEGIN
  IF TG_OP <> 'UPDATE' THEN RETURN NEW; END IF;
  v_old_data := to_jsonb(OLD) - 'updated_at';
  v_new_data := to_jsonb(NEW) - 'updated_at';
  IF v_old_data = v_new_data THEN RETURN NEW; END IF;
  SELECT f.owner_user_id INTO v_owner_user_id FROM public.families f WHERE f.id = NEW.family_id;
  IF v_owner_user_id IS NULL THEN RETURN NEW; END IF;
  IF auth.uid() IS NOT NULL AND auth.uid() = v_owner_user_id THEN RETURN NEW; END IF;
  PERFORM public.create_notification(
    NEW.family_id, v_owner_user_id, 'expense.updated',
    format('Expense updated: %s', NEW.title),
    format('Expense "%s" was updated.', NEW.title),
    jsonb_build_object('expense_id', NEW.id, 'old_data', to_jsonb(OLD), 'new_data', to_jsonb(NEW), 'updated_by_user_id', auth.uid()),
    'expense_management', 'expenses', NEW.id
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_log_expense_activity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'expense.created', 'expenses', NEW.id,
      format('Expense "%s" created', NEW.title), jsonb_build_object('new', to_jsonb(NEW)));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF to_jsonb(OLD) - 'updated_at' = to_jsonb(NEW) - 'updated_at' THEN RETURN NEW; END IF;
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'expense.updated', 'expenses', NEW.id,
      format('Expense "%s" updated', NEW.title), jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM public.log_activity(OLD.family_id, auth.uid(), 'expense.deleted', 'expenses', OLD.id,
      format('Expense "%s" deleted', OLD.title), jsonb_build_object('old', to_jsonb(OLD)));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_log_monthly_budget_activity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'budget.created', 'monthly_budgets', NEW.id,
      'Monthly budget created', jsonb_build_object('new', to_jsonb(NEW)));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF to_jsonb(OLD) - 'updated_at' = to_jsonb(NEW) - 'updated_at' THEN RETURN NEW; END IF;
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'budget.updated', 'monthly_budgets', NEW.id,
      'Monthly budget updated', jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM public.log_activity(OLD.family_id, auth.uid(), 'budget.deleted', 'monthly_budgets', OLD.id,
      'Monthly budget deleted', jsonb_build_object('old', to_jsonb(OLD)));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_log_want_to_buy_activity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'want_to_buy.created', 'want_to_buy_items', NEW.id,
      format('Want to buy item "%s" created', NEW.title), jsonb_build_object('new', to_jsonb(NEW)));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF to_jsonb(OLD) - 'updated_at' = to_jsonb(NEW) - 'updated_at' THEN RETURN NEW; END IF;
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'want_to_buy.updated', 'want_to_buy_items', NEW.id,
      format('Want to buy item "%s" updated', NEW.title), jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM public.log_activity(OLD.family_id, auth.uid(), 'want_to_buy.deleted', 'want_to_buy_items', OLD.id,
      format('Want to buy item "%s" deleted', OLD.title), jsonb_build_object('old', to_jsonb(OLD)));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_log_family_member_activity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'member.added', 'family_members', NEW.id,
      'Family member added', jsonb_build_object('new', to_jsonb(NEW)));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF to_jsonb(OLD) - 'updated_at' = to_jsonb(NEW) - 'updated_at' THEN RETURN NEW; END IF;
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'member.updated', 'family_members', NEW.id,
      'Family member updated', jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)));
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_log_permission_grant_activity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_family_id UUID;
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.revoked_at IS NULL AND NEW.revoked_at IS NOT NULL THEN
    SELECT fm.family_id INTO v_family_id FROM public.family_members fm WHERE fm.id = NEW.family_member_id;
    PERFORM public.log_activity(v_family_id, auth.uid(), 'permission.revoked', 'member_permission_grants', NEW.id,
      'Permission grant revoked', jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)));
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_log_money_distribution_activity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'completed' THEN
    PERFORM public.log_activity(NEW.family_id, auth.uid(), 'money_distribution.completed', 'money_distributions', NEW.id,
      'Money distribution completed', jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)));
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.notify_member_on_permission_granted()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_family_id UUID; v_user_id UUID; v_permission_key TEXT;
BEGIN
  IF TG_OP <> 'INSERT' OR NEW.revoked_at IS NOT NULL THEN RETURN NEW; END IF;
  SELECT fm.family_id, fm.user_id INTO v_family_id, v_user_id
  FROM public.family_members fm WHERE fm.id = NEW.family_member_id;
  IF v_family_id IS NULL OR v_user_id IS NULL THEN RETURN NEW; END IF;
  SELECT pd.permission_key INTO v_permission_key FROM public.permission_definitions pd WHERE pd.id = NEW.permission_id;
  PERFORM public.create_notification(
    v_family_id, v_user_id, 'permission.granted', 'New permission granted',
    format('You have been granted the %s permission.', COALESCE(v_permission_key, 'requested')),
    jsonb_build_object('permission_id', NEW.permission_id, 'permission_key', v_permission_key,
      'granted_by_user_id', NEW.granted_by_user_id, 'family_member_id', NEW.family_member_id, 'grant_id', NEW.id),
    'permissions', 'member_permission_grants', NEW.id
  );
  RETURN NEW;
END;
$$;

-- ============================================================================
-- 7. Triggers
-- ============================================================================

CREATE TRIGGER trg_profiles_set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_families_set_updated_at BEFORE UPDATE ON public.families FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_family_members_set_updated_at BEFORE UPDATE ON public.family_members FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_family_invitations_set_updated_at BEFORE UPDATE ON public.family_invitations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_member_permission_grants_set_updated_at BEFORE UPDATE ON public.member_permission_grants FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_expense_categories_set_updated_at BEFORE UPDATE ON public.expense_categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_expenses_set_updated_at BEFORE UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_expense_attachments_set_updated_at BEFORE UPDATE ON public.expense_attachments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_expense_tags_set_updated_at BEFORE UPDATE ON public.expense_tags FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_monthly_budgets_set_updated_at BEFORE UPDATE ON public.monthly_budgets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_budget_alerts_set_updated_at BEFORE UPDATE ON public.budget_alerts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_want_to_buy_items_set_updated_at BEFORE UPDATE ON public.want_to_buy_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_notifications_set_updated_at BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_notification_preferences_set_updated_at BEFORE UPDATE ON public.notification_preferences FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_money_sources_set_updated_at BEFORE UPDATE ON public.money_sources FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_money_distributions_set_updated_at BEFORE UPDATE ON public.money_distributions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_money_distribution_lines_set_updated_at BEFORE UPDATE ON public.money_distribution_lines FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_family_theme_settings_set_updated_at BEFORE UPDATE ON public.family_theme_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_user_theme_overrides_set_updated_at BEFORE UPDATE ON public.user_theme_overrides FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_months_set_updated_at BEFORE UPDATE ON public.months FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_auth_users_create_profile AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.create_profile_on_signup();

CREATE TRIGGER trg_expenses_create_update_history AFTER UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.create_expense_update_history();
CREATE TRIGGER trg_expenses_notify_owner_on_update AFTER UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.notify_owner_on_expense_update();

CREATE TRIGGER trg_expenses_log_activity AFTER INSERT OR UPDATE OR DELETE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.trg_log_expense_activity();
CREATE TRIGGER trg_monthly_budgets_log_activity AFTER INSERT OR UPDATE OR DELETE ON public.monthly_budgets FOR EACH ROW EXECUTE FUNCTION public.trg_log_monthly_budget_activity();
CREATE TRIGGER trg_want_to_buy_items_log_activity AFTER INSERT OR UPDATE OR DELETE ON public.want_to_buy_items FOR EACH ROW EXECUTE FUNCTION public.trg_log_want_to_buy_activity();
CREATE TRIGGER trg_family_members_log_activity AFTER INSERT OR UPDATE ON public.family_members FOR EACH ROW EXECUTE FUNCTION public.trg_log_family_member_activity();
CREATE TRIGGER trg_member_permission_grants_log_activity AFTER UPDATE ON public.member_permission_grants FOR EACH ROW EXECUTE FUNCTION public.trg_log_permission_grant_activity();
CREATE TRIGGER trg_money_distributions_log_activity AFTER UPDATE ON public.money_distributions FOR EACH ROW EXECUTE FUNCTION public.trg_log_money_distribution_activity();
CREATE TRIGGER trg_member_permission_grants_notify_on_insert AFTER INSERT ON public.member_permission_grants FOR EACH ROW EXECUTE FUNCTION public.notify_member_on_permission_granted();

-- ============================================================================
-- 8. Seed Data
-- ============================================================================

INSERT INTO public.permission_definitions (permission_key, module, description, is_assignable)
VALUES
  ('add_budget', 'Monthly Budgets', 'Create and update monthly category budgets.', TRUE),
  ('view_total_spending', 'Expense Management', 'View aggregated family spending totals and budget usage.', TRUE),
  ('add_money', 'Money Distribution', 'Add funds and create money distributions.', TRUE),
  ('view_transactions', 'Expense Management', 'View individual family expense transactions.', TRUE),
  ('view_notifications', 'Notifications', 'View in-app notifications for the family.', TRUE),
  ('manage_users', 'Permissions', 'Invite, manage, and assign permissions to family members.', TRUE),
  ('manage_want_to_buy', 'Want To Buy', 'Create, update, approve, and manage want-to-buy items.', TRUE),
  ('customize_theme', 'Theme Customization', 'Customize family theme and appearance settings.', TRUE);

INSERT INTO public.role_default_permissions (base_role, permission_id, scope)
SELECT 'owner'::public.base_role, pd.id, 'family'
FROM public.permission_definitions pd;


-- ============================================================================
-- 9. RLS Enable
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permission_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_default_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_permission_grants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_tag_map ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monthly_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budget_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.want_to_buy_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.money_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.money_source_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.money_distributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.money_distribution_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_theme_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_theme_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.months ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 10. Policies
-- ============================================================================

CREATE POLICY profiles_select_self_and_family_members ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid() OR EXISTS (SELECT 1 FROM public.family_members fm_self INNER JOIN public.family_members fm_other ON fm_other.family_id = fm_self.family_id WHERE fm_self.user_id = auth.uid() AND fm_self.membership_status = 'active' AND fm_other.user_id = profiles.id AND fm_other.membership_status = 'active'));
CREATE POLICY profiles_insert_self ON public.profiles FOR INSERT TO authenticated WITH CHECK (id = auth.uid());
CREATE POLICY profiles_update_self ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());
COMMENT ON POLICY profiles_select_self_and_family_members ON public.profiles IS 'Users can view their own profile and profiles of active members in the same family.';
COMMENT ON POLICY profiles_insert_self ON public.profiles IS 'Users can insert only their own profile row.';
COMMENT ON POLICY profiles_update_self ON public.profiles IS 'Users can update only their own profile row.';

CREATE POLICY families_select_active_members ON public.families FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = families.id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY families_insert_as_owner ON public.families FOR INSERT TO authenticated WITH CHECK (owner_user_id = auth.uid());
CREATE POLICY families_update_owner ON public.families FOR UPDATE TO authenticated USING (owner_user_id = auth.uid()) WITH CHECK (owner_user_id = auth.uid());
CREATE POLICY families_delete_owner ON public.families FOR DELETE TO authenticated USING (owner_user_id = auth.uid());
COMMENT ON POLICY families_select_active_members ON public.families IS 'Active family members can view their family record.';
COMMENT ON POLICY families_insert_as_owner ON public.families IS 'Authenticated users can create a family only when they are the owner.';
COMMENT ON POLICY families_update_owner ON public.families IS 'Only the family owner can update the family record.';
COMMENT ON POLICY families_delete_owner ON public.families IS 'Only the family owner can delete the family record.';

CREATE POLICY family_members_select_active_members ON public.family_members FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = family_members.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY family_members_insert_owner ON public.family_members FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_members.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY family_members_update_owner ON public.family_members FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_members.family_id AND f.owner_user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_members.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY family_members_delete_owner ON public.family_members FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_members.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY family_members_select_active_members ON public.family_members IS 'Active family members can view membership records in their family.';
COMMENT ON POLICY family_members_insert_owner ON public.family_members IS 'Only the family owner can add family members.';
COMMENT ON POLICY family_members_update_owner ON public.family_members IS 'Only the family owner can update family membership records.';
COMMENT ON POLICY family_members_delete_owner ON public.family_members IS 'Only the family owner can delete family membership records.';

CREATE POLICY family_invitations_select_owner_or_invitee ON public.family_invitations FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_invitations.family_id AND f.owner_user_id = auth.uid()) OR lower(family_invitations.email::text) = lower(auth.jwt() ->> 'email'));
CREATE POLICY family_invitations_insert_owner ON public.family_invitations FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_invitations.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY family_invitations_update_owner_or_invitee ON public.family_invitations FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_invitations.family_id AND f.owner_user_id = auth.uid()) OR lower(family_invitations.email::text) = lower(auth.jwt() ->> 'email')) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_invitations.family_id AND f.owner_user_id = auth.uid()) OR lower(family_invitations.email::text) = lower(auth.jwt() ->> 'email'));
CREATE POLICY family_invitations_delete_owner ON public.family_invitations FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_invitations.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY family_invitations_select_owner_or_invitee ON public.family_invitations IS 'Family owners and invited users can view relevant invitations.';
COMMENT ON POLICY family_invitations_insert_owner ON public.family_invitations IS 'Only the family owner can create invitations.';
COMMENT ON POLICY family_invitations_update_owner_or_invitee ON public.family_invitations IS 'Family owners and invited users can update relevant invitations.';
COMMENT ON POLICY family_invitations_delete_owner ON public.family_invitations IS 'Only the family owner can delete invitations.';

CREATE POLICY permission_definitions_select_authenticated ON public.permission_definitions FOR SELECT TO authenticated USING (TRUE);
COMMENT ON POLICY permission_definitions_select_authenticated ON public.permission_definitions IS 'All authenticated users can read the permission catalog.';

CREATE POLICY role_default_permissions_select_authenticated ON public.role_default_permissions FOR SELECT TO authenticated USING (TRUE);
COMMENT ON POLICY role_default_permissions_select_authenticated ON public.role_default_permissions IS 'All authenticated users can read default role permission mappings.';

CREATE POLICY member_permission_grants_select_owner ON public.member_permission_grants FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm INNER JOIN public.families f ON f.id = fm.family_id WHERE fm.id = member_permission_grants.family_member_id AND f.owner_user_id = auth.uid()));
CREATE POLICY member_permission_grants_insert_owner ON public.member_permission_grants FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.family_members fm INNER JOIN public.families f ON f.id = fm.family_id WHERE fm.id = member_permission_grants.family_member_id AND f.owner_user_id = auth.uid()));
CREATE POLICY member_permission_grants_update_owner ON public.member_permission_grants FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm INNER JOIN public.families f ON f.id = fm.family_id WHERE fm.id = member_permission_grants.family_member_id AND f.owner_user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.family_members fm INNER JOIN public.families f ON f.id = fm.family_id WHERE fm.id = member_permission_grants.family_member_id AND f.owner_user_id = auth.uid()));
CREATE POLICY member_permission_grants_delete_owner ON public.member_permission_grants FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm INNER JOIN public.families f ON f.id = fm.family_id WHERE fm.id = member_permission_grants.family_member_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY member_permission_grants_select_owner ON public.member_permission_grants IS 'Only the family owner can view permission grants.';
COMMENT ON POLICY member_permission_grants_insert_owner ON public.member_permission_grants IS 'Only the family owner can create permission grants.';
COMMENT ON POLICY member_permission_grants_update_owner ON public.member_permission_grants IS 'Only the family owner can update permission grants.';
COMMENT ON POLICY member_permission_grants_delete_owner ON public.member_permission_grants IS 'Only the family owner can delete permission grants.';

CREATE POLICY expense_categories_select_active_members ON public.expense_categories FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = expense_categories.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY expense_categories_insert_owner ON public.expense_categories FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expense_categories.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY expense_categories_update_owner ON public.expense_categories FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expense_categories.family_id AND f.owner_user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expense_categories.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY expense_categories_delete_owner ON public.expense_categories FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expense_categories.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY expense_categories_select_active_members ON public.expense_categories IS 'Active family members can view expense categories.';
COMMENT ON POLICY expense_categories_insert_owner ON public.expense_categories IS 'Only the family owner can create expense categories.';
COMMENT ON POLICY expense_categories_update_owner ON public.expense_categories IS 'Only the family owner can update expense categories.';
COMMENT ON POLICY expense_categories_delete_owner ON public.expense_categories IS 'Only the family owner can delete expense categories.';

CREATE POLICY expenses_select_owner_own_or_view_transactions ON public.expenses FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expenses.family_id AND f.owner_user_id = auth.uid()) OR expenses.created_by_user_id = auth.uid() OR public.has_permission(expenses.family_id, 'view_transactions', auth.uid()));
CREATE POLICY expenses_insert_active_members_own ON public.expenses FOR INSERT TO authenticated WITH CHECK (created_by_user_id = auth.uid() AND EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = expenses.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY expenses_update_owner_or_own ON public.expenses FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expenses.family_id AND f.owner_user_id = auth.uid()) OR expenses.created_by_user_id = auth.uid()) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expenses.family_id AND f.owner_user_id = auth.uid()) OR expenses.created_by_user_id = auth.uid());
CREATE POLICY expenses_delete_owner_or_own ON public.expenses FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expenses.family_id AND f.owner_user_id = auth.uid()) OR expenses.created_by_user_id = auth.uid());
COMMENT ON POLICY expenses_select_owner_own_or_view_transactions ON public.expenses IS 'Owners, expense creators, and users with view_transactions can read expenses.';
COMMENT ON POLICY expenses_insert_active_members_own ON public.expenses IS 'Active family members can create only their own expenses.';
COMMENT ON POLICY expenses_update_owner_or_own ON public.expenses IS 'Owners can update any family expense; regular users can update only their own.';
COMMENT ON POLICY expenses_delete_owner_or_own ON public.expenses IS 'Owners can delete any family expense; regular users can delete only their own.';

CREATE POLICY expense_attachments_select_via_expense_access ON public.expense_attachments FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_attachments.expense_id AND (EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid()) OR e.created_by_user_id = auth.uid() OR public.has_permission(e.family_id, 'view_transactions', auth.uid()))));
CREATE POLICY expense_attachments_insert_own_expense ON public.expense_attachments FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_attachments.expense_id AND (e.created_by_user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid()))));
CREATE POLICY expense_attachments_update_own_expense_or_owner ON public.expense_attachments FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_attachments.expense_id AND (e.created_by_user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid())))) WITH CHECK (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_attachments.expense_id AND (e.created_by_user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid()))));
CREATE POLICY expense_attachments_delete_own_expense_or_owner ON public.expense_attachments FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_attachments.expense_id AND (e.created_by_user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid()))));
COMMENT ON POLICY expense_attachments_select_via_expense_access ON public.expense_attachments IS 'Attachment access follows parent expense visibility rules.';
COMMENT ON POLICY expense_attachments_insert_own_expense ON public.expense_attachments IS 'Users can add attachments to their own expenses; owners can add to any family expense.';
COMMENT ON POLICY expense_attachments_update_own_expense_or_owner ON public.expense_attachments IS 'Users can update attachments on their own expenses; owners can update any family attachment.';
COMMENT ON POLICY expense_attachments_delete_own_expense_or_owner ON public.expense_attachments IS 'Users can delete attachments on their own expenses; owners can delete any family attachment.';

CREATE POLICY expense_tags_select_active_members ON public.expense_tags FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = expense_tags.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY expense_tags_insert_owner ON public.expense_tags FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expense_tags.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY expense_tags_update_owner ON public.expense_tags FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expense_tags.family_id AND f.owner_user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expense_tags.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY expense_tags_delete_owner ON public.expense_tags FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = expense_tags.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY expense_tags_select_active_members ON public.expense_tags IS 'Active family members can view expense tags.';
COMMENT ON POLICY expense_tags_insert_owner ON public.expense_tags IS 'Only the family owner can create expense tags.';
COMMENT ON POLICY expense_tags_update_owner ON public.expense_tags IS 'Only the family owner can update expense tags.';
COMMENT ON POLICY expense_tags_delete_owner ON public.expense_tags IS 'Only the family owner can delete expense tags.';

CREATE POLICY expense_tag_map_select_via_expense_access ON public.expense_tag_map FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_tag_map.expense_id AND (EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid()) OR e.created_by_user_id = auth.uid() OR public.has_permission(e.family_id, 'view_transactions', auth.uid()))));
CREATE POLICY expense_tag_map_insert_own_expense_or_owner ON public.expense_tag_map FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_tag_map.expense_id AND (e.created_by_user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid()))));
CREATE POLICY expense_tag_map_delete_own_expense_or_owner ON public.expense_tag_map FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_tag_map.expense_id AND (e.created_by_user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid()))));
COMMENT ON POLICY expense_tag_map_select_via_expense_access ON public.expense_tag_map IS 'Tag mappings are visible when the parent expense is visible.';
COMMENT ON POLICY expense_tag_map_insert_own_expense_or_owner ON public.expense_tag_map IS 'Users can tag their own expenses; owners can tag any family expense.';
COMMENT ON POLICY expense_tag_map_delete_own_expense_or_owner ON public.expense_tag_map IS 'Users can remove tags from their own expenses; owners can remove any family tag mapping.';

CREATE POLICY expense_updates_select_via_expense_access ON public.expense_updates FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_updates.expense_id AND (EXISTS (SELECT 1 FROM public.families f WHERE f.id = e.family_id AND f.owner_user_id = auth.uid()) OR e.created_by_user_id = auth.uid() OR public.has_permission(e.family_id, 'view_transactions', auth.uid()))));
CREATE POLICY expense_updates_deny_authenticated_insert ON public.expense_updates AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK (FALSE);
CREATE POLICY expense_updates_deny_authenticated_update ON public.expense_updates AS RESTRICTIVE FOR UPDATE TO authenticated USING (FALSE) WITH CHECK (FALSE);
CREATE POLICY expense_updates_deny_authenticated_delete ON public.expense_updates AS RESTRICTIVE FOR DELETE TO authenticated USING (FALSE);
COMMENT ON POLICY expense_updates_select_via_expense_access ON public.expense_updates IS 'Expense update history is visible when the parent expense is visible.';
COMMENT ON POLICY expense_updates_deny_authenticated_insert ON public.expense_updates IS 'Explicit deny: authenticated users cannot insert expense update history directly.';
COMMENT ON POLICY expense_updates_deny_authenticated_update ON public.expense_updates IS 'Explicit deny: authenticated users cannot update expense update history directly.';
COMMENT ON POLICY expense_updates_deny_authenticated_delete ON public.expense_updates IS 'Explicit deny: authenticated users cannot delete expense update history directly.';

CREATE POLICY monthly_budgets_select_active_members ON public.monthly_budgets FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = monthly_budgets.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY monthly_budgets_insert_owner_or_add_budget ON public.monthly_budgets FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = monthly_budgets.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(monthly_budgets.family_id, 'add_budget', auth.uid()));
CREATE POLICY monthly_budgets_update_owner_or_add_budget ON public.monthly_budgets FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = monthly_budgets.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(monthly_budgets.family_id, 'add_budget', auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = monthly_budgets.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(monthly_budgets.family_id, 'add_budget', auth.uid()));
CREATE POLICY monthly_budgets_delete_owner_or_add_budget ON public.monthly_budgets FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = monthly_budgets.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(monthly_budgets.family_id, 'add_budget', auth.uid()));
COMMENT ON POLICY monthly_budgets_select_active_members ON public.monthly_budgets IS 'All active family members can view monthly budgets.';
COMMENT ON POLICY monthly_budgets_insert_owner_or_add_budget ON public.monthly_budgets IS 'Owners and users with add_budget permission can create monthly budgets.';
COMMENT ON POLICY monthly_budgets_update_owner_or_add_budget ON public.monthly_budgets IS 'Owners and users with add_budget permission can update monthly budgets.';
COMMENT ON POLICY monthly_budgets_delete_owner_or_add_budget ON public.monthly_budgets IS 'Owners and users with add_budget permission can delete monthly budgets.';

CREATE POLICY budget_alerts_select_active_members ON public.budget_alerts FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = budget_alerts.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY budget_alerts_insert_owner_or_add_budget ON public.budget_alerts FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = budget_alerts.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(budget_alerts.family_id, 'add_budget', auth.uid()));
CREATE POLICY budget_alerts_update_owner_or_add_budget ON public.budget_alerts FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = budget_alerts.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(budget_alerts.family_id, 'add_budget', auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = budget_alerts.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(budget_alerts.family_id, 'add_budget', auth.uid()));
CREATE POLICY budget_alerts_delete_owner_or_add_budget ON public.budget_alerts FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = budget_alerts.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(budget_alerts.family_id, 'add_budget', auth.uid()));
COMMENT ON POLICY budget_alerts_select_active_members ON public.budget_alerts IS 'All active family members can view budget alerts.';
COMMENT ON POLICY budget_alerts_insert_owner_or_add_budget ON public.budget_alerts IS 'Owners and users with add_budget permission can create budget alerts.';
COMMENT ON POLICY budget_alerts_update_owner_or_add_budget ON public.budget_alerts IS 'Owners and users with add_budget permission can update budget alerts.';
COMMENT ON POLICY budget_alerts_delete_owner_or_add_budget ON public.budget_alerts IS 'Owners and users with add_budget permission can delete budget alerts.';

CREATE POLICY want_to_buy_items_select_active_members ON public.want_to_buy_items FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = want_to_buy_items.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY want_to_buy_items_insert_active_members ON public.want_to_buy_items FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = want_to_buy_items.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY want_to_buy_items_update_owner_or_creator ON public.want_to_buy_items FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = want_to_buy_items.family_id AND f.owner_user_id = auth.uid()) OR want_to_buy_items.requested_by_user_id = auth.uid() OR public.has_permission(want_to_buy_items.family_id, 'manage_want_to_buy', auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = want_to_buy_items.family_id AND f.owner_user_id = auth.uid()) OR want_to_buy_items.requested_by_user_id = auth.uid() OR public.has_permission(want_to_buy_items.family_id, 'manage_want_to_buy', auth.uid()));
CREATE POLICY want_to_buy_items_delete_owner_or_creator ON public.want_to_buy_items FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = want_to_buy_items.family_id AND f.owner_user_id = auth.uid()) OR want_to_buy_items.requested_by_user_id = auth.uid() OR public.has_permission(want_to_buy_items.family_id, 'manage_want_to_buy', auth.uid()));
COMMENT ON POLICY want_to_buy_items_select_active_members ON public.want_to_buy_items IS 'All active family members can view want-to-buy items.';
COMMENT ON POLICY want_to_buy_items_insert_active_members ON public.want_to_buy_items IS 'All active family members can create want-to-buy items.';
COMMENT ON POLICY want_to_buy_items_update_owner_or_creator ON public.want_to_buy_items IS 'Owners, item creators, and users with manage_want_to_buy can update items.';
COMMENT ON POLICY want_to_buy_items_delete_owner_or_creator ON public.want_to_buy_items IS 'Owners, item creators, and users with manage_want_to_buy can delete items.';

CREATE POLICY notifications_select_own ON public.notifications FOR SELECT TO authenticated USING (recipient_user_id = auth.uid());
CREATE POLICY notifications_update_own ON public.notifications FOR UPDATE TO authenticated USING (recipient_user_id = auth.uid()) WITH CHECK (recipient_user_id = auth.uid());
CREATE POLICY notifications_delete_own ON public.notifications FOR DELETE TO authenticated USING (recipient_user_id = auth.uid());
CREATE POLICY notifications_deny_authenticated_insert ON public.notifications AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK (FALSE);
COMMENT ON POLICY notifications_select_own ON public.notifications IS 'Users can view only their own notifications.';
COMMENT ON POLICY notifications_update_own ON public.notifications IS 'Users can update only their own notifications, such as marking them read.';
COMMENT ON POLICY notifications_delete_own ON public.notifications IS 'Users can delete only their own notifications.';
COMMENT ON POLICY notifications_deny_authenticated_insert ON public.notifications IS 'Explicit deny: authenticated users cannot insert notifications directly.';

CREATE POLICY notification_preferences_select_own ON public.notification_preferences FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY notification_preferences_insert_own ON public.notification_preferences FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY notification_preferences_update_own ON public.notification_preferences FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY notification_preferences_delete_own ON public.notification_preferences FOR DELETE TO authenticated USING (user_id = auth.uid());
COMMENT ON POLICY notification_preferences_select_own ON public.notification_preferences IS 'Users can view only their own notification preferences.';
COMMENT ON POLICY notification_preferences_insert_own ON public.notification_preferences IS 'Users can create only their own notification preferences.';
COMMENT ON POLICY notification_preferences_update_own ON public.notification_preferences IS 'Users can update only their own notification preferences.';
COMMENT ON POLICY notification_preferences_delete_own ON public.notification_preferences IS 'Users can delete only their own notification preferences.';

CREATE POLICY activity_logs_select_owner ON public.activity_logs FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = activity_logs.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY activity_logs_deny_authenticated_insert ON public.activity_logs AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK (FALSE);
CREATE POLICY activity_logs_deny_authenticated_update ON public.activity_logs AS RESTRICTIVE FOR UPDATE TO authenticated USING (FALSE) WITH CHECK (FALSE);
CREATE POLICY activity_logs_deny_authenticated_delete ON public.activity_logs AS RESTRICTIVE FOR DELETE TO authenticated USING (FALSE);
COMMENT ON POLICY activity_logs_select_owner ON public.activity_logs IS 'Only the family owner can view activity logs.';
COMMENT ON POLICY activity_logs_deny_authenticated_insert ON public.activity_logs IS 'Explicit deny: authenticated users cannot insert activity logs directly.';
COMMENT ON POLICY activity_logs_deny_authenticated_update ON public.activity_logs IS 'Explicit deny: authenticated users cannot update activity logs directly.';
COMMENT ON POLICY activity_logs_deny_authenticated_delete ON public.activity_logs IS 'Explicit deny: authenticated users cannot delete activity logs directly.';

CREATE POLICY money_sources_select_owner ON public.money_sources FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_sources.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_sources.family_id, 'add_money', auth.uid()));
CREATE POLICY money_sources_insert_owner ON public.money_sources FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_sources.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_sources.family_id, 'add_money', auth.uid()));
CREATE POLICY money_sources_update_owner ON public.money_sources FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_sources.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_sources.family_id, 'add_money', auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_sources.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_sources.family_id, 'add_money', auth.uid()));
CREATE POLICY money_sources_delete_owner ON public.money_sources FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_sources.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY money_sources_select_owner ON public.money_sources IS 'Owners and users with add_money permission can view money sources.';
COMMENT ON POLICY money_sources_insert_owner ON public.money_sources IS 'Owners and users with add_money permission can create money sources.';
COMMENT ON POLICY money_sources_update_owner ON public.money_sources IS 'Owners and users with add_money permission can update money sources.';
COMMENT ON POLICY money_sources_delete_owner ON public.money_sources IS 'Only the family owner can delete money sources.';

CREATE POLICY money_source_transactions_select_owner ON public.money_source_transactions FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_source_transactions.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_source_transactions.family_id, 'add_money', auth.uid()));
CREATE POLICY money_source_transactions_insert_owner ON public.money_source_transactions FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_source_transactions.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_source_transactions.family_id, 'add_money', auth.uid()));
COMMENT ON POLICY money_source_transactions_select_owner ON public.money_source_transactions IS 'Owners and users with add_money permission can view money source transactions.';
COMMENT ON POLICY money_source_transactions_insert_owner ON public.money_source_transactions IS 'Owners and users with add_money permission can create money source transactions.';

CREATE POLICY money_distributions_select_owner_or_recipient ON public.money_distributions FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_distributions.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_distributions.family_id, 'add_money', auth.uid()) OR EXISTS (SELECT 1 FROM public.money_distribution_lines mdl WHERE mdl.distribution_id = money_distributions.id AND mdl.recipient_user_id = auth.uid()));
CREATE POLICY money_distributions_insert_owner ON public.money_distributions FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_distributions.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_distributions.family_id, 'add_money', auth.uid()));
CREATE POLICY money_distributions_update_owner ON public.money_distributions FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_distributions.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_distributions.family_id, 'add_money', auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_distributions.family_id AND f.owner_user_id = auth.uid()) OR public.has_permission(money_distributions.family_id, 'add_money', auth.uid()));
CREATE POLICY money_distributions_delete_owner ON public.money_distributions FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = money_distributions.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY money_distributions_select_owner_or_recipient ON public.money_distributions IS 'Owners, users with add_money permission, and distribution recipients can view distributions.';
COMMENT ON POLICY money_distributions_insert_owner ON public.money_distributions IS 'Owners and users with add_money permission can create distributions.';
COMMENT ON POLICY money_distributions_update_owner ON public.money_distributions IS 'Owners and users with add_money permission can update distributions.';
COMMENT ON POLICY money_distributions_delete_owner ON public.money_distributions IS 'Only the family owner can delete distributions.';

CREATE POLICY money_distribution_lines_select_owner_or_recipient ON public.money_distribution_lines FOR SELECT TO authenticated USING (recipient_user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.money_distributions md INNER JOIN public.families f ON f.id = md.family_id WHERE md.id = money_distribution_lines.distribution_id AND f.owner_user_id = auth.uid()) OR EXISTS (SELECT 1 FROM public.money_distributions md WHERE md.id = money_distribution_lines.distribution_id AND public.has_permission(md.family_id, 'add_money', auth.uid())));
CREATE POLICY money_distribution_lines_insert_owner ON public.money_distribution_lines FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.money_distributions md INNER JOIN public.families f ON f.id = md.family_id WHERE md.id = money_distribution_lines.distribution_id AND (f.owner_user_id = auth.uid() OR public.has_permission(md.family_id, 'add_money', auth.uid()))));
CREATE POLICY money_distribution_lines_update_owner ON public.money_distribution_lines FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.money_distributions md INNER JOIN public.families f ON f.id = md.family_id WHERE md.id = money_distribution_lines.distribution_id AND (f.owner_user_id = auth.uid() OR public.has_permission(md.family_id, 'add_money', auth.uid())))) WITH CHECK (EXISTS (SELECT 1 FROM public.money_distributions md INNER JOIN public.families f ON f.id = md.family_id WHERE md.id = money_distribution_lines.distribution_id AND (f.owner_user_id = auth.uid() OR public.has_permission(md.family_id, 'add_money', auth.uid()))));
CREATE POLICY money_distribution_lines_delete_owner ON public.money_distribution_lines FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.money_distributions md INNER JOIN public.families f ON f.id = md.family_id WHERE md.id = money_distribution_lines.distribution_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY money_distribution_lines_select_owner_or_recipient ON public.money_distribution_lines IS 'Recipients can view their own distribution lines; owners and add_money users can view all lines.';
COMMENT ON POLICY money_distribution_lines_insert_owner ON public.money_distribution_lines IS 'Owners and users with add_money permission can create distribution lines.';
COMMENT ON POLICY money_distribution_lines_update_owner ON public.money_distribution_lines IS 'Owners and users with add_money permission can update distribution lines.';
COMMENT ON POLICY money_distribution_lines_delete_owner ON public.money_distribution_lines IS 'Only the family owner can delete distribution lines.';

CREATE POLICY family_theme_settings_select_owner ON public.family_theme_settings FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_theme_settings.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY family_theme_settings_insert_owner ON public.family_theme_settings FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_theme_settings.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY family_theme_settings_update_owner ON public.family_theme_settings FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_theme_settings.family_id AND f.owner_user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_theme_settings.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY family_theme_settings_delete_owner ON public.family_theme_settings FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = family_theme_settings.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY family_theme_settings_select_owner ON public.family_theme_settings IS 'Only the family owner can view theme settings.';
COMMENT ON POLICY family_theme_settings_insert_owner ON public.family_theme_settings IS 'Only the family owner can create theme settings.';
COMMENT ON POLICY family_theme_settings_update_owner ON public.family_theme_settings IS 'Only the family owner can update theme settings.';
COMMENT ON POLICY family_theme_settings_delete_owner ON public.family_theme_settings IS 'Only the family owner can delete theme settings.';

CREATE POLICY user_theme_overrides_select_owner ON public.user_theme_overrides FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = user_theme_overrides.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY user_theme_overrides_insert_owner ON public.user_theme_overrides FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = user_theme_overrides.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY user_theme_overrides_update_owner ON public.user_theme_overrides FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = user_theme_overrides.family_id AND f.owner_user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = user_theme_overrides.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY user_theme_overrides_delete_owner ON public.user_theme_overrides FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = user_theme_overrides.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY user_theme_overrides_select_owner ON public.user_theme_overrides IS 'Only the family owner can view user theme overrides.';
COMMENT ON POLICY user_theme_overrides_insert_owner ON public.user_theme_overrides IS 'Only the family owner can create user theme overrides.';
COMMENT ON POLICY user_theme_overrides_update_owner ON public.user_theme_overrides IS 'Only the family owner can update user theme overrides.';
COMMENT ON POLICY user_theme_overrides_delete_owner ON public.user_theme_overrides IS 'Only the family owner can delete user theme overrides.';

CREATE POLICY months_select_active_members ON public.months FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = months.family_id AND fm.user_id = auth.uid() AND fm.membership_status = 'active'));
CREATE POLICY months_insert_owner ON public.months FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = months.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY months_update_owner ON public.months FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = months.family_id AND f.owner_user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.families f WHERE f.id = months.family_id AND f.owner_user_id = auth.uid()));
CREATE POLICY months_delete_owner ON public.months FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.families f WHERE f.id = months.family_id AND f.owner_user_id = auth.uid()));
COMMENT ON POLICY months_select_active_members ON public.months IS 'All active family members can view family months.';
COMMENT ON POLICY months_insert_owner ON public.months IS 'Only the family owner can create month records.';
COMMENT ON POLICY months_update_owner ON public.months IS 'Only the family owner can update month records.';
COMMENT ON POLICY months_delete_owner ON public.months IS 'Only the family owner can delete month records.';

-- ============================================================================
-- 11. Comments
-- ============================================================================

COMMENT ON TABLE public.expense_updates IS 'Expense update history is append-only. Authenticated users may only SELECT via RLS. INSERT is performed by SECURITY DEFINER trigger function create_expense_update_history(). DENY: authenticated users cannot INSERT, UPDATE, or DELETE expense_updates directly. service_role bypasses RLS for administrative operations.';
COMMENT ON TABLE public.activity_logs IS 'Activity logs are append-only. Authenticated users may only SELECT family logs when owner. INSERT is performed by SECURITY DEFINER function log_activity() and related trigger functions. DENY: authenticated users cannot INSERT, UPDATE, or DELETE activity_logs directly. service_role bypasses RLS for administrative operations.';
COMMENT ON TABLE public.notifications IS 'Notifications are system-generated. Authenticated users may SELECT, UPDATE, and DELETE only their own notifications. INSERT is performed by SECURITY DEFINER function create_notification() and related trigger functions. DENY: authenticated users cannot INSERT notifications directly. service_role bypasses RLS for administrative operations.';
COMMENT ON TABLE public.member_permission_grants IS 'Permission grants are owner-managed. Writes may also occur through SECURITY DEFINER function grant_member_permission(). service_role bypasses RLS for administrative operations.';

COMMENT ON FUNCTION public.update_updated_at_column() IS 'Trigger function that sets updated_at to the current timestamp before an UPDATE.';
COMMENT ON FUNCTION public.create_profile_on_signup() IS 'Trigger function that auto-creates a profile row when a new Supabase auth user signs up.';
COMMENT ON FUNCTION public.has_permission(UUID, TEXT, UUID) IS 'Returns TRUE when the user is an active family member with the requested permission via owner role, role defaults, or an active grant.';
COMMENT ON FUNCTION public.create_notification(UUID, UUID, TEXT, TEXT, TEXT, JSONB, TEXT, TEXT, UUID) IS 'Creates a notification row and returns the new notification id.';
COMMENT ON FUNCTION public.log_activity(UUID, UUID, TEXT, TEXT, UUID, TEXT, JSONB, INET, TEXT) IS 'Writes an append-only activity log record and returns the new activity log id.';
COMMENT ON FUNCTION public.create_expense_update_history() IS 'Trigger function that records JSON snapshots of expense changes in expense_updates.';
COMMENT ON FUNCTION public.get_month_total_expenses(UUID, UUID) IS 'Returns the total expense amount for a month. Optionally validates month ownership by family.';
COMMENT ON FUNCTION public.get_month_budget_usage(UUID, UUID) IS 'Returns per-category budget allocation, spend, remaining balance, and usage percentage for a family month.';
COMMENT ON FUNCTION public.grant_member_permission(UUID, TEXT, UUID) IS 'Grants an active permission to a family member, prevents duplicate active grants, logs the action, and returns TRUE on success.';
COMMENT ON FUNCTION public.notify_owner_on_expense_update() IS 'Trigger function that notifies the family owner when an expense is updated by another user.';
COMMENT ON FUNCTION public.notify_member_on_permission_granted() IS 'Trigger function that notifies the target user when a new active permission grant is inserted.';

