"use client";

import { useState, useTransition } from "react";
import { addChild } from "../../actions";

export default function TambahAnakPage() {
  const [error, setError] = useState<string | null>(null);
  const [pending, startTransition] = useTransition();

  function handleSubmit(formData: FormData) {
    setError(null);
    startTransition(async () => {
      const result = await addChild(formData);
      if (result?.error) setError(result.error);
    });
  }

  return (
    <div className="mx-auto max-w-md">
      <h1 className="text-xl font-bold text-stone-900">Tambah profil anak</h1>
      <form action={handleSubmit} className="mt-6 space-y-4 rounded-2xl border border-stone-200 bg-white p-6">
        <div>
          <label className="block text-sm font-medium text-stone-700">Nama anak</label>
          <input
            type="text"
            name="name"
            required
            className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-stone-700">Tanggal lahir</label>
          <input
            type="date"
            name="birth_date"
            className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          />
        </div>
        {error && <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}
        <button
          type="submit"
          disabled={pending}
          className="w-full rounded-lg bg-rose-600 px-4 py-2.5 font-semibold text-white hover:bg-rose-700 disabled:opacity-60"
        >
          {pending ? "Menyimpan…" : "Simpan"}
        </button>
      </form>
    </div>
  );
}
