"use client";

import { useRef, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { addPhoto } from "../../../../actions";
import { compressImage } from "@/lib/compressImage";

export default function UploadPhotoForm({
  areaId,
  hasBaseline,
}: {
  areaId: string;
  hasBaseline: boolean;
}) {
  const [error, setError] = useState<string | null>(null);
  const [warning, setWarning] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const [useAi, setUseAi] = useState(true);
  const [pending, startTransition] = useTransition();
  const formRef = useRef<HTMLFormElement>(null);
  const router = useRouter();

  function handleSubmit(formData: FormData) {
    setError(null);
    setWarning(null);
    setSuccess(false);
    startTransition(async () => {
      const photo = formData.get("photo");
      if (photo instanceof File && photo.size > 0) {
        formData.set("photo", await compressImage(photo));
      }
      const result = await addPhoto(areaId, formData);
      if (result?.error) {
        setError(result.error);
        return;
      }
      if (result?.warning) setWarning(result.warning);
      else setSuccess(true);
      formRef.current?.reset();
      setUseAi(true);
      router.refresh();
    });
  }

  return (
    <form
      ref={formRef}
      action={handleSubmit}
      className="space-y-4 rounded-2xl border border-stone-200 bg-white p-5"
    >
      <p className="font-semibold text-stone-900">
        {hasBaseline ? "Tambah foto follow-up" : "Unggah foto baseline"}
      </p>

      <label className="flex items-start gap-2 rounded-lg bg-rose-50 p-3 text-sm text-stone-700">
        <input
          type="checkbox"
          name="use_ai_measure"
          checked={useAi}
          onChange={(e) => setUseAi(e.target.checked)}
          className="mt-0.5"
        />
        <span>
          Foto ada <strong>koin Rp100 (diameter 22mm)</strong> di dekat area — biar AI hitung
          lebar, tinggi, dan warna otomatis dari foto.
        </span>
      </label>

      {useAi && (
        <div className="rounded-lg border border-amber-200 bg-amber-50 p-3 text-xs text-amber-900">
          <p className="font-semibold">Supaya hasil ukur antar foto konsisten:</p>
          <ul className="mt-1 list-disc space-y-0.5 pl-4">
            <li>Foto <strong>tegak lurus dari atas</strong> (kamera sejajar 90° dengan kulit), jangan miring.</li>
            <li>Koin diletakkan <strong>rata &amp; menempel</strong> pada bidang kulit yang sama dengan area yang diukur.</li>
            <li>Jarak &amp; pencahayaan sebisa mungkin <strong>sama setiap kali</strong> foto — pastikan tidak buram/blur.</li>
            <li>Sebisa mungkin pakai HP &amp; mode kamera yang sama tiap kali foto (hindari gonta-ganti mode wide/macro), dan taruh koin di tengah bidang foto — bagian tepi lensa HP biasanya lebih melengkung/distorsi.</li>
            <li>Ukuran dari AI adalah estimasi visual, bisa ada sedikit variasi antar foto — lihat sebagai tren, bukan angka mutlak per hari.</li>
          </ul>
          <p className="mt-1">
            Sistem sekarang otomatis mendeteksi kalau foto tampak miring atau koin terlalu
            jauh/dekat, dan akan memberi peringatan setelah unggah supaya bisa difoto ulang.
          </p>
        </div>
      )}

      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <label className="block text-sm font-medium text-stone-700">Jenis foto</label>
          <select
            name="kind"
            defaultValue={hasBaseline ? "followup" : "baseline"}
            className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          >
            <option value="baseline">Baseline</option>
            <option value="followup">Follow-up</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-stone-700">Tanggal</label>
          <input
            type="date"
            name="taken_at"
            defaultValue={new Date().toISOString().slice(0, 10)}
            className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-stone-700">
            Lebar (mm{useAi ? ", opsional — override AI" : ", opsional"})
          </label>
          <input
            type="number"
            step="0.1"
            min="0"
            name="width_mm"
            className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-stone-700">
            Tinggi (mm{useAi ? ", opsional — override AI" : ", opsional"})
          </label>
          <input
            type="number"
            step="0.1"
            min="0"
            name="height_mm"
            className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          />
        </div>
        <div className="sm:col-span-2">
          <label className="block text-sm font-medium text-stone-700">
            Warna ({useAi ? "opsional — override AI" : "opsional"})
          </label>
          <input
            type="text"
            name="color"
            placeholder="mis. merah terang, merah tua, keunguan"
            className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
          />
        </div>
        <div className="sm:col-span-2">
          <label className="block text-sm font-medium text-stone-700">Foto</label>
          <input
            type="file"
            name="photo"
            accept="image/*"
            required
            className="mt-1 w-full text-sm text-stone-600 file:mr-3 file:rounded-lg file:border-0 file:bg-stone-100 file:px-3 file:py-2"
          />
        </div>
      </div>
      <div>
        <label className="block text-sm font-medium text-stone-700">Catatan (opsional)</label>
        <input
          type="text"
          name="notes"
          className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
        />
      </div>
      {error && <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}
      {warning && (
        <p className="rounded-lg bg-amber-50 px-3 py-2 text-sm text-amber-800">
          Foto tersimpan, tapi {warning}
        </p>
      )}
      {success && (
        <p className="rounded-lg bg-emerald-50 px-3 py-2 text-sm text-emerald-800">
          Foto tersimpan, ukuran & warna berhasil dihitung AI dari koin.
        </p>
      )}
      <button
        type="submit"
        disabled={pending}
        className="w-full rounded-lg bg-rose-600 px-4 py-2.5 font-semibold text-white hover:bg-rose-700 disabled:opacity-60 sm:w-auto"
      >
        {pending ? "Mengunggah & mengukur…" : "Unggah foto"}
      </button>
    </form>
  );
}
