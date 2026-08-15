"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export async function addChild(formData: FormData): Promise<{ error: string } | void> {
  const name = String(formData.get("name") ?? "").trim();
  const birthDate = String(formData.get("birth_date") ?? "").trim();

  if (!name) return { error: "Nama anak wajib diisi." };

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Sesi berakhir, silakan masuk lagi." };

  const { data, error } = await supabase
    .from("hematrack_children")
    .insert({ user_id: user.id, name, birth_date: birthDate || null })
    .select("id")
    .single();

  if (error) return { error: "Gagal menyimpan profil anak." };
  redirect(`/dashboard/anak/${data.id}`);
}

export async function addArea(
  childId: string,
  formData: FormData
): Promise<{ error: string } | void> {
  const name = String(formData.get("name") ?? "").trim();
  const notes = String(formData.get("notes") ?? "").trim();

  if (!name) return { error: "Nama/lokasi area wajib diisi." };

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Sesi berakhir, silakan masuk lagi." };

  const { data, error } = await supabase
    .from("hematrack_areas")
    .insert({ child_id: childId, user_id: user.id, name, notes: notes || null })
    .select("id")
    .single();

  if (error) return { error: "Gagal menyimpan area." };
  redirect(`/dashboard/anak/${childId}/area/${data.id}`);
}

export async function addPhoto(
  areaId: string,
  formData: FormData
): Promise<{ error: string } | void> {
  const kind = String(formData.get("kind") ?? "followup");
  const widthRaw = String(formData.get("width_mm") ?? "").trim();
  const heightRaw = String(formData.get("height_mm") ?? "").trim();
  const color = String(formData.get("color") ?? "").trim();
  const takenAt = String(formData.get("taken_at") ?? "").trim();
  const notes = String(formData.get("notes") ?? "").trim();
  const file = formData.get("photo") as File | null;

  if (!file || file.size === 0) return { error: "Foto wajib diunggah." };
  if (!["baseline", "followup"].includes(kind)) return { error: "Jenis foto tidak valid." };

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Sesi berakhir, silakan masuk lagi." };

  const ext = file.name.split(".").pop() || "jpg";
  const path = `${user.id}/${areaId}/${Date.now()}.${ext}`;

  const { error: uploadError } = await supabase.storage
    .from("hematrack-photos")
    .upload(path, file, { contentType: file.type });
  if (uploadError) return { error: "Gagal mengunggah foto." };

  const { error: insertError } = await supabase.from("hematrack_photos").insert({
    area_id: areaId,
    user_id: user.id,
    kind,
    photo_path: path,
    width_mm: widthRaw ? Number(widthRaw) : null,
    height_mm: heightRaw ? Number(heightRaw) : null,
    color: color || null,
    taken_at: takenAt || new Date().toISOString().slice(0, 10),
    notes: notes || null,
  });

  if (insertError) {
    await supabase.storage.from("hematrack-photos").remove([path]);
    return { error: "Gagal menyimpan data foto." };
  }

  revalidatePath(`/dashboard/anak`, "layout");
}
