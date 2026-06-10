const AVAILABLE_MONTHS = [
  { label: "April 2026", month: "April", year: 2026 },
  { label: "May 2026", month: "May", year: 2026 },
  { label: "June 2026", month: "June", year: 2026 },
  { label: "July 2026", month: "July", year: 2026 },
  { label: "August 2026", month: "August", year: 2026 },
];

export default function SelectMonthStep({ onSelectMonth }) {
  return (
    <div className="space-y-8">
      <div className="text-center space-y-1.5">
        <h1 className="text-2xl font-bold tracking-tight">Select Month</h1>
        <p className="text-sm text-gray-500">Slide to select month</p>
      </div>

      <div className="space-y-3 pt-4">
        {AVAILABLE_MONTHS.map((m) => (
          <button
            key={m.label}
            onClick={() => onSelectMonth(m)}
            className="w-full text-center px-5 py-4 rounded-xl border border-gray-200 bg-white font-medium text-base text-gray-800 hover:border-gray-400 hover:bg-gray-50 active:scale-[0.99] transition-all"
          >
            {m.label}
          </button>
        ))}
      </div>
    </div>
  );
}