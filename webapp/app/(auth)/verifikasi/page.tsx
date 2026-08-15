import Link from "next/link";
import VerifyForm from "./VerifyForm";

export default async function VerifikasiPage({
  searchParams,
}: {
  searchParams: Promise<{ email?: string }>;
}) {
  const { email } = await searchParams;

  return (
    <div className="flex flex-1 items-center justify-center px-5 py-12">
      <div className="w-full max-w-sm">
        <Link href="/" className="mb-6 block text-center text-lg font-bold text-stone-900">
          HemaTrack
        </Link>
        <div className="rounded-2xl border border-stone-200 bg-white p-6">
          <h1 className="text-xl font-bold text-stone-900">Cek emailmu</h1>
          <p className="mt-1 text-sm text-stone-600">
            Kami sudah kirim email konfirmasi. Masukkan kode yang ada di email itu.
          </p>
          <div className="mt-5">
            <VerifyForm email={email ?? ""} />
          </div>
        </div>
      </div>
    </div>
  );
}
