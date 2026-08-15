import Link from "next/link";
import AuthForm from "../AuthForm";
import { signup } from "../actions";

export default async function SignupPage({
  searchParams,
}: {
  searchParams: Promise<{ redirect?: string }>;
}) {
  const { redirect } = await searchParams;
  const redirectTo = redirect?.startsWith("/dashboard") ? redirect : "/dashboard";

  return (
    <div className="flex flex-1 items-center justify-center px-5 py-12">
      <div className="w-full max-w-sm">
        <Link href="/" className="mb-6 block text-center text-lg font-bold text-stone-900">
          HemaTrack
        </Link>
        <div className="rounded-2xl border border-stone-200 bg-white p-6">
          <h1 className="text-xl font-bold text-stone-900">Daftar gratis</h1>
          <p className="mt-1 text-sm text-stone-600">
            Mulai dokumentasikan perkembangan hemangioma si kecil.
          </p>
          <div className="mt-5">
            <AuthForm mode="signup" action={signup} redirectTo={redirectTo} />
          </div>
        </div>
      </div>
    </div>
  );
}
