# PRD — Lab 7: Chain Reaction (working title)

Defold Game Jam 2026 entry. This document is the single source of truth for building the game with Claude Code. If code and this PRD disagree, the PRD wins until it is updated.

---

## 0. Instructions for Claude Code (read first)

1. **You write code only. You never create game assets.** Do not generate, draw, synthesize, or download images, sprites, tilesources, fonts, sounds, or music. All assets are made by the developer. See §9. *Exception agreed 2026-09-27:* the HUD icons (antidote vials, gas and tower icons) and the LAB-AI portrait are simple shapes built in GUI code (`modules/ui.lua`), with no image files; this is disclosed in §1.1.
2. Until the developer's assets exist, use **only** placeholder graphics already shipped with Defold under `/builtins/` (for example a builtin particle image tinted with `tint`) and the builtin font. Reference every asset by the exact path in the Asset Manifest (§9.2) so real files can be dropped in without code changes.
3. Every gameplay number lives in `modules/config.lua`. No magic numbers in scripts.
4. Work milestone by milestone (§12). Finish and verify one milestone before starting the next. After each milestone, list what was done and what the developer must test.
5. The game must run in the Defold editor, as an HTML5 bundle, and on itch.io **without** Wavedash. All Wavedash calls go through `modules/wd.lua`, which is a no-op outside Wavedash.
6. Keep the code simple and readable. Prefer Defold messages and plain Lua modules over clever abstractions. No third-party libraries except the Wavedash SDK dependency.
7. Do not add features that are not in this PRD. Put ideas in a "Suggestions" note instead.

---

## 1. Jam rules and constraints (non-negotiable)

Source: https://itch.io/jam/defold-game-jam-2026

| Rule | What it means for us |
|---|---|
| Engine | Must be made with **Defold**. |
| Theme | **CHAIN REACTION.** The theme must be obvious within the first minute of play (§3). |
| Deadline | Submissions close **2026-10-04 21:59:59 CEST** = **2026-10-05 01:29 IST**. Our internal deadline is **Oct 3, 23:00 IST** (§12). |
| Platform | Playable on PC or in a browser (HTML5). No extra hardware or software. We ship an **HTML5 build**. |
| Content | No pornography, racism, hate speech, or anything illegal. Zombie/lab horror is fine; keep gore cartoonish. |
| Age | Submitter must be 13+ (or a parent/guardian submits). |
| Assets | Only use art, audio, code, and libraries we have the legal right to use. Developer-made assets satisfy this; Wavedash SDK is Apache-2.0. |
| AI use | Reasonable AI use is allowed, **but the game page must briefly state what AI was used for.** See §1.1. |
| Ownership | The game stays ours; the jam may feature it in videos. |
| Voting | Rated in Overall, Presentation, and Game Design. Winners announced 2026-10-11. |

### 1.1 AI disclosure (paste on the itch.io page)

> **Font:** Bangers by Vernon Adams (The Bangers Project Authors), SIL Open Font License 1.1.
>
> **AI usage:** Game code was written with the help of Claude Code (Anthropic), directed and reviewed by me, including a few simple UI shapes drawn in code (the antidote vials, gas/tower icons and the LAB-AI monitor face). All sprite art, animation, sound, music, and writing were created by me without AI.

Adjust if anything changes (e.g. if AI helps with dialog text, say so).

### 1.2 Wavedash challenge (optional prize)

- Deploy the game to **Wavedash** and put the Wavedash link in the itch.io game page description.
- Integration uses `wvdsh/sdk-defold` **1.2.0** (§10).

### 1.3 Submission checklist

- [ ] HTML5 build uploaded to itch.io, "This file will be played in the browser" checked, tested in Chrome and Firefox
- [ ] Submitted to the jam page before the deadline
- [ ] AI disclosure on the game page
- [ ] Controls and short rules on the game page
- [ ] Wavedash link in description (for the Wavedash challenge)
- [ ] Cover image, 3+ screenshots, one GIF showing a chain reaction
- [ ] Contact info on the page (needed if we win)

---

## 2. Game summary

**Pitch:** A contained outbreak in a single lab room. You are the scientist. Subject Zero is loose, and every creature it infects spreads the infection further. Stun, gas, and bait your way to the lab's research terminals, upload your data, and survive the escalating chain reaction as long as you can.

- **Genre:** top-down arcade survival, endless, high score
- **Session length:** 2–6 minutes per run
- **Camera:** single fixed room, whole room visible (no scrolling)
- **Resolution:** 1280×720 logical, scale to fit, keep aspect ratio
- **Win condition:** none (endless). **Lose condition:** the player fully turns into a zombie.

---

## 3. How the theme shows up

The chain reaction must be **visible**, not implied:

1. **Infection cascades:** zombie bites animal → animal turns → it bites the next one. Each infection plays a visible pulse/link effect between source and target.
2. **Mutation bursts:** every mutation, each zombie releases an infection pulse that can hit caged animals nearby, triggering new cascades.
3. **Stun chains:** stun pulses jump between zombies that are close together, drawn as a visible arc.
4. **Gas breaks chains:** gas clouds stop infection from spreading through them.
5. **Score rewards chains:** longer stun chains and stopped cascades are worth more (§6).

---

## 4. Core loop

1. Move around the room, avoid zombies. Reach the lit research terminal and upload data (§5.10).
2. Place stun towers where zombies will group.
3. Throw gas to break cascades and slow mutation.
4. Release caged animals to distract zombies (they may become zombies later).
5. Survive mutations every 30 s as the room escalates.
6. If touched, you are infected: drink an antidote within 30 s or turn.
7. Game over → score, leaderboard rank, retry.

---

## 5. Mechanics (all numbers are defaults in `config.lua`)

### 5.1 Player (scientist)
- 8-direction movement, speed `PLAYER_SPEED = 220` px/s.
- Collides with walls and cages; passes through gas.
- States: `normal`, `infected`, `drinking`, `turned` (game over).

### 5.2 Controls

| Action | Keyboard | Mouse |
|---|---|---|
| Move | WASD / arrow keys | — |
| Place stun tower | E (at player position) | — |
| Throw gas | G (lands at mouse cursor, max range) | aim |
| Release nearest cage | F (within `RELEASE_RANGE = 60`) | — |
| Drink antidote | Q | — |
| Advance dialog | Space / Enter | left click |
| Pause | Esc / P | — |

Show a small controls reminder on the pause screen.

### 5.3 Zombies
- Run starts with **1 zombie (Subject Zero)** at the room center.
- Target selection: nearest of {player, free animals} anywhere in the room (`ZOMBIE_SIGHT` is infinite); animals get a `BAIT_BIAS = 80` px advantage, so a nearby released animal pulls zombies off the player.
- Base speed `ZOMBIE_SPEED = 100` (lowered from 120 after the M1 playtest).
- Touching the player → player becomes `infected` (if `normal`).
- Touching a free animal → animal becomes infected.
- Stunned zombies cannot move, bite, or emit mutation bursts.

### 5.4 Animals
- `CAGE_COUNT = 20` cages scattered at random each run (no systematic or symmetric layout), each with one animal (types are visual only: rabbit, rat, cat — developer's art). Placement keeps a minimum spacing between cages and stays clear of spawns, terminals, the HUD strip and furniture painted into the floor (`CAGE_KEEP_CLEAR`).
- Released animals flee from the nearest zombie at `ANIMAL_SPEED = 150`.
- Infected animal: shows its zombie frames and flashes for `ANIMAL_TURN_TIME = 3` s, then becomes a **zombie version of itself** (same small size, its own zombie frames) at the current mutation tier. It chases, bites, mutates, splits and can be stunned like any zombie. Only Subject Zero and its splits are humanoid zombies.
- Caged animals can also be infected by mutation bursts (§5.7). The cage breaks and the animal turns.
- Released animals count for `BAIT` achievement when a zombie retargets to them.

### 5.5 Stun towers
- Max `TOWER_MAX = 3` active; placing a 4th removes the oldest.
- Placement cooldown `TOWER_COOLDOWN = 5` s.
- Every `TOWER_PULSE_INTERVAL = 3` s, stuns the nearest zombie within `TOWER_RANGE = 140`.
- **Chain:** from a stunned zombie, the stun jumps to the nearest unstunned zombie within `CHAIN_RADIUS = 110`, up to `CHAIN_MAX = 8` jumps. Draw an arc per jump.
- Each tower disappears `TOWER_LIFETIME = 12` s after placement.
- Stun duration `STUN_TIME = 2.5` s. Stunned zombie gets `STUN_IMMUNE = 1` s immunity after.

### 5.6 Mutation gas
- `GAS_CHARGES = 3` at start; +1 charge every `GAS_REGEN = 20` s, max 3.
- Throw range `GAS_RANGE = 300`; cloud radius `GAS_RADIUS = 90`; lasts `GAS_DURATION = 6` s.
- Inside gas: zombies move at `GAS_SLOW = 0.5`× speed; **infection cannot pass into or out of the cloud** (bites and bursts are blocked).
- A zombie standing in gas when a mutation happens does not mutate that cycle.
- Blocking an infection that would otherwise have happened counts as a "cascade stopped".

### 5.7 Mutation
- Every `MUTATION_INTERVAL = 30` s. Show a countdown bar; warning flash + sound at 5 s left.
- Each zombie that mutates gains +1 tier (max tier 4) and emits a **burst** of radius `BURST_RADIUS = 120` that infects caged or free animals in range (blocked by gas).
- Tier effects:
  - Tier 1: +20% speed
  - Tier 2: visible glow (sight bonus has no effect while sight is infinite)
  - Tier 3: splits into two zombies of tier 3
  - Tier 4: +20% speed, burst radius +50%
- Hard cap `ZOMBIE_MAX = 30` alive zombies (extra spawns are skipped) for performance.

### 5.8 Health, infection and antidotes
- The player has `PLAYER_HEALTH = 100`, shown as a bar above their head (green → yellow → red). Health never refills by itself.
- Every zombie hit: −`HIT_DAMAGE = 15` and `HIT_INVULN = 1.5` s of blinking protection. The first hit also makes the player `infected` (screen tint).
- While infected (or drinking), health drains at `INFECTION_DRAIN = 2`/s (full bar in 50 s).
- While infected: score multiplier ×2, player still moves.
- **Antidotes:** `ANTIDOTES = 3` per run, shown as vials in the HUD.
- Press Q while infected → `drinking` for `DRINK_TIME = 1` s (cannot move; if hit during drinking, drinking is cancelled but the antidote is not used, and the hit still does damage). Then cured (drain stops) and healed by only `ANTIDOTE_HEAL = 35`, with `CURE_INVULN = 2` s invulnerability (blinking).
- Health hits 0 (from hits or drain) → `turned` → game over sequence (1.5 s transformation, then Game Over screen).
- Q while not infected does nothing (small "not needed" feedback).

### 5.9 Difficulty ramp
- Besides mutation, one extra caged animal gets infected automatically every `AUTO_INFECT_INTERVAL = 45` s if fewer than 3 zombies are alive, so the room never becomes empty and safe.

### 5.10 Research terminals (the scientist's objective)
- `TERMINALS`: 5 terminals against the walls — 2 front-view on the top wall (`terminal-1.png`), 3 side-view on the left/right walls (`terminal-2.png`, mirrored on the right wall). Cages keep clear of them. Player collides with them. The lit terminal pulses with a glow tint.
- Exactly one terminal is lit at a time. Stand within `TERMINAL_RANGE = 50` to upload; progress shows as a bar above the terminal and pauses (does not reset) while away.
- First upload takes `UPLOAD_TIME = 8` s; each completed upload adds `UPLOAD_TIME_STEP = 2` s to the next.
- Completing an upload: +`TERMINAL_ANTIDOTES = 1` antidote (never above `ANTIDOTES`), +`TERMINAL_SCORE` points, then after `TERMINAL_NEXT_DELAY = 3` s a different terminal lights up. Endless.

---

## 6. Scoring

| Event | Points |
|---|---|
| Each second survived | +10 |
| Zombie stunned | +50 |
| Stun chain of length n (n ≥ 2) | +50 × n × n bonus |
| Cascade stopped by gas | +200 |
| Surviving a mutation | +250 |
| Research upload completed | +1000 |
| Unused antidote at game over | +500 each |
| While infected | all points ×2 |

- Show floating score text for each event and a combo label for chains ("CHAIN ×4!").
- Track per run: `score`, `seconds`, `stuns`, `best_chain`, `antidotes_used`, `mutations_survived`, `animals_released`, `uploads`.

---

## 7. Screens and flow

1. **Boot** → loads main menu (and calls `wd.init()`).
2. **Main menu:** Play, How to Play (replays tutorial), Leaderboard (if Wavedash available), Mute toggle.
3. **Intro dialog** (skippable) → **Game** with contextual tutorial on first run of the session.
4. **Pause:** resume, restart, controls, quit to menu.
5. **Game Over:** score breakdown, personal best (session), Wavedash rank + top 10 if available, Retry (R), Menu.

Use collection proxies: `main.collection` (bootstrap, owns proxies) → `menu.collection`, `game.collection`.

---

## 8. Dialog guide (LAB-AI)

Dialog box at the bottom of the screen, speaker name "LAB-AI", text types in, advances on Space/Enter/click, auto-hides 4 s after fully shown if the player ignores it. "Skip tutorial" button. Remember skip for the session.

Lines live in `modules/dialog_data.lua` (text is written by the developer; Claude Code uses these as-is):

**Intro (before play)**
1. "Dr. [Name], containment breach in Lab 7. Subject Zero is loose."
2. "It's infecting everything it touches, and every infected creature spreads it further. It's a chain reaction."
3. "Your job is to survive as long as you can and keep the outbreak under control."

**Contextual tutorial (each shown once, triggered by events)**
| ID | Trigger | Line |
|---|---|---|
| `move` | game start | "Move with WASD. Keep your distance. One touch and you're infected." |
| `tower` | 3 s after start | "Place a stun tower with E. Stun pulses jump between zombies that are close together, so group them up." |
| `gas` | first animal infection happens | "Press G to throw mutation gas. Infection can't spread through it. Break the chain!" |
| `release` | player first within range of a cage | "Press F to release an animal. Zombies will chase it instead of you... but anything they bite, they turn." |
| `mutation` | first mutation warning (5 s left) | "Subject Zero is about to mutate. Every 30 seconds it gets stronger." |
| `antidote` | first time infected | "You're infected! Press Q to drink an antidote. You only have 3." |
| `score` | after first mutation | "Stun chains, survival time, and unused antidotes all add to your score. Good luck, Doctor." |

**Game over (random)**
- "Containment failed. Dr. [Name] has joined the experiment."
- "Out of antidotes. The chain reaction claims another."
- "Lab 7 is lost. Your research will be... continued by someone else."

The tutorial pauses mutation timers while a tutorial line is on screen during the first run only.

---

## 9. Assets (developer-made only)

### 9.1 Rules
- **All** final art, animation, UI graphics, fonts (or a properly licensed font), sound effects, and music are made or legally sourced by the developer. **No AI-generated assets.**
- Claude Code must not create or modify files in `assets/` except `.atlas`, `.font`, `.tilesource`, and `.sound` Defold resource definitions that point to developer files.
- Placeholders: builtin Defold graphics tinted per entity (player = cyan, zombie = green, animal = yellow, cage = grey, tower = blue, gas = purple).
- If an asset file in the manifest is missing, the game must still run using the placeholder.

### 9.2 Asset manifest (developer fills these)

Sprites go into `assets/images/` and are packed into `assets/game.atlas` and `assets/ui.atlas`.

| File | Size (px) | Frames / notes |
|---|---|---|
| `player.png` | 72×72 frames, shown at 48×48 | 8 frames: idle front ×2, idle back ×2, idle side ×2, walk side ×2 (side faces left). Infected/drinking shown as a color wash. |
| `zombie_t0_walk_1..4.png` … `zombie_t4_walk_1..4.png` | 72×72 | one set per tier, or one set + tint |
| `zombie_stunned_1..2.png` | 72×72 | stun effect |
| `rabbit.png`, `rat.png`, `cat.png` (one sheet each) | 16×16 frames, shown at 24×24 | 5 frames, facing left: idle, run ×2, zombie run ×2. An animal type appears in game once its sheet exists. |
| `cage_closed.png`, `cage_open.png`, `cage_broken.png` | 40×40 | |
| `tower.png` | 32×32 frames | 4-frame sheet: idle, pulse ×3 (plays once per stun pulse) |
| `gas-cloud.png` | 180×180 frames | 7-frame sheet: bloom 1–7 once, then 5–7 loop (ping-pong) |
| `terminal-1.png` (front view), `terminal-2.png` (side view, faces right) | 40×40 | research terminal (§5.10); lit state is a code glow |
| `zombie_glow.png` | 144×144 | optional; tier 2+ glow (builtin blob used otherwise) |
| ~~`mutation_burst.png`~~ | — | Dropped: the burst ring uses Defold's builtin blob, tinted |
| `stun-arc.png` | 32×32 | stretched lengthwise between zombies |
| `infection-link.png` | 32×32 | stretched lengthwise between source and target |
| `lab_floor.png` | 1280×720 | background |
| ~~`ui_vial_*`, `ui_gas_icon`, `ui_tower_icon`, `ui_labai_portrait`~~ | — | Not needed: drawn as shapes in GUI code (`modules/ui.lua`) |
| `ui_dialog_box.png` | 9-slice | optional; dialog is a plain dark panel otherwise |
| `cover.png` | 630×500 | itch.io cover |

Audio (`assets/sounds/`, `.ogg`):
`music_loop.ogg`, `sfx_stun.ogg`, `sfx_chain.ogg`, `sfx_gas.ogg`, `sfx_release.ogg`, `sfx_bite.ogg`, `sfx_animal_turn.ogg`, `sfx_mutation_warn.ogg`, `sfx_mutation.ogg`, `sfx_infected.ogg`, `sfx_drink.ogg`, `sfx_gameover.ogg`, `sfx_ui_click.ogg`, `sfx_dialog_blip.ogg`.

Font: `assets/fonts/main.ttf` (developer-chosen, license verified).

---

## 10. Wavedash integration

- Dependency in `game.project`: `https://github.com/wvdsh/sdk-defold/archive/refs/tags/1.2.0.zip`
- All calls go through `modules/wd.lua` (already written; keep its API). `wd.init()` must be called from bootstrap once the game is ready, or the Wavedash loading screen never closes.
- Achievements and stats: import `wavedash_achievements.json` in the Dev Portal. IDs used in code must match exactly:

| ID | Unlock condition (checked in code) |
|---|---|
| `FIRST_STUN` | first zombie stunned (ever) |
| `CHAIN_5` | stun chain length ≥ 5 |
| `GAS_BREAK` | first cascade stopped by gas |
| `BAIT` | a zombie retargets to a released animal |
| `CLOSE_CALL` | antidote finished with less than 15 health left |
| `LAST_VIAL` | survive 60 s after using the 3rd antidote |
| `STEADY_HANDS` | reach 180 s with 0 antidotes used |
| `ANIMAL_RIGHTS` | reach 120 s with 0 animals released |
| `MUTATION_10` | 10 mutations survived in one run |
| `SURVIVE_5MIN` | reach 300 s |
| `STUNS_100` | automatic: stat `TOTAL_STUNS` ≥ 100 (`wd.add_stat("TOTAL_STUNS", 1)` per stun) |
| `RUNS_25` | automatic: stat `RUNS_PLAYED` ≥ 25 (`wd.add_stat("RUNS_PLAYED", 1)` per run) |

- Leaderboards (created manually in Dev Portal, not by code): `high-score` (DESC, numeric) and `longest-survival` (DESC, seconds). Submit once at game over via `wd.submit_run(run, cb)`.
- Deploy: bundle HTML5 to `dist/` (never `build/`), `wavedash.toml` with `game_id` and `upload_dir = "./dist"`, then `wavedash build push`.

---

## 11. Technical structure

```
/game.project
/input/game.input_binding
/main/main.collection            -- bootstrap + collection proxies
/main/main.script                -- wd.init(), proxy switching, audio mute
/menu/menu.collection, menu.gui, menu.gui_script
/game/game.collection
/game/game_manager.script        -- timers, mutation, spawning, score, game over
/game/player.go, player.script
/game/zombie.go, zombie.script   -- spawned via factory
/game/animal.go, animal.script   -- spawned via factory
/game/cage.go, cage.script
/game/tower.go, tower.script     -- factory
/game/gas.go, gas.script         -- factory
/game/fx/                        -- arcs, links, floating text (factories)
/gui/hud.gui, hud.gui_script
/gui/dialog.gui, dialog.gui_script
/gui/gameover.gui, gameover.gui_script
/gui/pause.gui, pause.gui_script
/modules/config.lua              -- every tunable number
/modules/dialog_data.lua
/modules/score.lua               -- scoring rules + run stats
/modules/wd.lua                  -- Wavedash wrapper
/assets/...                      -- developer only
/wavedash.toml
```

- **Physics:** kinematic collision objects. Groups: `player`, `zombie`, `animal`, `cage`, `wall`, `gas`, `tower_range`. Walls around the room edges.
- **Communication:** entities report events to `game_manager` by message (`zombie_bit`, `animal_infected`, `stunned`, `chain`, `cascade_blocked`, …). The manager owns score, timers, and achievement checks.
- **Zombie list:** manager keeps a table of live zombie ids + positions for chain and burst lookups (no per-frame physics queries for chains).
- **Performance target:** 60 fps in Chrome on a mid-range laptop with 30 zombies. HTML5 build under 15 MB.
- **Audio:** everything respects the mute toggle; music starts after first user input (browser autoplay rules).

---

## 12. Milestones (today: Sep 24, 2026)

| # | Dates (IST) | Deliverable | Done when |
|---|---|---|---|
| M1 | Sep 24–25 | Project setup, room, player movement, walls, one zombie chasing, placeholder graphics, config.lua | Player can be chased and "touched" |
| M2 | Sep 26–27 | Cages, animal release, animal fleeing, zombie retargeting, animal infection → new zombie, infection link effect | A cascade can be watched happening |
| M3 | Sep 28 | Stun towers + stun chains with arcs; mutation timer, tiers, bursts | Chains visible; room escalates |
| M4 | Sep 29 | Gas; player infection, antidotes, drinking, game over | Full run is playable start to finish |
| M5 | Sep 30 | Scoring, HUD, floating text, menu, pause, game over screen, retry | Game loop complete |
| M6 | Oct 1 | Dialog system + tutorial triggers; Wavedash wrapper wired (achievements, stats, leaderboards) | First playtest link on Wavedash |
| M7 | Oct 2 | Developer swaps in final assets and audio; juice (screen shake, hit flash); balancing pass | Feels good, no placeholders |
| M8 | Oct 3 | Bug fixing only. HTML5 builds uploaded to itch.io and Wavedash, page text, screenshots, GIF, AI disclosure. **Submit by 23:00 IST.** | Submitted |
| Buffer | Oct 4 | Emergency fixes only (deadline Oct 5, 01:29 IST) | — |

Feature freeze after M6. Anything not done by then is cut, starting from the bottom of the list in §13.

---

## 13. Priority / cut list

Must have: movement, zombies, animals + release, cascades, stun chain, mutation, infection + antidotes, score, game over, HTML5 build.
Should have: gas, dialog tutorial, menu, Wavedash leaderboards and achievements.
Nice to have (cut first, in this order): tier 4 effects, zombie splitting (tier 3), longest-survival leaderboard, auto-infect ramp, animal type variety.

---

## 14. Out of scope

Multiplayer, multiple levels/rooms, mobile touch controls, save files beyond Wavedash stats, story beyond the dialog lines, any AI-generated assets.

---

## 15. Acceptance criteria

- A new player understands goal and controls within 60 s (tutorial on).
- A chain reaction (cascade or stun chain) happens in the first 60 s of a typical run.
- No crash or soft-lock in 20 consecutive runs.
- HTML5 build loads and plays in Chrome and Firefox on itch.io; works identically without Wavedash.
- On Wavedash: loading screen dismisses, score appears on `high-score`, `FIRST_STUN` unlocks on first stun.
- All numbers tunable from `config.lua`; changing one requires no other code change.
- Zero AI-generated image, audio or font files in the repository (the code-drawn UI shapes are disclosed in §1.1).
