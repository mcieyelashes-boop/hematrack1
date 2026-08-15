import Link from "next/link";
import Image from "next/image";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import UploadPhotoForm from "./UploadPhotoForm";
import TrendChart from "./TrendChart";

export default async function DetailAreaPage({
  params,
}: {
  params: Promise<{ childId: string; areaId: string }>;
}) {
  const { childId, areaId } = await params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: area } = await supabase
    .from("hematrack_areas")
    .select("id, name, notes, child_id")
    .eq("id", areaId)
    .eq("user_id", user!.id)
    .single();

  if (!area || area.child_id !== childId) notFound();

  const { data: photos } = await supabase
    .from("hematrack_photos")
    .select("id, kind, photo_path, width_mm, height_mm, color, taken_at, notes")
    .eq("area_id", areaId)
    .order("taken_at", { ascending: true });

  const paths = (photos ?? []).map((p) => p.photo_path);
  const { data: signedUrls } = paths.length
    ? await supabase.storage.from("hematrack-photos").createSignedUrls(paths, 3600)
    : { data: [] };

  const urlByPath = new Map((signedUrls ?? []).map((s) => [s.path, s.signedUrl]));
  const timeline = (photos ?? []).map((p) => ({
    ...p,
    url: urlByPath.get(p.photo_path) ?? null,
  }));

  const baseline = timeline.find((p) => p.kind === "baseline");
  const followups = timeline.filter((p) => p.kind === "followup");
  const latestFollowup = followups[followups.length - 1];

  const trendData = timeline
    .filter((p) => p.width_mm !== null && p.height_mm !== null)
    .map((p) => ({
      taken_at: p.taken_at,
      area_mm2: Math.round((p.width_mm as number) * (p.height_mm as number) * 10) / 10,
    }));

  function formatUkuran(p: { width_mm: number | null; height_mm: number | null }): string | null {
    if (p.width_mm !== null && p.height_mm !== null) return `${p.width_mm} × ${p.height_mm} mm`;
    if (p.width_mm !== null) return `Lebar ${p.width_mm} mm`;
    if (p.height_mm !== null) return `Tinggi ${p.height_mm} mm`;
    return null;
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <Link href={`/dashboard/anak/${childId}`} className="text-sm text-stone-500 hover:text-stone-700">
          ← Kembali
        </Link>
        <h1 className="mt-1 text-xl font-bold text-stone-900">{area.name}</h1>
        {area.notes && <p className="text-sm text-stone-600">{area.notes}</p>}
      </div>

      {baseline && latestFollowup && (
        <div className="rounded-2xl border border-stone-200 bg-white p-5">
          <p className="font-semibold text-stone-900">Perbandingan baseline vs terbaru</p>
          <div className="mt-4 grid grid-cols-2 gap-4">
            <div>
              <p className="mb-2 text-center text-xs font-medium text-stone-500">
                Baseline · {baseline.taken_at}
              </p>
              {baseline.url && (
                <Image
                  src={baseline.url}
                  alt="Foto baseline"
                  width={300}
                  height={300}
                  className="aspect-square w-full rounded-xl object-cover"
                  unoptimized
                />
              )}
              {formatUkuran(baseline) && (
                <p className="mt-2 text-center text-xs text-stone-600">{formatUkuran(baseline)}</p>
              )}
              {baseline.color && (
                <p className="text-center text-xs text-stone-600">Warna: {baseline.color}</p>
              )}
            </div>
            <div>
              <p className="mb-2 text-center text-xs font-medium text-stone-500">
                Terbaru · {latestFollowup.taken_at}
              </p>
              {latestFollowup.url && (
                <Image
                  src={latestFollowup.url}
                  alt="Foto follow-up terbaru"
                  width={300}
                  height={300}
                  className="aspect-square w-full rounded-xl object-cover"
                  unoptimized
                />
              )}
              {formatUkuran(latestFollowup) && (
                <p className="mt-2 text-center text-xs text-stone-600">{formatUkuran(latestFollowup)}</p>
              )}
              {latestFollowup.color && (
                <p className="text-center text-xs text-stone-600">Warna: {latestFollowup.color}</p>
              )}
            </div>
          </div>
        </div>
      )}

      <TrendChart data={trendData} />

      <UploadPhotoForm areaId={areaId} hasBaseline={!!baseline} />

      <div>
        <p className="mb-3 font-semibold text-stone-900">Timeline foto</p>
        {timeline.length === 0 ? (
          <p className="text-stone-600">Belum ada foto.</p>
        ) : (
          <ul className="space-y-3">
            {[...timeline].reverse().map((p) => (
              <li key={p.id} className="flex gap-4 rounded-xl border border-stone-200 bg-white p-4">
                {p.url && (
                  <Image
                    src={p.url}
                    alt={p.kind}
                    width={80}
                    height={80}
                    className="h-20 w-20 shrink-0 rounded-lg object-cover"
                    unoptimized
                  />
                )}
                <div className="min-w-0">
                  <p className="font-medium text-stone-900">
                    {p.kind === "baseline" ? "Baseline" : "Follow-up"} · {p.taken_at}
                  </p>
                  {formatUkuran(p) && (
                    <p className="text-sm text-stone-600">{formatUkuran(p)}</p>
                  )}
                  {p.color && <p className="text-sm text-stone-600">Warna: {p.color}</p>}
                  {p.notes && <p className="truncate text-sm text-stone-500">{p.notes}</p>}
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
