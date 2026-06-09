export default function AuthInput({
  autoComplete,
  disabled,
  error,
  id,
  label,
  placeholder,
  registration,
  type = "text",
}) {
  return (
    <div>
      <label className="mb-2 block text-left text-sm font-medium text-black" htmlFor={id}>
        {label}
      </label>
      <input
        id={id}
        autoComplete={autoComplete}
        className="h-12 w-full rounded-md border border-neutral-200 bg-white px-3 text-sm text-black outline-none transition placeholder:text-neutral-400 focus:border-black focus:ring-2 focus:ring-black/10 disabled:cursor-not-allowed disabled:bg-neutral-50 disabled:text-neutral-500"
        disabled={disabled}
        placeholder={placeholder}
        type={type}
        aria-describedby={error ? `${id}-error` : undefined}
        aria-invalid={Boolean(error)}
        {...registration}
      />
      {error ? (
        <p className="mt-2 text-left text-xs font-medium text-red-600" id={`${id}-error`}>
          {error.message}
        </p>
      ) : null}
    </div>
  );
}
