"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

function cleanRedirect(raw: FormDataEntryValue | null): string {
  const value = typeof raw === "string" ? raw : "";
  if (value.startsWith("/dashboard")) return value;
  return "/dashboard";
}

export async function signup(formData: FormData): Promise<{ error: string } | void> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    return { error: "Email dan kata sandi wajib diisi." };
  }
  if (password.length < 6) {
    return { error: "Kata sandi minimal 6 karakter." };
  }

  const supabase = await createClient();
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000";
  const { error } = await supabase.auth.signUp({
    email,
    password,
    options: { emailRedirectTo: `${siteUrl}/login` },
  });

  if (error) {
    return { error: terjemahkanError(error.message) };
  }
  redirect(`/verifikasi?email=${encodeURIComponent(email)}`);
}

export async function login(formData: FormData): Promise<{ error: string } | void> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  const target = cleanRedirect(formData.get("redirect"));

  if (!email || !password) {
    return { error: "Email dan kata sandi wajib diisi." };
  }

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    if (error.message.toLowerCase().includes("not confirmed")) {
      redirect(`/verifikasi?email=${encodeURIComponent(email)}`);
    }
    return { error: terjemahkanError(error.message) };
  }
  redirect(target);
}

export async function verifyCode(formData: FormData): Promise<{ error: string } | void> {
  const email = String(formData.get("email") ?? "").trim();
  const token = String(formData.get("token") ?? "").trim();

  if (!email || !token) {
    return { error: "Email dan kode konfirmasi wajib diisi." };
  }

  const supabase = await createClient();
  let { error } = await supabase.auth.verifyOtp({ email, token, type: "signup" });
  if (error) {
    const retry = await supabase.auth.verifyOtp({ email, token, type: "email" });
    error = retry.error;
  }

  if (error) {
    const m = error.message.toLowerCase();
    if (m.includes("expired") || m.includes("invalid") || m.includes("not found")) {
      return { error: "Kode salah atau sudah kedaluwarsa. Cek email terbaru atau daftar ulang." };
    }
    return { error: terjemahkanError(error.message) };
  }
  redirect("/dashboard");
}

export async function logout(): Promise<void> {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}

function terjemahkanError(msg: string): string {
  const m = msg.toLowerCase();
  if (m.includes("invalid login")) return "Email atau kata sandi salah.";
  if (m.includes("already registered") || m.includes("already been registered"))
    return "Email ini sudah terdaftar. Silakan masuk.";
  if (m.includes("rate limit"))
    return "Terlalu banyak percobaan. Coba lagi dalam beberapa menit.";
  if (m.includes("not confirmed"))
    return "Email belum dikonfirmasi. Masukkan kode dari emailmu di halaman verifikasi.";
  if (m.includes("email")) return "Email tidak valid.";
  return "Terjadi kesalahan. Coba lagi.";
}
