import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export default async function DetailAnakPage({
  params,
}: {
  params: Promise<{ childId: string }>;
}) {
  const { childId } = await params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: child } = await supabase
    .from("hematrack_children")
    .select("id, name, birth_date")
    .eq("id", childId)
    .eq("user_id", user!.id)
    .single();

  if (!child) notFound();

  const { data: areas } = await supabase
    .from("hematrack_areas")
    .select("id, name, notes")
    .eq("child_id", childId)
    .order("created_at", { ascending: false });

  return (
    <div className="mx-auto max-w-2xl">
      <Link href="/dashboard" className="text-sm text-stone-500 hover:text-stone-700">
        ← Semua anak
      </Link>
      <div className="mt-2 flex items-center justify-between">
        <h1 className="text-xl font-bold text-stone-900">{child.name}</h1>
        <Link
          href={`/dashboard/anak/${childId}/area/baru`}
          className="rounded-lg bg-rose-600 px-4 py-2 text-sm font-semibold text-white hover:bg-rose-700"
        >
          + Tambah area
        </Link>
      </div>

      {!areas || areas.length === 0 ? (
        <div className="mt-8 rounded-2xl border border-dashed border-stone-300 bg-white p-8 text-center">
          <p className="text-stone-600">Belum ada area hemangioma yang dicatat.</p>
          <Link
            href={`/dashboard/anak/${childId}/area/baru`}
            className="mt-3 inline-block font-medium text-rose-700"
          >
            Tambah area pertama
          </Link>
        </div>
      ) : (
        <ul className="mt-6 space-y-3">
          {areas.map((area) => (
            <li key={area.id}>
              <Link
                href={`/dashboard/anak/${childId}/area/${area.id}`}
                className="flex items-center justify-between rounded-xl border border-stone-200 bg-white px-4 py-4 hover:border-rose-300"
              >
                <div>
                  <p className="font-semibold text-stone-900">{area.name}</p>
                  {area.notes && <p className="text-sm text-stone-500">{area.notes}</p>}
                </div>
                <span className="text-stone-400">→</span>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
