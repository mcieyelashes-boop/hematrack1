import Link from "next/link";
import { createClient } from "@/lib/supabase/server";

function hitungUsia(birthDate: string | null): string {
  if (!birthDate) return "";
  const birth = new Date(birthDate);
  const now = new Date();
  let months = (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth());
  if (now.getDate() < birth.getDate()) months -= 1;
  if (months < 0) return "";
  if (months < 12) return `${months} bulan`;
  const years = Math.floor(months / 12);
  const rest = months % 12;
  return rest > 0 ? `${years} th ${rest} bln` : `${years} tahun`;
}

export default async function DashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: children } = await supabase
    .from("hematrack_children")
    .select("id, name, birth_date")
    .eq("user_id", user!.id)
    .order("created_at", { ascending: false });

  return (
    <div className="mx-auto max-w-2xl">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-stone-900">Anak</h1>
        <Link
          href="/dashboard/anak/baru"
          className="rounded-lg bg-rose-600 px-4 py-2 text-sm font-semibold text-white hover:bg-rose-700"
        >
          + Tambah anak
        </Link>
      </div>

      {!children || children.length === 0 ? (
        <div className="mt-8 rounded-2xl border border-dashed border-stone-300 bg-white p-8 text-center">
          <p className="text-stone-600">Belum ada profil anak.</p>
          <Link
            href="/dashboard/anak/baru"
            className="mt-3 inline-block font-medium text-rose-700"
          >
            Tambah profil anak pertama
          </Link>
        </div>
      ) : (
        <ul className="mt-6 space-y-3">
          {children.map((child) => (
            <li key={child.id}>
              <Link
                href={`/dashboard/anak/${child.id}`}
                className="flex items-center justify-between rounded-xl border border-stone-200 bg-white px-4 py-4 hover:border-rose-300"
              >
                <div>
                  <p className="font-semibold text-stone-900">{child.name}</p>
                  <p className="text-sm text-stone-500">{hitungUsia(child.birth_date)}</p>
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
