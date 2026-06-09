export default function AuthButton({ children, loading = false, loadingText, type = "submit" }) {
  return (
    <button
      className="inline-flex h-12 w-full items-center justify-center rounded-md bg-black px-4 text-sm font-semibold text-white transition hover:bg-neutral-800 focus:outline-none focus:ring-2 focus:ring-black focus:ring-offset-2 disabled:cursor-not-allowed disabled:bg-neutral-400"
      disabled={loading}
      type={type}
    >
      {loading ? (
        <span className="flex items-center gap-2">
          <span
            className="h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white"
            aria-hidden="true"
          />
          {loadingText ?? "Please wait"}
        </span>
      ) : (
        children
      )}
    </button>
  );
}
