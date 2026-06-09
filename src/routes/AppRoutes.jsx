import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";

import { ProtectedRoute, PublicRoute, useAuth } from "../features/auth";
import ForgotPassword from "../pages/auth/ForgotPassword";
import Login from "../pages/auth/Login";
import Register from "../pages/auth/Register";

function DashboardPlaceholder() {
  const { family, logout, profile, role } = useAuth();

  return (
    <main className="min-h-screen bg-slate-50 px-5 py-8 text-slate-950">
      <section className="mx-auto flex min-h-[calc(100svh-4rem)] w-full max-w-md flex-col justify-center">
        <div className="rounded-lg border border-slate-200 bg-white p-5 text-left shadow-sm">
          <p className="text-sm font-medium text-emerald-700">Authentication ready</p>
          <h1 className="mt-2 text-2xl font-semibold text-slate-950">
            {profile?.display_name || profile?.email || "Signed in"}
          </h1>
          <dl className="mt-5 space-y-3 text-sm text-slate-600">
            <div>
              <dt className="font-medium text-slate-950">Family</dt>
              <dd>{family?.name ?? "Family setup pending"}</dd>
            </div>
            <div>
              <dt className="font-medium text-slate-950">Role</dt>
              <dd>{role ?? "No active role yet"}</dd>
            </div>
          </dl>
          <button
            className="mt-6 inline-flex h-11 items-center justify-center rounded-md bg-slate-950 px-4 text-sm font-semibold text-white transition hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-400 focus:ring-offset-2"
            type="button"
            onClick={logout}
          >
            Sign out
          </button>
        </div>
      </section>
    </main>
  );
}

export default function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<PublicRoute />}>
          <Route path="/" element={<Login />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/forgot-password" element={<ForgotPassword />} />
        </Route>
        <Route element={<ProtectedRoute />}>
          <Route path="/dashboard" element={<DashboardPlaceholder />} />
        </Route>
        <Route path="*" element={<Navigate replace to="/" />} />
      </Routes>
    </BrowserRouter>
  );
}
