export default function DashboardHeader({
  familyName,
  role,
}) {
  const formattedRole =
    role?.replaceAll("_", " ")?.replace(/\b\w/g, (char) => char.toUpperCase()) ||
    "Member";

  return (
    <header className="space-y-1">
      <h1 className="text-2xl font-bold text-gray-900">
        Dashboard
      </h1>

      <p className="text-sm text-gray-500">
        {familyName}
      </p>

      <div className="inline-flex rounded-full bg-gray-100 px-3 py-1 text-xs font-medium text-gray-700">
        {formattedRole}
      </div>
    </header>
  );
}