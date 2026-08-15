"use client";

import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";

export default function TrendChart({
  data,
}: {
  data: { taken_at: string; size_mm: number }[];
}) {
  if (data.length < 2) return null;

  return (
    <div className="rounded-2xl border border-stone-200 bg-white p-5">
      <p className="font-semibold text-stone-900">Tren ukuran (mm)</p>
      <div className="mt-4 h-56 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={{ top: 5, right: 12, left: -12, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e7e5e4" />
            <XAxis dataKey="taken_at" tick={{ fontSize: 12, fill: "#78716c" }} />
            <YAxis tick={{ fontSize: 12, fill: "#78716c" }} />
            <Tooltip />
            <Line type="monotone" dataKey="size_mm" stroke="#e11d48" strokeWidth={2} dot={{ r: 3 }} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
