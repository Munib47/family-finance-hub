export default function AuthLoadingScreen({ message = "Loading your session" }) {
  return (
    <main className="min-h-screen bg-slate-50 px-5 py-8 text-slate-950">
      <div className="mx-auto flex min-h-[calc(100svh-4rem)] w-full max-w-md flex-col items-center justify-center text-center">
        <div
          className="mb-5 h-11 w-11 animate-spin rounded-full border-4 border-emerald-100 border-t-emerald-600"
          aria-hidden="true"
        />
        <p className="text-sm font-medium text-slate-600">{message}</p>
      </div>
    </main>
  );
}
