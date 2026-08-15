"use client";

import { useState, useTransition } from "react";
import Link from "next/link";

type Mode = "login" | "signup";

export default function AuthForm({
  mode,
  action,
  redirectTo,
}: {
  mode: Mode;
  action: (formData: FormData) => Promise<{ error: string } | void>;
  redirectTo: string;
}) {
  const [error, setError] = useState<string | null>(null);
  const [pending, startTransition] = useTransition();

  const isLogin = mode === "login";

  function handleSubmit(formData: FormData) {
    setError(null);
    startTransition(async () => {
      const result = await action(formData);
      if (result?.error) setError(result.error);
    });
  }

  return (
    <form action={handleSubmit} className="space-y-4">
      <input type="hidden" name="redirect" value={redirectTo} />
      <div>
        <label className="block text-sm font-medium text-stone-700">Email</label>
        <input
          type="email"
          name="email"
          required
          autoComplete="email"
          className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 text-stone-900 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          placeholder="nama@email.com"
        />
      </div>
      <div>
        <label className="block text-sm font-medium text-stone-700">Kata sandi</label>
        <input
          type="password"
          name="password"
          required
          minLength={6}
          autoComplete={isLogin ? "current-password" : "new-password"}
          className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 text-stone-900 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          placeholder="Minimal 6 karakter"
        />
      </div>

      {error && (
        <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>
      )}

      <button
        type="submit"
        disabled={pending}
        className="w-full rounded-lg bg-rose-600 px-4 py-2.5 font-semibold text-white hover:bg-rose-700 disabled:opacity-60"
      >
        {pending ? "Memproses…" : isLogin ? "Masuk" : "Daftar gratis"}
      </button>

      <p className="text-center text-sm text-stone-600">
        {isLogin ? (
          <>
            Belum punya akun?{" "}
            <Link href="/signup" className="font-medium text-rose-700">
              Daftar
            </Link>
          </>
        ) : (
          <>
            Sudah punya akun?{" "}
            <Link href="/login" className="font-medium text-rose-700">
              Masuk
            </Link>
          </>
        )}
      </p>
    </form>
  );
}
