import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";

import {
  AuthButton,
  AuthCard,
  AuthInput,
  AuthLayout,
  AuthTextLink,
  useAuth,
} from "../../features/auth";

function getErrorMessage(error) {
  return error?.message ?? "Unable to send reset instructions. Please try again.";
}

export default function ForgotPassword() {
  const { actionLoading, clearError, sendPasswordReset } = useAuth();
  const [successMessage, setSuccessMessage] = useState("");
  const {
    formState: { errors, isSubmitting },
    handleSubmit,
    register,
    setError,
  } = useForm({
    defaultValues: {
      email: "",
    },
  });

  const loading = isSubmitting || actionLoading;

  useEffect(() => {
    clearError();
  }, [clearError]);

  async function onSubmit(values) {
    setSuccessMessage("");

    try {
      const redirectTo = `${window.location.origin}/login`;

      await sendPasswordReset(values.email.trim(), redirectTo);
      setSuccessMessage("Password reset link sent. Please check your email.");
    } catch (error) {
      setError("root.server", {
        message: getErrorMessage(error),
        type: "server",
      });
    }
  }

  return (
    <AuthLayout
      title="Reset Password"
      subtitle="Enter your email to receive a reset link"
      backTo="/"
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

          {successMessage ? (
            <div
              className="rounded-md border border-emerald-200 bg-emerald-50 px-3 py-2 text-left text-sm font-medium text-emerald-800"
              role="status"
            >
              {successMessage}
            </div>
          ) : null}

          <AuthInput
            autoComplete="email"
            disabled={loading}
            error={errors.email}
            id="forgot-password-email"
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

          <AuthButton loading={loading} loadingText="Sending link">
            Send Reset Link
          </AuthButton>
        </form>

        <p className="mt-7 text-center text-xs text-neutral-600">
          Remember your password? <AuthTextLink to="/">Login</AuthTextLink>
        </p>
      </AuthCard>
    </AuthLayout>
  );
}
