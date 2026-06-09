import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { AuthInput, AuthButton } from "../../auth";

export default function FamilySetupForm({ loading, onSubmit, error: serverError }) {
  const {
    formState: { errors, isSubmitting },
    handleSubmit,
    register,
    setError,
  } = useForm({
    defaultValues: {
      familyName: "",
    },
  });

  const loading_state = isSubmitting || loading;

  useEffect(() => {
    if (serverError) {
      setError("root.server", {
        message: serverError?.message ?? "Unable to create family. Please try again.",
        type: "server",
      });
    }
  }, [serverError, setError]);

  async function handleFormSubmit(values) {
    try {
      await onSubmit(values.familyName.trim());
    } catch (error) {
      setError("root.server", {
        message: error?.message ?? "Unable to create family. Please try again.",
        type: "server",
      });
    }
  }

  return (
    <form className="space-y-4" noValidate onSubmit={handleSubmit(handleFormSubmit)}>
      {errors.root?.server ? (
        <div
          className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-left text-sm font-medium text-red-700"
          role="alert"
        >
          {errors.root.server.message}
        </div>
      ) : null}

      <AuthInput
        autoComplete="off"
        disabled={loading_state}
        error={errors.familyName}
        id="family-name"
        label="Family Name"
        placeholder="Enter your family name"
        registration={register("familyName", {
          maxLength: {
            message: "Family name must not exceed 100 characters.",
            value: 100,
          },
          minLength: {
            message: "Family name must be at least 2 characters.",
            value: 2,
          },
          required: "Family name is required.",
        })}
      />

      <AuthButton loading={loading_state} loadingText="Creating family">
        Create Family
      </AuthButton>
    </form>
  );
}
