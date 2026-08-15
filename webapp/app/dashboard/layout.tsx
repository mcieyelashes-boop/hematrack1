import Link from "next/link";
import { logout } from "../(auth)/actions";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-1 flex-col">
      <header className="flex items-center justify-between border-b border-stone-200 bg-white px-5 py-4 sm:px-8">
        <Link href="/dashboard" className="text-lg font-bold text-stone-900">
          HemaTrack
        </Link>
        <form action={logout}>
          <button type="submit" className="text-sm text-stone-600 hover:text-stone-900">
            Keluar
          </button>
        </form>
      </header>
      <main className="flex-1 px-5 py-8 sm:px-8">{children}</main>
    </div>
  );
}
