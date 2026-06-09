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
  return error?.message ?? "Unable to create your account. Please try again.";
}

export default function Register() {
  const { actionLoading, clearError, register: registerUser } = useAuth();
  const [successMessage, setSuccessMessage] = useState("");
  const {
    formState: { errors, isSubmitting },
    getValues,
    handleSubmit,
    register,
    setError,
  } = useForm({
    defaultValues: {
      confirmPassword: "",
      email: "",
      fullName: "",
      password: "",
    },
  });

  const loading = isSubmitting || actionLoading;

  useEffect(() => {
    clearError();
  }, [clearError]);

  async function onSubmit(values) {
    setSuccessMessage("");

    try {
      const data = await registerUser({
        email: values.email.trim(),
        metadata: {
          display_name: values.fullName.trim(),
          full_name: values.fullName.trim(),
        },
        password: values.password,
      });

      if (data.user && !data.session) {
        setSuccessMessage("Account created. Please check your email to confirm your account.");
      }
    } catch (error) {
      setError("root.server", {
        message: getErrorMessage(error),
        type: "server",
      });
    }
  }

  return (
    <AuthLayout title="Create Account" subtitle="Fill in the details to register" backTo="/" showBackButton={false}>
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
            autoComplete="name"
            disabled={loading}
            error={errors.fullName}
            id="register-full-name"
            label="Full Name"
            placeholder="Full Name"
            registration={register("fullName", {
              minLength: {
                message: "Full name must be at least 2 characters.",
                value: 2,
              },
              required: "Full name is required.",
            })}
          />

          <AuthInput
            autoComplete="email"
            disabled={loading}
            error={errors.email}
            id="register-email"
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
            autoComplete="new-password"
            disabled={loading}
            error={errors.password}
            id="register-password"
            label="Password"
            placeholder="Password"
            type="password"
            registration={register("password", {
              minLength: {
                message: "Password must be at least 8 characters.",
                value: 8,
              },
              required: "Password is required.",
            })}
          />

          <AuthInput
            autoComplete="new-password"
            disabled={loading}
            error={errors.confirmPassword}
            id="register-confirm-password"
            label="Confirm Password"
            placeholder="Confirm Password"
            type="password"
            registration={register("confirmPassword", {
              required: "Please confirm your password.",
              validate: (value) =>
                value === getValues("password") || "Passwords do not match.",
            })}
          />

          <AuthButton loading={loading} loadingText="Creating account">
            Register
          </AuthButton>
        </form>

        <p className="mt-7 text-center text-xs text-neutral-600">
          Already have an account? <AuthTextLink to="/">Login</AuthTextLink>
        </p>
      </AuthCard>
    </AuthLayout>
  );
}
