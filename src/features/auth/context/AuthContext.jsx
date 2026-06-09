/* eslint-disable react-refresh/only-export-components */
import { createContext, useCallback, useEffect, useMemo, useRef, useState } from "react";

import {
  getCurrentSession,
  onAuthStateChange,
  sendPasswordResetEmail,
  signInWithEmail,
  signOut,
  signUpWithEmail,
} from "../services/authService";
import { bootstrapAuthState } from "../services/authBootstrapService";

const emptyAuthState = {
  family: null,
  membership: null,
  permissionDefinitions: [],
  permissions: {},
  profile: null,
  role: null,
  session: null,
  user: null,
};

export const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const requestIdRef = useRef(0);
  const [authState, setAuthState] = useState(emptyAuthState);
  const [initializing, setInitializing] = useState(true);
  const [bootstrapping, setBootstrapping] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const [error, setError] = useState(null);

  const clearAuthState = useCallback(() => {
    setAuthState(emptyAuthState);
  }, []);

  const hydrateFromSession = useCallback(async (session) => {
    const requestId = requestIdRef.current + 1;
    requestIdRef.current = requestId;

    if (!session) {
      clearAuthState();
      setError(null);
      setBootstrapping(false);
      setInitializing(false);
      return;
    }

    setBootstrapping(true);
    setError(null);

    console.log("AuthProvider hydrateFromSession", {
      sessionUserId: session?.user?.id,
      session: session ? { expires_at: session.expires_at } : null,
    });

    try {
      const nextAuthState = await bootstrapAuthState(session);

      if (requestIdRef.current === requestId) {
        setAuthState(nextAuthState);
      }
    } catch (authError) {
      if (requestIdRef.current === requestId) {
        setAuthState({
          ...emptyAuthState,
          session,
          user: session.user ?? null,
        });
        setError(authError);
      }
    } finally {
      if (requestIdRef.current === requestId) {
        setBootstrapping(false);
        setInitializing(false);
      }
    }
  }, [clearAuthState]);

  const refreshAuthState = useCallback(async () => {
    setInitializing(true);

    const { data, error: sessionError } = await getCurrentSession();

    if (sessionError) {
      setError(sessionError);
      setInitializing(false);
      return;
    }

    await hydrateFromSession(data.session);
  }, [hydrateFromSession]);

  useEffect(() => {
    let isMounted = true;

    async function initializeAuth() {
      const { data, error: sessionError } = await getCurrentSession();

      if (!isMounted) {
        return;
      }

      if (sessionError) {
        setError(sessionError);
        setInitializing(false);
        return;
      }

      await hydrateFromSession(data.session);
    }

    initializeAuth();

    const { data } = onAuthStateChange((_event, session) => {
      window.setTimeout(() => {
        if (isMounted) {
          hydrateFromSession(session);
        }
      }, 0);
    });

    return () => {
      isMounted = false;
      data.subscription.unsubscribe();
    };
  }, [hydrateFromSession]);

  const login = useCallback(async ({ email, password }) => {
    setActionLoading(true);
    setError(null);

    try {
      const { data, error: signInError } = await signInWithEmail({ email, password });

      if (signInError) {
        throw signInError;
      }

      if (data.session) {
        await hydrateFromSession(data.session);
      }

      return data;
    } catch (authError) {
      setError(authError);
      throw authError;
    } finally {
      setActionLoading(false);
    }
  }, [hydrateFromSession]);

  const register = useCallback(async ({ email, password, metadata }) => {
    setActionLoading(true);
    setError(null);

    try {
      const { data, error: signUpError } = await signUpWithEmail({
        email,
        metadata,
        password,
      });

      if (signUpError) {
        throw signUpError;
      }

      if (data.session) {
        await hydrateFromSession(data.session);
      }

      return data;
    } catch (authError) {
      setError(authError);
      throw authError;
    } finally {
      setActionLoading(false);
    }
  }, [hydrateFromSession]);

  const logout = useCallback(async () => {
    setActionLoading(true);
    setError(null);

    try {
      const { error: signOutError } = await signOut();

      if (signOutError) {
        throw signOutError;
      }

      clearAuthState();
    } catch (authError) {
      setError(authError);
      throw authError;
    } finally {
      setActionLoading(false);
    }
  }, [clearAuthState]);

  const sendPasswordReset = useCallback(async (email, redirectTo) => {
    setActionLoading(true);
    setError(null);

    try {
      const { data, error: resetError } = await sendPasswordResetEmail(email, redirectTo);

      if (resetError) {
        throw resetError;
      }

      return data;
    } catch (authError) {
      setError(authError);
      throw authError;
    } finally {
      setActionLoading(false);
    }
  }, []);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const hasPermission = useCallback(
    (permissionKey) => {
      if (authState.role === "owner") {
        return true;
      }

      return Boolean(authState.permissions[permissionKey]);
    },
    [authState.permissions, authState.role]
  );

  const value = useMemo(() => {
    const isAuthenticated = Boolean(authState.session?.user);

    return {
      ...authState,
      actionLoading,
      bootstrapping,
      clearError,
      error,
      hasFamily: Boolean(authState.family && authState.membership),
      hasPermission,
      initializing,
      isAuthenticated,
      isOwner: authState.role === "owner",
      loading: initializing || bootstrapping,
      login,
      logout,
      refreshAuthState,
      register,
      sendPasswordReset,
    };
  }, [
    actionLoading,
    authState,
    bootstrapping,
    clearError,
    error,
    hasPermission,
    initializing,
    login,
    logout,
    refreshAuthState,
    register,
    sendPasswordReset,
  ]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
