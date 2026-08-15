import Link from "next/link";

export default function LandingPage() {
  return (
    <div className="flex flex-1 flex-col">
      <header className="flex items-center justify-between px-5 py-5 sm:px-8">
        <span className="text-lg font-bold text-stone-900">HemaTrack</span>
        <nav className="flex items-center gap-3 text-sm">
          <Link href="/login" className="text-stone-700 hover:text-stone-900">
            Masuk
          </Link>
          <Link
            href="/signup"
            className="rounded-lg bg-rose-600 px-4 py-2 font-semibold text-white hover:bg-rose-700"
          >
            Daftar gratis
          </Link>
        </nav>
      </header>

      <main className="flex flex-1 flex-col items-center px-5 py-12 text-center sm:px-8">
        <div className="max-w-xl">
          <h1 className="text-3xl font-bold text-stone-900 sm:text-4xl">
            Pantau perkembangan hemangioma anak dengan tenang
          </h1>
          <p className="mt-4 text-stone-600">
            Simpan foto baseline dan follow-up, catat ukuran dari waktu ke waktu, dan lihat
            tren perkembangannya dalam satu tempat — supaya lebih mudah didiskusikan dengan
            dokter anak.
          </p>
          <div className="mt-8 flex justify-center gap-3">
            <Link
              href="/signup"
              className="rounded-lg bg-rose-600 px-6 py-3 font-semibold text-white hover:bg-rose-700"
            >
              Mulai gratis
            </Link>
            <Link
              href="/login"
              className="rounded-lg border border-stone-300 px-6 py-3 font-semibold text-stone-700 hover:bg-stone-100"
            >
              Sudah punya akun
            </Link>
          </div>
        </div>

        <div className="mt-16 grid w-full max-w-3xl gap-4 text-left sm:grid-cols-3">
          <div className="rounded-2xl border border-stone-200 bg-white p-5">
            <p className="font-semibold text-stone-900">Profil multi-anak</p>
            <p className="mt-1 text-sm text-stone-600">
              Kelola dokumentasi untuk lebih dari satu anak dalam satu akun.
            </p>
          </div>
          <div className="rounded-2xl border border-stone-200 bg-white p-5">
            <p className="font-semibold text-stone-900">Foto & ukuran per area</p>
            <p className="mt-1 text-sm text-stone-600">
              Catat foto baseline dan follow-up beserta ukuran untuk tiap area hemangioma.
            </p>
          </div>
          <div className="rounded-2xl border border-stone-200 bg-white p-5">
            <p className="font-semibold text-stone-900">Grafik tren</p>
            <p className="mt-1 text-sm text-stone-600">
              Lihat perkembangan ukuran dari waktu ke waktu dalam bentuk grafik.
            </p>
          </div>
        </div>

        <p className="mt-12 max-w-md text-xs text-stone-500">
          HemaTrack adalah alat bantu dokumentasi visual saja, bukan alat diagnostik medis.
          Selalu konsultasikan kondisi anak ke dokter spesialis.
        </p>
      </main>
    </div>
  );
}
