import { Link } from "react-router-dom";

export default function ModuleCard({
  title,
  description,
  icon,
  to,
}) {
  return (
    <Link
      to={to}
      className="block rounded-xl border border-gray-200 bg-white p-5 shadow-sm transition hover:border-black hover:shadow-md"
    >
      <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-black text-white">
        {icon}
      </div>

      <h3 className="mb-1 text-lg font-semibold text-gray-900">
        {title}
      </h3>

      <p className="text-sm text-gray-500">
        {description}
      </p>
    </Link>
  );
}