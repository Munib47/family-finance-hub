import { useMemo } from "react";

export default function MonthSelector({
  value,
  onChange,
}) {
  const months = useMemo(
    () => [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ],
    []
  );

  return (
    <div>
      <label
        htmlFor="month-selector"
        className="mb-2 block text-sm font-medium text-gray-700"
      >
        Selected Month
      </label>

      <select
        id="month-selector"
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-lg border border-gray-300 bg-white px-4 py-3 text-sm outline-none focus:border-black"
      >
        {months.map((month) => (
          <option
            key={month}
            value={month}
          >
            {month}
          </option>
        ))}
      </select>
    </div>
  );
}