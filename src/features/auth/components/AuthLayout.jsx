import { Link, useNavigate } from "react-router-dom";

export default function AuthLayout({ backTo, children, subtitle, title }) {
  const navigate = useNavigate();

  function handleBack() {
    if (backTo) {
      navigate(backTo);
      return;
    }

    navigate(-1);
  }

  return (
    <main className="min-h-screen bg-white px-5 py-6 text-black sm:px-6">
      <section className="mx-auto flex min-h-[calc(100svh-3rem)] w-full max-w-sm flex-col justify-center">
        <div className="mb-5 flex min-h-10 items-center">
          <button
            className="inline-flex h-10 w-10 items-center justify-center rounded-md text-black transition hover:bg-neutral-100 focus:outline-none focus:ring-2 focus:ring-black focus:ring-offset-2"
            type="button"
            aria-label="Go back"
            onClick={handleBack}
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <path d="m15 18-6-6 6-6" />
            </svg>
          </button>
        </div>

        <div className="mb-7 text-center">
          <h1 className="text-2xl font-semibold tracking-normal text-black">{title}</h1>
          {subtitle ? <p className="mt-2 text-sm text-neutral-600">{subtitle}</p> : null}
        </div>

        {children}

        <p className="mt-8 text-center text-xs text-neutral-500">
          Family Expense Management
        </p>
      </section>
    </main>
  );
}

export function AuthTextLink({ children, to }) {
  return (
    <Link
      className="font-semibold text-blue-700 transition hover:text-blue-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      to={to}
    >
      {children}
    </Link>
  );
}
