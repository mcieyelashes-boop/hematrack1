"use client";

import { use, useState, useTransition } from "react";
import { addArea } from "../../../../actions";

export default function TambahAreaPage({
  params,
}: {
  params: Promise<{ childId: string }>;
}) {
  const { childId } = use(params);
  const [error, setError] = useState<string | null>(null);
  const [pending, startTransition] = useTransition();

  function handleSubmit(formData: FormData) {
    setError(null);
    startTransition(async () => {
      const result = await addArea(childId, formData);
      if (result?.error) setError(result.error);
    });
  }

  return (
    <div className="mx-auto max-w-md">
      <h1 className="text-xl font-bold text-stone-900">Tambah area hemangioma</h1>
      <form action={handleSubmit} className="mt-6 space-y-4 rounded-2xl border border-stone-200 bg-white p-6">
        <div>
          <label className="block text-sm font-medium text-stone-700">Nama / lokasi area</label>
          <input
            type="text"
            name="name"
            required
            placeholder="mis. Pipi kanan"
            className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-stone-700">Catatan (opsional)</label>
          <textarea
            name="notes"
            rows={3}
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
