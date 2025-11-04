import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { ProfessionalsAPI } from "@/lib/api";

export default function Index() {
  const [ping, setPing] = useState<string | null>(null);
  const [count, setCount] = useState<number | null>(null);

  useEffect(() => {
    let mounted = true;
    async function load() {
      try {
        const list = await ProfessionalsAPI.list();
        if (mounted) {
          setCount(Array.isArray(list) ? list.length : null);
          setPing("ok");
        }
      } catch (e) {
        if (mounted) {
          setPing("offline");
          setCount(null);
        }
      }
    }
    load();
    return () => {
      mounted = false;
    };
  }, []);

  return (
    <main className="min-h-[70vh] bg-gradient-to-br from-slate-50 to-white">
      <section className="container mx-auto py-16 px-6">
        <div className="grid gap-10 lg:grid-cols-2 lg:items-center">
          <div>
            <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl">
              Unified professional sign-ups, one beautiful dashboard
            </h1>
            <p className="mt-4 max-w-2xl text-lg text-slate-600">
              Collect, consolidate, and manage professionals who sign up via
              your website, partner referrals, or internal additions — fast and
              reliably.
            </p>

            <div className="mt-8 flex flex-wrap gap-3">
              <Link to="/add" className="inline-block">
                <button className="rounded-md bg-primary px-5 py-3 text-sm font-medium text-white shadow-sm hover:opacity-95">
                  Add Professional
                </button>
              </Link>
              <Link to="/professionals" className="inline-block">
                <button className="rounded-md border border-input bg-white px-5 py-3 text-sm font-medium text-slate-700 hover:bg-muted">
                  View Professionals
                </button>
              </Link>
            </div>

            <dl className="mt-10 grid grid-cols-1 gap-6 sm:grid-cols-3">
              <div className="rounded-lg border bg-card p-4">
                <dt className="text-sm font-medium text-muted-foreground">
                  Sources
                </dt>
                <dd className="mt-2 text-lg font-semibold text-foreground">
                  Direct • Partner • Internal
                </dd>
              </div>
              <div className="rounded-lg border bg-card p-4">
                <dt className="text-sm font-medium text-muted-foreground">
                  Professionals
                </dt>
                <dd className="mt-2 text-lg font-semibold text-foreground">
                  {count ?? "—"}
                </dd>
              </div>
              <div className="rounded-lg border bg-card p-4">
                <dt className="text-sm font-medium text-muted-foreground">
                  API
                </dt>
                <dd className="mt-2 text-lg font-semibold text-foreground">
                  {ping ?? "—"}
                </dd>
              </div>
            </dl>

            <p className="mt-6 text-sm text-muted-foreground">
              Built with Django REST API (prototype) and a modern React
              frontend.
            </p>
          </div>

          <div className="order-first lg:order-last">
            <div className="relative isolate overflow-hidden rounded-2xl bg-gradient-to-tr from-indigo-600 to-sky-500 px-6 py-8 shadow-lg sm:px-10 sm:py-12">
              <svg
                aria-hidden="true"
                className="absolute inset-0 -z-10 h-full w-full opacity-20"
                viewBox="0 0 1024 1024"
              >
                <defs>
                  <linearGradient id="g" x1="0" x2="1">
                    <stop offset="0" stopColor="#8b5cf6" />
                    <stop offset="1" stopColor="#06b6d4" />
                  </linearGradient>
                </defs>
                <rect width="100%" height="100%" fill="url(#g)" />
              </svg>
              <div className="flex items-center justify-between gap-6">
                <div className="w-3/5">
                  <h3 className="text-2xl font-semibold text-white">
                    Signups unified
                  </h3>
                  <p className="mt-2 text-sm text-white/90">
                    A single API to collect professionals from multiple sources
                    and deduplicate automatically.
                  </p>

                  <ul className="mt-4 space-y-2 text-sm text-white/90">
                    <li>• Unique email/phone validation</li>
                    <li>• Bulk upsert endpoint for partner imports</li>
                    <li>• Optional resume upload & parsing</li>
                  </ul>

                  <div className="mt-6">
                    <Link to="/professionals" className="inline-block">
                      <button className="rounded-md bg-white/90 px-4 py-2 text-sm font-medium text-slate-900">
                        Go to dashboard
                      </button>
                    </Link>
                  </div>
                </div>
                <div className="hidden w-2/5 rounded-lg bg-white/20 p-4 text-white/90 sm:block">
                  <div className="h-40 w-full rounded-md bg-gradient-to-br from-white/30 to-white/10" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="border-t bg-white/50 py-12">
        <div className="container mx-auto px-6">
          <h2 className="text-lg font-medium text-slate-900">How it works</h2>
          <div className="mt-6 grid gap-6 sm:grid-cols-3">
            <div className="rounded-lg border bg-card p-6">
              <h3 className="font-semibold">Collect</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Receive signups via direct form, partner bulk uploads, or
                internal adds.
              </p>
            </div>
            <div className="rounded-lg border bg-card p-6">
              <h3 className="font-semibold">Consolidate</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Upsert logic ensures unique profiles by email or phone.
              </p>
            </div>
            <div className="rounded-lg border bg-card p-6">
              <h3 className="font-semibold">Manage</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Filter by source, review resumes, and export as needed.
              </p>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
