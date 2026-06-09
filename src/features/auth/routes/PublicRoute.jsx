import { Navigate, Outlet, useLocation } from "react-router-dom";

import AuthLoadingScreen from "../components/AuthLoadingScreen";
import { useAuth } from "../hooks/useAuth";

export default function PublicRoute({ children, redirectTo = "/dashboard" }) {
  const location = useLocation();
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return <AuthLoadingScreen />;
  }

  if (isAuthenticated) {
    const destination = location.state?.from?.pathname ?? redirectTo;
    return <Navigate replace to={destination} />;
  }

  return children ?? <Outlet />;
}
