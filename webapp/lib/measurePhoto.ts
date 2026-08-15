const COIN_PROMPT = `Foto ini memuat koin Rp100 Indonesia (diameter tepat 22mm) yang diletakkan sebagai referensi skala di dekat area kulit (hemangioma / tanda lahir) yang ingin diukur.

Langkah:
1. Temukan koin Rp100 di foto, ukur diameternya dalam pixel untuk dapat rasio pixel-ke-mm.
2. Temukan batas area kulit (hemangioma/tanda lahir) yang paling menonjol di foto.
3. Hitung lebar dan tinggi area tersebut dalam milimeter menggunakan rasio dari koin.
4. Deskripsikan warna dominan area tersebut dalam Bahasa Indonesia singkat (mis. "merah terang", "merah tua", "keunguan", "merah muda", "kecoklatan").

Jika koin tidak terlihat jelas di foto, set "coin_found": false dan field ukuran/warna jadi null, isi "note" singkat menjelaskan kenapa.

Balas HANYA dengan JSON valid, tanpa teks lain, format persis:
{"coin_found": boolean, "width_mm": number|null, "height_mm": number|null, "color": string|null, "note": string}`;

export type PhotoMeasurement = {
  coin_found: boolean;
  width_mm: number | null;
  height_mm: number | null;
  color: string | null;
  note: string;
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
    return {
      coin_found: Boolean(parsed.coin_found),
      width_mm: typeof parsed.width_mm === "number" ? parsed.width_mm : null,
      height_mm: typeof parsed.height_mm === "number" ? parsed.height_mm : null,
      color: typeof parsed.color === "string" ? parsed.color : null,
      note: typeof parsed.note === "string" ? parsed.note : "",
    };
  } catch {
    return { error: "Gagal memproses pengukuran AI." };
  }
}
