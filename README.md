# 🧙‍♂️ MYSTIC REALMS: BOUNCE BACK
### Tutorial Grounds & Final Battle Edition
**Created by Dhoni and Prathik**

A complete, polished fantasy action-adventure platformer built in **Godot 4.x**, deeply integrating the Game Jam theme **"BOUNCE BACK"** across physics-driven combat, mobility, risk-reward loops, and progression. Features a realistic 30-second dark-to-light 3D choreographed cinematic entry sequence, prominent developer showcase for **Dhoni & Prathik**, the epic anthem **"Lord of the Mysteries - Dark Dream" by Curley Gao**, an interactive tutorial, and the extended **Final Battle** against the 10,000 HP 4-phase Primordial Void Emperor!

---

## 🎬 3D Entry Animation & Credits (Realistic Dark-to-Light 30s Sequence)
- **Cinematic 3D Opening Scene (`scenes/intro/intro_splash_3d.tscn`):**
  - **Dynamic Lighting Transition:**
    - Begins in pure mysterious pitch darkness where only the purple orb on the archmage's staff casts mystical point light on his silhouette.
    - Progressively brightens through overhead stage spotlights and soft ambient illumination as the wizard taps the ground.
    - Fully illuminates into a brilliant realistic 3D arena with metallic reflections on celestial rings, marble dais highlights, and cosmic rim lighting.
  - **Player Wand Dance & Spell Choreography:**
    - Hooded archmage performs rhythmic dancing steps, 360° pirouette spins, leaps, and wand flourishes.
    - Fires dynamic bouncing spell volleys that reflect in 3D off celestial rings with pitch-escalating crystalline chimes and fireworks.
  - **Developer Showcase (Dhoni & Prathik):**
    - High-visibility vector typography (`cinematic_black.ttf` & `cinematic_bold.ttf`) with deep contrast outlines and billboard rendering for razor-sharp legibility.
    - Dedicated developer spotlight nodes:
      - `★ GAME DEVELOPERS ★` (Gold shimmering header)
      - `DHONI & PRATHIK` (High-contrast cyan with golden outline)
      - `✦ CREATED BY DHONI AND PRATHIK ✦`
  - **5-Act Choreographed Timeline:**
    - **Act 1 (0.0s–6.0s): The Dark Silhouette** — Pitch black stage; only glowing purple staff orb illuminates wizard dancing with mystical wand flourishes.
    - **Act 2 (6.0s–12.0s): The Dawn of Light** — Staff tap ignites overhead spotlight and soft ambient glow; reveals `✦ MYSTIC REALMS • THE POWER OF MAGIC ✦`.
    - **Act 3 (12.0s–19.0s): Full Arena Illumination** — Sun, rim, and stage lights engage fully; high pirouette leap, cross-volley ricochets off metallic rings; monumental bounce-drop of `GAME: BOUNCE BACK`.
    - **Act 4 (19.0s–26.0s): Dedicated Developer Spotlight** — Skyward spell burst with fireworks; spotlights center directly onto `★ GAME DEVELOPERS ★ DHONI & PRATHIK`.
    - **Act 5 (26.0s–30.0s): Triumphant Stance** — Radiant victory stance with glowing wand aura, pulsing `[ PRESS SPACE / ENTER / CLICK TO PLAY ]` prompt, and smooth transition to Main Menu (or instant skip on any key/click).

---

## 🎮 Game Architecture: Two Dedicated Modes

### 1. ✨ Tutorial Grounds (`scenes/levels/level_tutorial.tscn`)
- Interactive signposts introducing core controls and mechanics:
  - **Sign 1 (Movement):** Walk with `[A]` / `[D]`, jump with `[Space]` or `[W]`.
  - **Sign 2 (Casting & Ricochet):** Fireball `[J]` or Left-Click, Freeze Power `[K]`, wall ricochet mechanics ($1\times \to 2\times \to 3\times$ damage).
  - **Sign 3 (Rocket Jumping):** Leap into the air, aim downward with mouse or `[S]`, and cast Fireball to launch skyward over high stone walls!
  - **Sign 4 (Chasm Air-Boost):** Jump forward over chasms and shoot downward in mid-air to gain height and forward momentum.
  - **Sign 5 (Portal):** Step through the ancient portal to enter the Final Battle.

### 2. ⚔️ The Final Battle (`scenes/levels/final_battle.tscn`)
- **Extended High-Stakes Platforming:**
  - 4 distinct celestial void platforming zones with floating ruins and moving platforms.
  - 3 progression checkpoints and 3 ruined shrines.
  - Deadly spiked pits, flying bats, shadow monsters, and fire demons.
- **The Ancient Astral Sanctum (Secret Room):**
  - Hidden behind a destructible secret wall (`scenes/objects/secret_wall.tscn`).
  - Contains astral crystals and the **God Relic Shrine** (`scenes/objects/god_relic_shrine.tscn`), which bestows **$+1,500$ Max HP**, **$+500$ Max MP**, accelerated mana regeneration, and **$+60\%$ spell damage**!
- **The Ultimate Boss Arena:**
  - Confront the **Primordial Void Emperor Malakor** (10,000 HP).

---

## 👑 The Boss: Primordial Void Emperor Malakor (10,000 HP)
- **4-Phase Transformation System:**
  - **Phase 1 (10,000 – 7,500 HP):** Obsidian Void Armor with Deep Violet Aura. Teleports and fires tracking dark energy orbs.
  - **Phase 2 (7,500 – 5,000 HP):** Crimson Void Surge with glowing red eye flares & fire trail. High-speed dash attacks (850 px/s), electric stun shockwaves, minion summons.
  - **Phase 3 (5,000 – 2,500 HP):** Astral Cosmic Electric Cyan with celestial wings. Deploys a 1,000 HP protective hexagonal void barrier, full-screen dark energy beam, dark siphon health regeneration (+350 HP/tick).
  - **Phase 4 (2,500 – 0 HP):** Supreme Apocalyptic Rage Mode. Solar Gold aura, 550 px/s sprint speed, massive screen-shaking void explosions, 14-orb spiral bullet hell, and relentless rage roaring.
- **Dedicated Boss Health Bar:** Real-time health, percentage, and dynamic phase badges (`[PHASE 1]` to `[PHASE 4: ULTIMATE RAGE]`).

---

## ⚡ Core Combat & "BOUNCE BACK" Mechanics

### 1. 🔮 Fireball `[J]` or Left-Click (Ricochet & Rocket Jump)
- **Wall & Floor Ricochet:** Projectiles bounce up to 3 times off surfaces.
- **Damage Scaling:** Each bounce multiplies damage ($1\times \to 2\times \to 3\times$).
- **Rocket-Jumping:** Aim downward with the mouse or hold `[S]` while casting to launch high into the air via explosion recoil (`velocity.y <= -420 px/s`).

### 2. ❄️ Freeze Power / Ice Blast `[K]`
- Launches a concentrated frost orb that chills and freezes enemies solid for 4.0 seconds, disabling their attacks and movement.

### 3. 🛡️ Timed Parry & Projectile Deflection
- Press **Right-Click** or **[Shift]** right before an enemy projectile hits.
- Deflects incoming missiles directly back at foes with **$3\times$ speed**, **$3\times$ damage**, and an immediate stun!

### 4. 🏛️ Ruined Shrines
- Dormant stone shrines awaken when struck by spells, permanently increasing Max HP (+30) or Movement Speed (+25).

---

## 🕹️ Controls Reference

| Action | Primary Key | Alternate | Description |
|---|---|---|---|
| **Move Left / Right** | `A` / `D` | `←` / `→` | Smooth physics-based running |
| **Jump** | `Space` | `W` / `↑` | Jump with variable height cut & coyote time |
| **Fireball** | `J` | Left Mouse Click | Ricocheting spell (1x $\to$ 2x $\to$ 3x DMG). Rocket-jumps when aimed down |
| **Freeze Power** | `K` | — | Ice Blast that freezes enemies in ice for 4s |
| **Parry / Deflect** | Right Mouse Click | `Shift` | Reflects enemy projectiles at 3x speed and 3x damage |
| **Restart Checkpoint**| `R` | — | Respawn at last reached checkpoint |
| **Pause Menu** | `Esc` | `P` | Resume, Restart, Level Select, Main Menu |

---

## 💀 Persistent Death & Respawn Tracking
- **Live HUD Display:** Tracks deaths and respawns in real-time (`💀 Deaths: X  |  🔄 Respawns: Y`).
- **Main Menu Career Stats:** Saves overall player career statistics to `user://mystic_realms_save.json`.
- **Game Over & Victory Screens:** Summarizes stats upon completion or defeat.

---

## 🎵 Featured Music
- **Title:** *"Lord of Mysteries - Dark Dream"*
- **Artist:** Curley Gao
- **Path:** `assets/music/dark_dream.mp3`

---

## 🚀 Running the Game

### 1. Get the files
**Option A — Download ZIP (easiest):** Click the green **`<> Code`** button on this page → **Download ZIP** → unzip anywhere.

**Option B — Clone with Git:**
```bash
git clone https://github.com/prathikvardhan/Mystic-Realms.git
cd Mystic-Realms
```

### 2. Install Godot
Download the free engine from [godotengine.org/download](https://godotengine.org/download) (standard **Godot 4.7** — no C#/.NET build needed).

### 3. Open and play
In the Godot Project Manager, click **Import** → select the `project.godot` file inside the folder → **Import & Edit** → press **F5**.
The engine will import all assets automatically on first open (this takes a minute or two), then the 3D cinematic intro plays.

### In Godot Engine
Open the project directory in **Godot 4.x** (compatible with 4.2+ / 4.7+ Forward+).
- **Default Main Scene:** `scenes/intro/intro_splash_3d.tscn` (plays the 3D cinematic opening, then loads Main Menu).
- **Direct Level Launch:**
  ```bash
  # Final Battle
  godot scenes/levels/final_battle.tscn

  # Tutorial Grounds
  godot scenes/levels/level_tutorial.tscn
  ```

### Automated In-Engine Test Suite
Run the automated test runner headless to verify all systems:
```bash
godot --headless scenes/tests/test_runner.tscn
```
*All 13 automated test suites pass with 100% success rate.*

---

## 📜 Credits & License
- **Developed by:** Dhoni and Prathik
- **Game Jam Theme:** BOUNCE BACK
- **Engine:** Godot 4.x
- **Platform:** macOS, Windows, Linux
