import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { AuthLayout, useAuth } from "../../features/auth";
import FamilySetupCard from "../../features/family/components/FamilySetupCard";
import { createFamily } from "../../features/family/services/familyService";

export default function FamilySetup() {
  const navigate = useNavigate();
  const { actionLoading, error, profile, refreshAuthState, user } = useAuth();

  useEffect(() => {
    // If user somehow has a family, redirect to dashboard
    // This is a safety check
    if (profile && profile.family_id) {
      navigate("/dashboard", { replace: true });
    }
  }, [profile, navigate]);

  async function handleCreateFamily(familyName) {
    if (!user?.id) {
      throw new Error("User session not found. Please refresh and try again.");
    }

    await createFamily(familyName, user.id);

    // Refresh auth state to load the new family
    await refreshAuthState();

    // Redirect to dashboard
    navigate("/dashboard", { replace: true });
  }

  return (
    <AuthLayout
      title="Create Your Family"
      subtitle="Set up your family to start managing expenses"
      backTo={null}
      showBackButton={false}
    >
      <FamilySetupCard
        error={error}
        loading={actionLoading}
        onSubmit={handleCreateFamily}
      />
    </AuthLayout>
  );
}
