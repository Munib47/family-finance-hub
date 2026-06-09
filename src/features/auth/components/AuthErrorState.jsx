function getErrorMessage(error) {
  if (!error) {
    return "Something went wrong while loading authentication state.";
  }

  if (typeof error === "string") {
    return error;
  }

  return error.message ?? "Something went wrong while loading authentication state.";
}

export default function AuthErrorState({
  error,
  onRetry,
  title = "Authentication could not be loaded",
}) {
  return (
    <main className="min-h-screen bg-slate-50 px-5 py-8 text-slate-950">
      <div className="mx-auto flex min-h-[calc(100svh-4rem)] w-full max-w-md flex-col justify-center">
        <div className="rounded-lg border border-red-200 bg-white p-5 text-left shadow-sm">
          <div
            className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-red-50 text-red-600"
            aria-hidden="true"
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path d="M12 9v4" />
              <path d="M12 17h.01" />
              <path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z" />
            </svg>
          </div>
          <h1 className="text-lg font-semibold text-slate-950">{title}</h1>
          <p className="mt-2 text-sm leading-6 text-slate-600">{getErrorMessage(error)}</p>
          {onRetry ? (
            <button
              className="mt-5 inline-flex h-11 items-center justify-center rounded-md bg-slate-950 px-4 text-sm font-semibold text-white transition hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-400 focus:ring-offset-2"
              type="button"
              onClick={onRetry}
            >
              Retry
            </button>
          ) : null}
        </div>
      </div>
    </main>
  );
}
