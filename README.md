# COIN RUSH — roblox-game-01

Arcade 2D di Roblox: kumpulkan koin emas, hindari bola berduri. Satu ronde
60 detik, 3 nyawa, level naik tiap 15 detik. Kontrol: WASD / tombol panah
di keyboard, atau 4 tombol sentuh di layar (HP).

## Cara main

- **Start**: tekan MAIN, koin mulai bermunculan di arena.
- **Koin** (+10 poin): ambil beruntun dalam 3 detik untuk menjaga combo —
  tiap koin ke-5 beruntun dapat bonus +25.
- **Bola berduri**: kena = −1 nyawa + kebal sesaat (pemain berkedip).
- **Akhir**: waktu habis atau nyawa habis — skor akhir dikirim ke server
  dan disimpan sebagai Best Score di leaderboard.

## Struktur

- `main.ts` — program entrypoint (Node 22): menyalin game ke `/output`
  dan menulis `dossier.json`.
- `game.rbxl` — place biner, dibangun dengan Rojo 7.7.1:
  `rojo build default.project.json --output game.rbxl`
- `src/client/Game.client.luau` — loop utama + HUD.
- `src/client/CoinRush/` — modul: `Config`, `GameState`, `Arena` (UI),
  `Controls` (ContextActionService + tombol sentuh), `Spawner`
  (koin & rintangan).
- `src/server/init.server.luau` — leaderstats + validasi skor akhir.
- `screenshots/` — 3 tangkapan layar dari HP (start, play, end).
- `PLAY.json` — tautan experience Roblox yang sudah Public.
- `vendor/makefun-roblox.ts` — pustaka dossier dari kit, tanpa diubah.

## Status

Game sudah jadi dan terverifikasi lokal. Menunggu publish: experience
Baseplate Public + `PLAY.json` berisi place_id/universe_id asli, lalu
3 screenshot dari HP sebelum submit.

Lisensi: MIT.
