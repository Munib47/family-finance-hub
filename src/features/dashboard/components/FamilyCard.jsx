export default function FamilyCard({
  familyName,
  memberCount = null,
}) {
  return (
    <div className="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
      <div className="flex items-center gap-3">
        <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-black text-white">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M17 20h5V9H2v11h5m10 0v-4a3 3 0 00-3-3H10a3 3 0 00-3 3v4m10 0H7"
            />
          </svg>
        </div>

        <div>
          <p className="text-sm text-gray-500">
            Active Family
          </p>

          <h2 className="font-semibold text-gray-900">
            {familyName}
          </h2>

          {memberCount !== null && (
            <p className="text-xs text-gray-500">
              {memberCount} Members
            </p>
          )}
        </div>
      </div>
    </div>
  );
}