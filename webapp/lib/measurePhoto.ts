const COIN_PROMPT = `Foto ini memuat koin Rp100 Indonesia (diameter tepat 22mm) yang diletakkan sebagai referensi skala di dekat area kulit (hemangioma / tanda lahir) yang ingin diukur.

Langkah:
1. Temukan koin Rp100 di foto. Ukur diameter koin dalam pixel pada dua sumbu: sumbu terpanjang (coin_major_px) dan sumbu terpendek yang tegak lurus terhadapnya (coin_minor_px). Jika foto diambil tegak lurus (90°) dari atas, koin akan tampak bulat sempurna sehingga coin_major_px ≈ coin_minor_px; jika foto miring, koin akan tampak oval sehingga coin_minor_px < coin_major_px.
2. Ukur juga sisi terpendek foto dalam pixel (image_short_side_px).
3. Gunakan diameter koin (rata-rata coin_major_px dan coin_minor_px) untuk dapat rasio pixel-ke-mm (22mm = diameter koin).
4. Temukan batas area kulit (hemangioma/tanda lahir) yang paling menonjol di foto.
5. Hitung lebar dan tinggi area tersebut dalam milimeter menggunakan rasio dari koin.
6. Deskripsikan warna dominan area tersebut dalam Bahasa Indonesia singkat (mis. "merah terang", "merah tua", "keunguan", "merah muda", "kecoklatan").

Jika koin tidak terlihat jelas di foto, set "coin_found": false dan field ukuran/warna/pixel jadi null, isi "note" singkat menjelaskan kenapa.

Balas HANYA dengan JSON valid, tanpa teks lain, format persis:
{"coin_found": boolean, "width_mm": number|null, "height_mm": number|null, "color": string|null, "coin_major_px": number|null, "coin_minor_px": number|null, "image_short_side_px": number|null, "note": string}`;

export type PhotoMeasurement = {
  coin_found: boolean;
  width_mm: number | null;
  height_mm: number | null;
  color: string | null;
  note: string;
  /** min(coin_minor_px, coin_major_px) / max(...) — 1 = koin bulat sempurna (foto tegak lurus), makin kecil = makin miring. Null kalau AI tidak bisa mengukur dua sumbu. */
  coinCircularity: number | null;
  /** diameter koin relatif terhadap sisi terpendek foto (0-1). Terlalu kecil = koin terlalu jauh, terlalu besar = koin terlalu dekat/dominan. */
  coinRelativeSize: number | null;
};

export async function measurePhotoWithCoin(
  imageBase64: string,
  mimeType: string
): Promise<PhotoMeasurement | { error: string }> {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) return { error: "Fitur pengukuran AI belum dikonfigurasi." };

  try {
    const response = await fetch(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent",
      {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "x-goog-api-key": apiKey,
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                { inline_data: { mime_type: mimeType, data: imageBase64 } },
                { text: COIN_PROMPT },
              ],
            },
          ],
          generationConfig: { responseMimeType: "application/json" },
        }),
      }
    );

    if (!response.ok) {
      return { error: `Gagal memanggil AI pengukuran (${response.status}).` };
    }

    const data = await response.json();
    const text: string = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) return { error: "AI tidak mengembalikan hasil yang bisa dibaca." };

    const parsed = JSON.parse(jsonMatch[0]);
    const majorPx = typeof parsed.coin_major_px === "number" ? parsed.coin_major_px : null;
    const minorPx = typeof parsed.coin_minor_px === "number" ? parsed.coin_minor_px : null;
    const shortSidePx =
      typeof parsed.image_short_side_px === "number" ? parsed.image_short_side_px : null;

    const coinCircularity =
      majorPx && minorPx && majorPx > 0 ? Math.min(majorPx, minorPx) / Math.max(majorPx, minorPx) : null;
    const coinRelativeSize =
      majorPx && minorPx && shortSidePx && shortSidePx > 0
        ? (majorPx + minorPx) / 2 / shortSidePx
        : null;

    return {
      coin_found: Boolean(parsed.coin_found),
      width_mm: typeof parsed.width_mm === "number" ? parsed.width_mm : null,
      height_mm: typeof parsed.height_mm === "number" ? parsed.height_mm : null,
      color: typeof parsed.color === "string" ? parsed.color : null,
      note: typeof parsed.note === "string" ? parsed.note : "",
      coinCircularity,
      coinRelativeSize,
    };
  } catch {
    return { error: "Gagal memproses pengukuran AI." };
  }
}
