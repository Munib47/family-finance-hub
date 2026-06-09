import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { Link } from "react-router-dom";

import {
  AuthButton,
  AuthCard,
  AuthInput,
  AuthLayout,
  AuthTextLink,
  useAuth,
} from "../../features/auth";

function getErrorMessage(error) {
  return error?.message ?? "Unable to log in. Please check your details and try again.";
}

export default function Login() {
  const { actionLoading, clearError, login } = useAuth();
  const {
    formState: { errors, isSubmitting },
    handleSubmit,
    register,
    setError,
  } = useForm({
    defaultValues: {
      email: "",
      password: "",
    },
  });

  const loading = isSubmitting || actionLoading;

  useEffect(() => {
    clearError();
  }, [clearError]);

  async function onSubmit(values) {
    try {
      await login({
        email: values.email.trim(),
        password: values.password,
      });
    } catch (error) {
      setError("root.server", {
        message: getErrorMessage(error),
        type: "server",
      });
    }
  }

  return (
    <AuthLayout
      title="Welcome Back"
      subtitle="Please login to your account"
      backTo="/login"
    >
      <AuthCard>
        <form className="space-y-4" noValidate onSubmit={handleSubmit(onSubmit)}>
          {errors.root?.server ? (
            <div
              className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-left text-sm font-medium text-red-700"
              role="alert"
            >
              {errors.root.server.message}
            </div>
          ) : null}

          <AuthInput
            autoComplete="email"
            disabled={loading}
            error={errors.email}
            id="login-email"
            label="Email"
            placeholder="Email"
            type="email"
            registration={register("email", {
              pattern: {
                message: "Enter a valid email address.",
                value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
              },
              required: "Email is required.",
            })}
          />

          <AuthInput
            autoComplete="current-password"
            disabled={loading}
            error={errors.password}
            id="login-password"
            label="Password"
            placeholder="Password"
            type="password"
            registration={register("password", {
              required: "Password is required.",
            })}
          />

          <div className="flex justify-end">
            <Link
              className="text-xs font-medium text-neutral-700 transition hover:text-black focus:outline-none focus:ring-2 focus:ring-black focus:ring-offset-2"
              to="/forgot-password"
            >
              Forgot Password?
            </Link>
          </div>

          <AuthButton loading={loading} loadingText="Logging in">
            Login
          </AuthButton>
        </form>

        <p className="mt-7 text-center text-xs text-neutral-600">
          Do not have an account? <AuthTextLink to="/register">Register</AuthTextLink>
        </p>
      </AuthCard>
    </AuthLayout>
  );
}
