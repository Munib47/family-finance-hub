import { AuthCard } from "../../auth";
import FamilySetupForm from "./FamilySetupForm";

export default function FamilySetupCard({ loading, onSubmit, error }) {
  return (
    <AuthCard>
      <FamilySetupForm error={error} loading={loading} onSubmit={onSubmit} />
    </AuthCard>
  );
}
