import { Navigate, Outlet, useLocation } from "react-router-dom";

import AuthErrorState from "../components/AuthErrorState";
import AuthLoadingScreen from "../components/AuthLoadingScreen";
import { useAuth } from "../hooks/useAuth";

export default function ProtectedRoute({
  children,
  redirectTo = "/",
  requireFamily = false,
  requiredPermission,
  unauthorizedTo = "/dashboard",
}) {
  const location = useLocation();
  const {
    error,
    hasFamily,
    hasPermission,
    isAuthenticated,
    loading,
    refreshAuthState,
  } = useAuth();

  if (loading) {
    return <AuthLoadingScreen />;
  }

  if (!isAuthenticated) {
    return <Navigate replace state={{ from: location }} to={redirectTo} />;
  }

  if (error) {
    return <AuthErrorState error={error} onRetry={refreshAuthState} />;
  }

  if (requireFamily && !hasFamily) {
    return <Navigate replace to="/family-setup" />;
  }

  if (requiredPermission && !hasPermission(requiredPermission)) {
    return <Navigate replace to={unauthorizedTo} />;
  }

  return children ?? <Outlet />;
}
