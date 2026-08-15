"use client";

import { useState, useTransition } from "react";
import Link from "next/link";
import { verifyCode } from "../actions";

export default function VerifyForm({ email }: { email: string }) {
  const [error, setError] = useState<string | null>(null);
  const [pending, startTransition] = useTransition();

  function handleSubmit(formData: FormData) {
    setError(null);
    startTransition(async () => {
      const result = await verifyCode(formData);
      if (result?.error) setError(result.error);
    });
  }

  return (
    <form action={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-stone-700">Email</label>
        <input
          type="email"
          name="email"
          required
          defaultValue={email}
          autoComplete="email"
          className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 text-stone-900 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          placeholder="nama@email.com"
        />
      </div>
      <div>
        <label className="block text-sm font-medium text-stone-700">Kode konfirmasi</label>
        <input
          type="text"
          name="token"
          required
          inputMode="numeric"
          autoComplete="one-time-code"
          className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 text-center text-lg tracking-widest text-stone-900 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          placeholder="Kode dari email"
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
        {pending ? "Memverifikasi…" : "Konfirmasi & masuk"}
      </button>

      <p className="text-center text-sm text-stone-600">
        Tidak menerima email?{" "}
        <Link href="/signup" className="font-medium text-rose-700">
          Daftar ulang
        </Link>
      </p>
    </form>
  );
}
