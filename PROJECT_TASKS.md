# POWERSTEAL — Project Task Breakdown

**Linked to:** GAME_DESIGN_DOCUMENT.md
**Total Duration:** 28 weeks
**Structure:** Weekly tasks with acceptance criteria and estimated hours

---

## How to Use This Document

Each task has:
- **ID:** Phase.Week.Task (e.g., P1.W1.T1 = Phase 1, Week 1, Task 1)
- **Est. Hours:** Rough time estimate assuming ~25-30 productive hours/week (solo dev, sustainable pace)
- **Acceptance Criteria:** How you know the task is DONE. Not "it works" — specific, testable outcomes.
- **Dependencies:** What must be finished before this task can start.
- **Status:** `[ ]` Not started, `[~]` In progress, `[x]` Done, `[-]` Cut/Skipped

---

## PHASE 1: PROTOTYPE (Weeks 1-4)

**Goal:** Prove the core loop works and feels good with one boss.
**Kill Gate:** If the Boss 1 loop isn't fun by end of Week 4, STOP and iterate. Do not move to Phase 2.

---

### Week 1 — Foundation

**Theme:** Get the player moving and fighting in a room with a controller.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P1.W1.T1 | **Create Godot 4.x project** — Set up project structure matching GDD Section 9 (folders: scenes/, scripts/, assets/, etc.). Configure project settings: 480x270 resolution, pixel-perfect rendering, 60fps target. | 2h | [ ] |
| P1.W1.T2 | **Input mapping** — Define all input actions in Godot Input Map: move (left stick / WASD), aim (right stick / mouse), melee (R1 / LMB), dash (L1 / Space), power1 (R2 / RMB), power2 (L2 / Shift), interact (A / E), pause (Start / Esc). Test with at least one controller. | 3h | [ ] |
| P1.W1.T3 | **Player scene (CharacterBody2D)** — Create player scene with placeholder sprite (32x32 colored rectangle). Implement 8-directional movement with left stick/WASD. Constant speed, no acceleration. | 4h | [ ] |
| P1.W1.T4 | **Twin-stick aiming** — Implement independent aim direction using right stick (controller) and mouse position (keyboard). Visual indicator: a small dot or line showing aim direction. Player sprite does NOT rotate — aim is separate from movement. | 3h | [ ] |
| P1.W1.T5 | **Melee auto-combo** — Implement 3-swing melee combo on R1/LMB mash. Each swing is slightly faster than the last. Brief recovery after 3rd hit (~0.3s). Hitbox appears in aim direction. Placeholder animation (sprite flash or simple frame swap). | 5h | [ ] |
| P1.W1.T6 | **Dash** — Implement dash on L1/Space. Quick movement burst in move direction (or aim direction if not moving). 4-6 invincibility frames. 0.5s cooldown timer (separate from energy). Visual: brief afterimage or trail. | 4h | [ ] |
| P1.W1.T7 | **Test room** — Create a basic tilemap room (16x16 tiles) with walls. Player can move, aim, melee, and dash within the room. No enemies yet — just the space. | 3h | [ ] |
| P1.W1.T8 | **Player state machine** — Implement basic state machine: Idle, Move, Attack, Dash, Dead. Clean transitions between states. Dash cancels Attack. Attack cancels Move. | 4h | [ ] |

**Week 1 Acceptance Criteria:**
- [ ] Player moves in 8 directions with left stick AND WASD
- [ ] Aim direction is independent of movement (right stick AND mouse)
- [ ] Melee combo plays 3 swings on mash, with recovery after 3rd hit
- [ ] Dash moves the player quickly, has visible i-frames, and has a 0.5s cooldown
- [ ] All inputs work on at least one controller model AND keyboard+mouse
- [ ] Player cannot walk through walls in the test room
- [ ] Game runs at 60fps

---

### Week 2 — Combat Systems

**Theme:** Add the first power, the energy system, enemies to hit, and health.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P1.W2.T1 | **Player health system** — 5 hit points. Visual: simple health bar or 5 pips on HUD. Player takes damage on contact with enemy attacks. Brief invincibility after being hit (~0.5s, sprite flashes). Death state triggers room restart. | 4h | [ ] |
| P1.W2.T2 | **Energy system** — Implement energy meter (max 100, passive regen 5/sec). Energy bar in HUD (positioned under health). Bar color-shifts to match last used power color. **Energy bar starts HIDDEN** — will be revealed later when first power is acquired. | 4h | [ ] |
| P1.W2.T3 | **Power base class** — Create `power_base.gd` with virtual methods: `activate()`, `deactivate()`, `update(delta)`, `get_energy_cost()`, `get_power_name()`, `get_power_color()`. PowerManager autoload with slot1/slot2 references. | 3h | [ ] |
| P1.W2.T4 | **Fireball power** — Implement Fireballs inheriting from power base. Press R2/RMB to fire a projectile in aim direction. Costs 20 energy. Fireball travels in straight line, destroys on wall/enemy contact. Placeholder sprite (orange circle). Deals damage to enemies (kills in 1-2 hits). | 5h | [ ] |
| P1.W2.T5 | **Fire patch** — Fireballs leave a small fire patch on impact that lasts 2-3 seconds. Deals burn damage to enemies standing in it (1 damage/second). Placeholder visual (orange glow on ground). | 3h | [ ] |
| P1.W2.T6 | **Basic enemy (Fire Grunt)** — Create enemy scene (CharacterBody2D, 32x32 placeholder). AI: detect player within range → walk toward player → lunge attack at close range. Takes 2-4 melee hits to die. Deals 1 damage on hit. Drops nothing. Leaves small fire patch on death (thematic). | 5h | [ ] |
| P1.W2.T7 | **Hit feedback** — Screen shake on hit (both dealing and receiving). Brief freeze-frame (2-3 frames) on melee contact. Particle burst on enemy death. This is CRITICAL for game feel — spend time tuning. | 4h | [ ] |
| P1.W2.T8 | **Death and room restart** — When player health reaches 0: brief death animation (sprite fades/explodes), 0.5s pause, reload current room scene. Fast — under 1 second from death to playable. Energy carries over on room restart (persisted in GameManager). | 3h | [ ] |

**Week 2 Acceptance Criteria:**
- [ ] Player has 5 visible health points
- [ ] Player takes damage from enemy attacks and flashes briefly (invincibility)
- [ ] Energy bar regenerates visibly at 5/sec (but is hidden until first power — test by temporarily showing it)
- [ ] Fireball fires in aim direction, costs 20 energy, and destroys enemies
- [ ] Fire patches appear on fireball impact and deal burn damage
- [ ] Fire Grunt walks toward player and attacks — dies in 2-4 melee hits
- [ ] Screen shake and freeze-frame on hit feel impactful
- [ ] Room restart after death takes under 1 second

---

### Week 3 — Boss Framework + Boss 1

**Theme:** Build the boss system and create the Hothead encounter.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P1.W3.T1 | **Boss base class** — Create `boss_base.gd` with: health pool, phase thresholds (100-75%, 75-50%, 50-25%, 25-0%), state machine (Idle, Phase1-4, Stunned, Dead), health bar (large bar at top of screen), damage handling. | 5h | [ ] |
| P1.W3.T2 | **Boss 1: Hothead — Phase 1 (100-75%)** — Charges at player in straight lines, leaving fire trails. Throws single fireballs at player (reuse Fireball projectile with enemy flag). Pauses 1-2s after charges (punish window). Placeholder art (orange rectangle, larger than player). | 5h | [ ] |
| P1.W3.T3 | **Boss 1: Hothead — Phase 2 (75-50%)** — Charges become faster (1.5x speed). Throws 3-fireball spread instead of single. Oil patches on floor ignite periodically (timed hazard zones). | 4h | [ ] |
| P1.W3.T4 | **Boss 1: Hothead — Phase 3 (50-25%)** — Adds ground-slam: telegraphed windup (0.5s), expanding fire ring from impact point. Fire ring must be dashed through. Fire trails from charges last longer (5s → 8s). | 4h | [ ] |
| P1.W3.T5 | **Boss 1: Hothead — Phase 4 (25-0%)** — Berserk mode: constant fire aura (contact damage within radius). All attacks faster. Punish windows shortened (1s instead of 2s). Most aggressive phase. | 3h | [ ] |
| P1.W3.T6 | **Boss 1 arena** — Create boss arena tilemap. Open room with scattered flammable barrels (destructible). Oil patches on floor (pre-placed). Walls, entry point, clear boundary. | 3h | [ ] |
| P1.W3.T7 | **Approach rooms (Boss 1)** — Room 1: corridor with fire jets on timed cycles (dash through gaps). Room 2: room with flammable barrels + fire traps + 2-3 Fire Grunt minions. Transition trigger at room exit. | 4h | [ ] |
| P1.W3.T8 | **Room transition system** — Implement scene transitions: approach room 1 → room 2 → boss arena. Brief fade-to-black transition (0.3s). GameManager tracks current room index. Energy persists across transitions. | 3h | [ ] |

**Week 3 Acceptance Criteria:**
- [ ] Boss health bar displays at top of screen, updates on damage
- [ ] Hothead transitions between 4 phases at correct health thresholds
- [ ] Each phase has visibly different behavior (faster, more attacks, new abilities)
- [ ] Fire trails, fire ring, and fire aura all deal damage to the player
- [ ] Punish windows exist in every phase — boss is beatable without taking damage if played perfectly
- [ ] Approach rooms are playable with working traps and minions
- [ ] Room transitions work smoothly with energy carry-over
- [ ] Dying in boss arena restarts boss arena (not approach rooms)
- [ ] Dying in approach room restarts that room only

---

### Week 4 — Ritual, Power Swap, Full Loop

**Theme:** Complete the steal moment and close the gameplay loop.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P1.W4.T1 | **Boss defeat state** — When Hothead reaches 0 HP: boss collapses (placeholder animation), becomes interactable. A prompt appears: "Hold [A/E] to steal power." Boss body stays on screen. | 3h | [ ] |
| P1.W4.T2 | **Ritual animation** — Hold interact button for 2 seconds. Progress indicator (radial fill or bar). During the hold: screen darkens slightly, particles flow from boss to player, power color (orange) intensifies. On completion: flash, power acquired. This is the SIGNATURE MOMENT — prioritize feel over complexity. | 5h | [ ] |
| P1.W4.T3 | **Energy bar reveal** — After first ritual completes, the energy bar fades in on the HUD for the first time. One-time event tracked by GameManager. From this point forward, energy bar is always visible. | 2h | [ ] |
| P1.W4.T4 | **Power swap menu** — After ritual: if both slots are empty, power goes to slot 1 automatically. If one slot is full, power goes to empty slot. If both slots full, show swap menu: "Replace [Power 1 name]" / "Replace [Power 2 name]" / "Discard [New Power name]". Controller-navigable (D-pad/stick to select, A to confirm). | 5h | [ ] |
| P1.W4.T5 | **HUD — power slot indicators** — Show two power slot icons on HUD. Empty slots are gray outlines. Filled slots show power color + icon/name. Active power highlights briefly when used. | 3h | [ ] |
| P1.W4.T6 | **Hub menu** — Simple menu screen: game title, list of available missions (Boss 1, Boss 2 locked, etc.). Select a mission to load its first approach room. "Mission Complete" flag on beaten bosses. Dossier text for each target (short text box, scrollable). | 4h | [ ] |
| P1.W4.T7 | **Full loop integration** — Connect everything: Hub → select Boss 1 → approach room 1 → approach room 2 → boss arena → defeat boss → ritual → power acquired → return to hub → Boss 1 marked complete, Boss 2 unlocked (but not built yet). | 4h | [ ] |
| P1.W4.T8 | **Playtest and tuning** — Play through the full Boss 1 loop 5+ times. Tune: boss damage, boss speed, fire trail duration, punish window length, melee damage, energy regen feel. Write down what works and what doesn't. | 4h | [ ] |

**Week 4 Acceptance Criteria:**
- [ ] Holding interact on defeated boss triggers 2-second ritual with visual feedback
- [ ] Power is acquired and appears in the correct HUD slot
- [ ] Energy bar appears for the first time after ritual
- [ ] If testing with 2 powers: swap menu appears and works with controller
- [ ] Hub menu lists missions, shows dossier text, loads correct scene
- [ ] Full loop: hub → rooms → boss → steal → hub is completable without bugs
- [ ] The ritual moment feels deliberate and satisfying (subjective but critical)
- [ ] Combat feels fast and responsive with clear hit feedback
- [ ] Deaths feel fair — player can identify what they did wrong

---

### MILESTONE GATE 1: PROTOTYPE REVIEW (End of Week 4)

**Critical Questions — Answer Honestly:**

| Question | Pass Condition | Action if Fail |
|---|---|---|
| Does melee combat feel satisfying? | You enjoy mashing R1 and hitting things. Screen shake and freeze-frame land. | Iterate on hit feedback, timing, and damage numbers. Do NOT proceed to Phase 2. |
| Does the dash feel responsive? | Dash input → movement is instant. I-frames feel fair. Cooldown is noticeable but not frustrating. | Adjust cooldown, distance, or i-frame count. |
| Does Fireball feel useful? | Throwing a fireball feels impactful. Cost (20 energy / 4 seconds of regen) feels worth it. | Adjust energy cost or damage. If fireballs feel pointless, the power system has a fundamental problem. |
| Does the energy regen pace work? | You're not constantly energy-starved OR constantly full. There's a natural rhythm to using powers. | Adjust regen rate (try 3/sec or 8/sec). This is the most likely number to change. |
| Is the Boss 1 fight fair and interesting? | You die 3-10 times on first attempt. Each death teaches something. Victory feels earned. Phase transitions are noticeable. | Rebalance boss health, damage, speed, and patterns. |
| Does the ritual steal moment land? | Holding the button over the defeated boss feels deliberate and meaningful. Not just "picking up an item." | Invest more in VFX, sound, screen effect. This moment IS the game. |
| Is the full loop engaging? | After completing Boss 1, you want to play Boss 2. The hub → rooms → boss → steal → hub cycle feels complete. | Identify which phase is weakest and iterate. |

**KILL DECISION:** If 4+ of these questions fail, seriously consider whether the core design works. It's cheaper to redesign now than to build 4 more bosses on a broken foundation.

---

## PHASE 2: CONTENT BUILD (Weeks 5-16)

**Goal:** Build all 5 boss encounters, all approach rooms, all powers, all minions.
**Rule:** Each boss is built on the frameworks established in Phase 1. Reuse patterns aggressively.

---

### Week 5 — Telekinesis Power + Hurler Prep

**Theme:** Build the second power and the approach rooms for Boss 2.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P2.W5.T1 | **Telekinesis power** — Hold R2/RMB to grab nearest object/enemy in aim direction (range ~150px). Grabbed target follows aim direction at a distance. Release to throw in aim direction. Cost: 15 to grab + 5 to throw = 20 total. | 6h | [ ] |
| P2.W5.T2 | **Grabbable objects system** — Tag certain objects as "grabbable" (barrels, crates, debris). When grabbed: object floats, highlighted purple. When thrown: object becomes a projectile, deals damage on impact, destroyed on hit. Enemies are grabbable: stunned while held, take damage when thrown. | 5h | [ ] |
| P2.W5.T3 | **TK projectile deflection** — If TK grab is aimed at an incoming enemy projectile, grab it and hold it. Release to throw it back. Extends the TK system to be defensive. | 3h | [ ] |
| P2.W5.T4 | **TK puzzle objects** — Heavy blocks (movable only with TK, not by player walking). Distant switches (activate by throwing object at them). Test in a prototype puzzle room. | 3h | [ ] |
| P2.W5.T5 | **Object Thrower minion** — Enemy type for Boss 2 zone. Stays at range, picks up nearby objects, lobs them at player in an arc. Harmless once nearby objects are depleted. Dies in 2-3 hits. Purple color accent. | 4h | [ ] |
| P2.W5.T6 | **Boss 2 approach room 1** — Power-gated room: heavy block obstructs path + fire-activated mechanism (player uses Fireballs to light fuse, opening way). Validates player understands Fireballs. 1-2 Object Thrower minions. | 3h | [ ] |
| P2.W5.T7 | **Boss 2 approach room 2** — Reflex corridor: objects fly across screen on set paths (horizontal, diagonal). Player must dash through gaps. 1-2 Object Thrower minions at the end. | 3h | [ ] |

**Week 5 Acceptance Criteria:**
- [ ] TK grab works on objects and enemies in aim direction
- [ ] Thrown objects deal damage and are destroyed on impact
- [ ] TK can deflect enemy projectiles
- [ ] Heavy blocks are movable only with TK
- [ ] Object Thrower minion throws objects and becomes harmless when depleted
- [ ] Both approach rooms are playable with traps and minions

---

### Week 6 — Boss 2: The Hurler

**Theme:** Build the full Hurler boss fight.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P2.W6.T1 | **Boss 2: Hurler — Base setup** — Boss scene with placeholder art (purple rectangle, larger than player). Health pool, phase thresholds. Arena: cluttered room with 20-30 throwable objects (chairs, crates, beams). Track object count for depletion system. | 4h | [ ] |
| P2.W6.T2 | **Hurler — Fireball catching** — When player fires a fireball, if boss is FACING the player (within ~90-degree cone of boss's facing direction), boss catches it and throws it back. If boss is mid-attack or facing away, fireball hits normally. Visual: purple flash on catch. | 5h | [ ] |
| P2.W6.T3 | **Hurler — Phase 1 (100-75%)** — Throws single objects at player. Maintains distance (kites away if player gets close). Catches fireballs when facing player. Slow attack rate. | 3h | [ ] |
| P2.W6.T4 | **Hurler — Phase 2 (75-50%)** — Throws multiple objects simultaneously (2-3 at once). Creates orbiting debris shield (3-4 objects orbit boss, block melee, must be broken with 2-3 hits each). Object supply visibly thinning (fewer objects on the floor). | 5h | [ ] |
| P2.W6.T5 | **Hurler — Phase 3 (50-25%)** — Lifts and throws large objects (placeholder: big squares). Slam attacks create circular shockwave on impact (dash through). Throws are slower due to depleted supply. | 4h | [ ] |
| P2.W6.T6 | **Hurler — Phase 4 (25-0%)** — Lifts the player briefly (~1.5s, player is immobilized, mash A/LMB to escape faster). Scrapes together remaining debris for weaker but frantic volleys. Supply is low, throws are weak but constant. | 5h | [ ] |
| P2.W6.T7 | **Boss 2 full integration** — Connect approach rooms → boss arena. Ritual + power swap (TK acquired). Hub updated: Boss 2 complete, Boss 3 unlocked. Test full Boss 2 sequence 3+ times. Tune damage, speed, object count, depletion rate. | 4h | [ ] |

**Week 6 Acceptance Criteria:**
- [ ] Hurler catches fireballs only when facing player — flanking works
- [ ] Object count visibly decreases during fight — throws get weaker over time
- [ ] Debris shield in Phase 2 is breakable with melee
- [ ] Player lift in Phase 4 has mash-to-escape mechanic
- [ ] Boss is beatable without taking damage if played perfectly
- [ ] Full sequence: approach rooms → boss → steal TK → hub works cleanly
- [ ] TK power is usable immediately after acquisition

---

### Week 7 — Blink Power + Blitzer Prep

**Theme:** Build the third power (most complex mobility tool) and Boss 3 approach rooms.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P2.W7.T1 | **Blink power** — Press R2/RMB to teleport short distance (~100-120px) in aim direction. Costs 25 energy. Player passes through walls, enemies, and obstacles during transit. ~10 frames of invulnerability. Green afterimage at origin, particle dissolve/reform at destination. | 6h | [ ] |
| P2.W7.T2 | **Blink collision handling** — If destination would place player inside a wall, snap to nearest valid position on the near side. If blinking across a gap (no floor), land on the far side. Handle edge cases: blinking into corners, blinking at exact wall boundaries. | 4h | [ ] |
| P2.W7.T3 | **Blink puzzle elements** — Thin barriers (passable with Blink, not with dash). Gaps/chasms (crossable with Blink). Locked doors (bypassable with Blink if there's space on the other side). Test in a prototype puzzle room. | 3h | [ ] |
| P2.W7.T4 | **Phase Dasher minion** — Fast enemy that blinks short distances toward player. Appears at position, attacks once (melee slash), blinks to new position. Predictable 3-position pattern. Green color accent. Dies in 2 hits (fragile but evasive). | 5h | [ ] |
| P2.W7.T5 | **Boss 3 approach room 1** — Power-gated: gap too wide to dash across. Multiple solutions: burn rope with Fireballs to drop bridge, OR move platform with TK, OR (if player has Blink from replay) blink across. 1-2 Phase Dasher minions. | 3h | [ ] |
| P2.W7.T6 | **Boss 3 approach room 2** — Reflex: trap corridor where hazards blink in/out of existence (spikes appear for 1s, disappear for 1s). Timing-based. 1-2 Phase Dasher minions. | 3h | [ ] |
| P2.W7.T7 | **Boss 3 approach room 3** — Mixed puzzle: activate 3 switches in sequence, but each switch randomly teleports the player to a different position in the room. Disorienting. Teaches "being blinked" feeling. | 4h | [ ] |

**Week 7 Acceptance Criteria:**
- [ ] Blink teleports player in aim direction, passing through walls
- [ ] Player cannot get stuck inside walls after Blink
- [ ] Blink crosses gaps and bypasses locked doors
- [ ] Phase Dasher minion blinks in a predictable pattern and is killable
- [ ] All 3 approach rooms are playable with traps, puzzles, and minions
- [ ] Multiple power-based solutions exist for Room 1 (fire OR TK)

---

### Weeks 8-9 — Boss 3: The Blitzer

**Theme:** Build the phase-shifting boss. Extra week for the set-path blink chain system.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P2.W8.T1 | **Boss 3: Blitzer — Base setup** — Boss scene with placeholder art (green rectangle). Arena: multi-platform room with pillars providing cover. Define 5-7 blink positions (waypoints) around the arena. | 4h | [ ] |
| P2.W8.T2 | **Blink telegraph system** — Green particle effect appears at destination 0.5s before boss arrives. Audio cue (subtle whoosh). This telegraph is the player's primary tool for predicting boss location. Must be clear and consistent. | 4h | [ ] |
| P2.W8.T3 | **Blitzer — Phase 1 (100-75%)** — Blinks to a position, attacks once (melee slash in player direction), blinks away. Predictable 3-position rotation (cycles through same 3 waypoints). Learning phase — player recognizes the pattern. 0.5s telegraph. | 4h | [ ] |
| P2.W8.T4 | **Blitzer — Phase 2 (75-50%)** — Rotation expands to 5 positions. Adds ranged attack (thrown knife projectile) immediately after blinking. Faster tempo (less time at each position). 0.5s telegraph maintained. | 4h | [ ] |
| P2.W8.T5 | **Blitzer — Phase 3 (50-25%)** — Blinks behind the player specifically (calculates position opposite player's facing). Telegraph shortens to 0.3s. Adds blink-slash-blink-slash combo (2 rapid attacks from 2 positions). | 5h | [ ] |
| P2.W9.T1 | **Blitzer — Phase 4 (25-0%) — Set-path chain blinks** — Define 2-3 blink paths (sequences of 4-6 waypoints each). Boss rapidly blinks along one path, attacking at each waypoint. Speed: ~2-3 positions per second. After completing a path, 1.5s cooldown (punish window). Boss cycles between paths. | 8h | [ ] |
| P2.W9.T2 | **Blink path visualization** — During Phase 4, briefly show the upcoming path as a faint green dotted line (0.3s before chain starts). Gives the player a split-second to read and position. | 3h | [ ] |
| P2.W9.T3 | **Boss 3 full integration** — Connect approach rooms → boss arena. Ritual + power swap (Blink acquired). Hub updated. Test full sequence 5+ times. Tune telegraph timing, path speed, cooldown windows. The Blitzer should feel HARD but FAIR — every death should be learnable. | 5h | [ ] |

**Weeks 8-9 Acceptance Criteria:**
- [ ] Green telegraphs consistently predict boss arrival position
- [ ] Phase 1-3 blink patterns are learnable — player can predict where boss goes after 2-3 attempts
- [ ] Phase 4 set-path blinks are visually readable (path preview works)
- [ ] 1.5s cooldown between chains is a clear punish window
- [ ] Boss is beatable without taking damage by a skilled player
- [ ] Blink power swap works correctly after ritual
- [ ] Fight feels distinctly different from Boss 1 and 2 — tests prediction, not reaction

---

### Weeks 10-12 — Boss 4: The Warden + Time Freeze

**Theme:** The hardest boss and the most complex power. Three weeks allocated. Do not rush.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P2.W10.T1 | **Time Freeze power** — Press R2/RMB to activate. Duration: 2.5 seconds. Cost: 40 energy. All enemies, projectiles, and environmental hazards freeze. Player moves at full speed. Melee damage x1.5 during freeze. Cannot be activated if energy < 40. | 6h | [ ] |
| P2.W10.T2 | **Time Freeze global flag** — Create a global `time_frozen` boolean in PowerManager. All enemy `_process()` methods check this flag — if true, skip movement/AI/animation. All projectile `_process()` methods check this flag — if true, freeze in place. Environmental hazards (fire jets, traps) also freeze. | 4h | [ ] |
| P2.W10.T3 | **Time Freeze visual effect** — Shader on CanvasLayer: desaturate everything except the player. Player glows white/silver. Frozen elements have a crystalline/static overlay. Subtle clock-tick audio loop during freeze. Duration timer visible on HUD (circular countdown). | 5h | [ ] |
| P2.W10.T4 | **Time Freeze puzzle elements** — Moving platforms freeze in position (can be used as stepping stones). Timed hazards (fire jets, spike traps) stop during freeze. Create 1-2 test puzzles: freeze a moving platform to cross a gap, freeze cycling spikes to walk through. | 3h | [ ] |
| P2.W10.T5 | **Player slow system** — `slow_multiplier` variable in player.gd (default 1.0). When set to 0.5: movement speed halved, attack animation speed halved, dash distance halved (same i-frames). Input response remains instant — only character speed changes. Visual: slow-aura particle effect around player. UI: "SLOWED" text indicator. Audio: low-pitched droning sound. | 6h | [ ] |
| P2.W10.T6 | **Slow Drone minion** — Floating enemy, follows fixed patrol paths. Emits slow-aura zone (~80px radius). Player entering zone gets slow_multiplier set to 0.5. Does not attack directly — the zone IS the threat. Destroyable (2 melee hits). White/silver color accent. | 4h | [ ] |
| P2.W11.T1 | **Boss 4 approach room 1** — Power-gated: time-locked doors (mechanisms activate during brief windows, player must reach them in time). Fire/TK/Blink each offer different solutions. 1-2 Slow Drones. | 4h | [ ] |
| P2.W11.T2 | **Boss 4 approach room 2** — Reflex: corridor where time alternates between normal and slow in waves (every 4 seconds, slow_multiplier toggles). Traps that are easy in normal time become deadly at half speed. 1-2 Slow Drones. | 4h | [ ] |
| P2.W11.T3 | **Boss 4 approach room 3** — Mixed puzzle: objects move at different speeds. A fast-moving platform and a slow-moving platform. Player must time interactions based on the current speed state. Cerebral, less combat-focused. | 4h | [ ] |
| P2.W11.T4 | **Boss 4: Warden — Base setup** — Boss scene with placeholder art (white/silver rectangle). Arena: clean, minimalist room. Few objects. Stark contrast with previous cluttered arenas. | 3h | [ ] |
| P2.W11.T5 | **Warden — Phase 1 (100-75%)** — Periodically applies slow (3-4 seconds duration) to player. During slow: boss attacks normally (melee swipes, short dash attacks). Between slows: boss is passive, walks slowly — punish window. Slow has visual/audio telegraph (0.5s before activation). | 5h | [ ] |
| P2.W12.T1 | **Warden — Phase 2 (75-50%)** — Slow periods extend to 5 seconds. Boss adds slow-moving projectiles during slow periods (easy for boss, hard for slowed player). Boss begins brief self-speed-ups (1-2 second bursts where boss moves at 2x speed, blurred visual). | 5h | [ ] |
| P2.W12.T2 | **Warden — Phase 3 (50-25%)** — Boss places time-distortion zones on the floor (visible shimmering fields, ~100px radius). Stepping in a zone freezes player for 1 second (complete stop). Boss places 2-3 zones strategically to cut off escape routes. Zones last 8-10 seconds then fade. | 5h | [ ] |
| P2.W12.T3 | **Warden — Phase 4 (25-0%)** — Arena splits: half is in slow-time (visible wavering white particle boundary). Player in slow side gets 50% speed reduction. Boss fights from normal-time side. Boundary shifts slowly across the arena. Player must stay in normal-time while boss pushes them toward the slow side. | 6h | [ ] |
| P2.W12.T4 | **Boss 4 full integration** — Connect approach rooms → boss arena. Ritual + power swap (Time Freeze acquired). Hub updated. Extensive playtesting: 5+ full runs. **Critical test: show the time-slow to someone who hasn't played the game. Ask: "Does this feel like a game mechanic or a bug?"** Adjust VFX/UI until the answer is unambiguous. | 5h | [ ] |

**Weeks 10-12 Acceptance Criteria:**
- [ ] Time Freeze stops all enemies, projectiles, and hazards for 2.5 seconds
- [ ] Time Freeze desaturation shader looks distinct and intentional
- [ ] Time Freeze works correctly with puzzles (freezes moving platforms, stops traps)
- [ ] Player slow system: movement and attack speed at 50%, input still instant
- [ ] Slow is visually distinct from lag: aura effect + "SLOWED" indicator + audio
- [ ] Warden phase transitions create escalating difficulty
- [ ] Time-distortion zones in Phase 3 are visible and avoidable
- [ ] Arena split in Phase 4 has a clear visual boundary
- [ ] Fresh-eyes test: someone new recognizes time-slow as a mechanic, not a bug
- [ ] Boss is the hardest fight in the game — victory feels earned

---

### Weeks 13-15 — Boss 5: The Hunter

**Theme:** Final boss with no power reward. Pre-scripted counters, gadgets, EMP zones.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P2.W13.T1 | **EMP zone system** — Area effect (~120px radius) that disables power usage. Player inside zone: powers cannot be activated, energy bar grays out, visual static/interference effect on player. EMP zones can be placed by entities or be static in level design. | 5h | [ ] |
| P2.W13.T2 | **Gadget Sentry minion** — Stationary turret OR patrolling drone. Fires projectiles at player (straight line, moderate speed). Destroyable (3 melee hits). Some variants have small EMP field (~60px radius). Color: neutral gray with red accents. | 4h | [ ] |
| P2.W13.T3 | **Boss 5 approach room 1** — Mixed: Hunter's traps counter specific powers. Fire-resistant barriers redirect fireballs back. Bolted-down objects resist TK. Blink-blocking walls (thick enough that Blink range can't cross). Forces creative problem-solving and melee. 2-3 Gadget Sentries. | 5h | [ ] |
| P2.W13.T4 | **Boss 5 approach room 2** — Narrative: room with environmental storytelling. Files on each previous boss (simple text pop-ups when player walks near). Observations on the player. Light puzzle: decode lock combination from research notes (3-digit code displayed across multiple notes in the room). | 4h | [ ] |
| P2.W13.T5 | **Boss 5 approach room 3** — Reflex gauntlet: EMP zones (disable powers temporarily), trip mines (visible wire, dash through or destroy), automated turrets (Gadget Sentries on walls). Pure skill test. | 4h | [ ] |
| P2.W14.T1 | **Boss 5: Hunter — Base setup** — Boss scene: human-sized (same as player), no superpowers. Industrial arena with deployable cover points, trap zones. Unique health bar color (neutral gray). | 3h | [ ] |
| P2.W14.T2 | **Hunter — Gadget system** — Boss has a gadget inventory: smoke bombs (obscure ~150px radius, 3s duration), flash grenades (stun player 0.5s in ~100px radius, telegraphed), grapple wire (pulls player toward boss from range, dodgeable). Each gadget on its own cooldown. | 6h | [ ] |
| P2.W14.T3 | **Hunter — Pre-scripted power counters** — For each of the 4 powers, define 2-3 specific counter-actions the Hunter performs when the player uses that power. Example: player uses Fireballs → Hunter deploys fire-resistant shield and throws flash grenade; player uses Blink → Hunter drops EMP mine at player's predicted destination. Counters are NOT real-time AI — they are `if player_used_power_X, play_counter_Y` with cooldowns to prevent spam. | 6h | [ ] |
| P2.W14.T4 | **Hunter — Phase 1 (100-75%)** — Uses gadgets: smoke, flash, grapple. Mobile, uses cover. Deploys 1-2 EMP zones to restrict power usage areas. Counter-attacks when player uses powers. | 4h | [ ] |
| P2.W15.T1 | **Hunter — Phase 2 (75-50%)** — Activates arena traps: floor panels (telegraph → damage), wall spikes (on timer). Counters become more aggressive. Forces player to switch between powers and melee. EMP zones expand. | 5h | [ ] |
| P2.W15.T2 | **Hunter — Phase 3 (50-25%)** — Destroys parts of arena walls (opens new area). Aggressive close-range combat: electrified baton combos (2-3 hit chain, telegraphed). Mixes gadgets (smoke → baton attack from inside smoke). EMP zones expand further. | 5h | [ ] |
| P2.W15.T3 | **Hunter — Phase 4 (25-0%)** — Most of arena EMP'd. Gadgets + melee hybrid: flash grenade → grapple pull → baton combo. Smoke bomb → reposition → baton attack from new angle. Every attack is gadget-assisted. Powers barely usable (small non-EMP pockets remain). | 5h | [ ] |
| P2.W15.T4 | **Boss 5 ritual variant — No power reward** — After defeating Hunter: ritual prompt still appears. Player performs ritual but... nothing happens. No power to take. The Hunter had no power. Hold animation plays, but no acquisition flash. Moment of emptiness. Then: fade, return to hub. No Boss 6 unlocked. Game proceeds to ending. | 3h | [ ] |
| P2.W15.T5 | **Ending sequence** — After returning to hub from Boss 5: hub menu shows all bosses complete. No new targets. Brief pause (2-3 seconds). Fade to black. 5-10 seconds of silence (ambient sound only). Credits roll. No input accepted during the pause/fade. | 3h | [ ] |

**Weeks 13-15 Acceptance Criteria:**
- [ ] EMP zones disable powers visually and mechanically
- [ ] Gadget Sentry minions fire projectiles and are destroyable
- [ ] Approach rooms have working power-counter traps and narrative elements
- [ ] Hunter's gadgets (smoke, flash, grapple) work distinctly
- [ ] Pre-scripted counters trigger correctly when player uses specific powers
- [ ] Hunter fight feels different from all other bosses — tactical, human, grounded
- [ ] Phase 4 gadget+melee hybrid keeps combat varied (not just trading melee hits)
- [ ] Empty ritual moment after Hunter defeat is noticeable and intentional
- [ ] Ending sequence plays correctly: silence, fade, credits
- [ ] Full game is completable start to finish (hub → 5 bosses → ending)

---

### Week 16 — Balance Pass + Full Game Testing

**Theme:** The game is content-complete. Now make it fair.

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P2.W16.T1 | **Full playthrough #1** — Play the entire game start to finish. Time each boss sequence. Note every moment of frustration, confusion, or boredom. Write down specific issues. | 3h | [ ] |
| P2.W16.T2 | **Damage tuning** — Adjust all damage values: player melee damage, fireball damage, TK throw damage, boss damage (per phase), minion damage. Goal: player dies in 5 hits from any source. Enemies die in 2-4 melee hits. Bosses take 30-60 seconds of active combat per phase. | 4h | [ ] |
| P2.W16.T3 | **Energy economy tuning** — Play each boss with 5/sec regen and evaluate: Am I using powers enough? Am I energy-starved? Am I always full? Adjust regen rate if needed (try 3, 5, or 8/sec). Adjust individual power costs if specific powers feel too cheap or expensive. | 3h | [ ] |
| P2.W16.T4 | **Boss difficulty curve** — Verify difficulty escalation: Boss 1 < Boss 2 < Boss 3 < Boss 4 < Boss 5. If any boss is easier than the previous, increase their speed/damage/pattern complexity. Death count targets: Boss 1 (3-5 deaths), Boss 2 (4-7), Boss 3 (5-8), Boss 4 (7-12), Boss 5 (5-10). | 3h | [ ] |
| P2.W16.T5 | **Minion placement tuning** — Review every approach room. Are minions contributing to the experience or just in the way? Adjust count, position, and behavior. Remove minions that add nothing. | 2h | [ ] |
| P2.W16.T6 | **Power swap tension check** — Play through with different power swap choices. Does the decision feel meaningful at least twice? Test: keep Fireballs the whole game vs. always take the new power. Both should be viable but different. | 2h | [ ] |
| P2.W16.T7 | **Full playthrough #2** — Play again with all adjustments applied. Note remaining issues. Confirm the game is 2-3 hours total. | 3h | [ ] |
| P2.W16.T8 | **Bug list** — Document all known bugs, glitches, edge cases. Prioritize: game-breaking > frustrating > cosmetic. Fix game-breaking bugs immediately. | 4h | [ ] |

**Week 16 Acceptance Criteria:**
- [ ] Full game is completable in 2-3 hours
- [ ] Difficulty curve is consistent: each boss is harder than the last
- [ ] Energy regen rate feels natural (not starved, not overflowing)
- [ ] Power swap creates genuine decision tension at least twice
- [ ] No game-breaking bugs remain
- [ ] Written list of balance changes made and reasons

---

### MILESTONE GATE 2: CONTENT COMPLETE (End of Week 16)

**The game is playable start to finish with greybox art. Every system works. Before investing in art and audio, confirm:**

| Question | Pass Condition |
|---|---|
| Is the full game fun with placeholder art? | You enjoy playing it despite ugly graphics. The mechanics carry the experience. |
| Does each boss feel distinct? | You can describe each boss's personality in one sentence based purely on gameplay. |
| Is the power swap meaningful? | You genuinely hesitate at least once during a playthrough. |
| Does the ending land? | The silence after Boss 5 feels intentional, not like the game crashed. |
| Are there any design-level problems? | No — only art, audio, and polish issues remain. If there ARE design problems, fix them before Phase 3. |

---

## PHASE 3: POLISH (Weeks 17-24)

**Goal:** Replace all placeholder art, add audio, add VFX, add narrative text. Make the game feel finished.
**Rule:** No new features. No new systems. Polish only.

---

### Weeks 17-19 — Art Production

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P3.W17.T1 | **Player sprite** — 32x32 pixel art. Base appearance (dark, minimal). Idle animation (2-3 frames). Walk animation (4 frames, 4 directions or rotation). | 4h | [ ] |
| P3.W17.T2 | **Player melee animation** — 3-frame combo swing. Visible weapon arc/slash effect. Must feel fast — hold the impact frame briefly. | 3h | [ ] |
| P3.W17.T3 | **Player dash animation** — Afterimage trail (2-3 ghost copies of player sprite, fading). Stretching/blur effect optional. | 2h | [ ] |
| P3.W17.T4 | **Player power visual states** — When a power is equipped, the player has a subtle glow/accent of that power's color. Fireball equipped = faint orange glow. TK = purple. Blink = green. Time Freeze = white. Two accents when two powers equipped. | 3h | [ ] |
| P3.W17.T5 | **Player ritual animation** — 4-5 frames: player kneels, reaches toward boss, energy flows from boss to player (particle stream in power color), flash. Animation escalates per boss: Boss 1 is clean, Boss 4 is violent/intense. | 5h | [ ] |
| P3.W17.T6 | **Player death animation** — Collapse, brief flash, sprite fades. Fast — matches the instant restart loop. | 2h | [ ] |
| P3.W18.T1 | **Boss 1 (Hothead) sprite** — 48x48 or 64x64 (larger than player). Aggressive posture, fire accents (orange). Idle, walk, charge, fireball throw, ground slam, berserk aura animations. | 6h | [ ] |
| P3.W18.T2 | **Boss 2 (Hurler) sprite** — 48x48. Defensive posture, floating debris accent (purple). Idle, throw, shield, lift player animations. | 5h | [ ] |
| P3.W18.T3 | **Boss 3 (Blitzer) sprite** — 48x48. Cocky posture, phase-shift green accent. Must convey personality even at small size. Idle, slash, blink-in, blink-out animations. | 5h | [ ] |
| P3.W18.T4 | **Boss 4 (Warden) sprite** — 48x48. Calm, composed, white/silver accent. Serene — contrast with aggressive bosses. Idle, slow-gesture, speed-up blur, zone-place animations. | 5h | [ ] |
| P3.W18.T5 | **Boss 5 (Hunter) sprite** — 32x32 (same size as player — they're human, no powers). Tactical gear, neutral gray with red accents. Idle, baton swing, gadget throw, grapple animations. | 5h | [ ] |
| P3.W19.T1 | **Minion sprites (5 types)** — 16x16 or 24x24 each. Simple, color-coded. 2-3 frames per animation (idle, move, attack, death). Fire Grunt, Object Thrower, Phase Dasher, Slow Drone, Gadget Sentry. | 6h | [ ] |
| P3.W19.T2 | **Environment tilesets** — 16x16 tiles. 5 tilesets (1 per boss zone): fire/industrial (orange accents), cluttered/warehouse (purple), urban/rooftops (green), clean/lab (white/silver), military/bunker (gray). Each needs: floor, walls, doors, hazard tiles. | 8h | [ ] |
| P3.W19.T3 | **HUD art** — Health bar/pips, energy bar, power slot icons (4 power icons + empty slot), boss health bar, "SLOWED" indicator, ritual progress indicator. Clean, readable, noir style. | 4h | [ ] |
| P3.W19.T4 | **Hub menu art** — Menu background, mission select layout, dossier text styling, boss portrait thumbnails (small, for mission select). Keep it minimal — function over form. | 3h | [ ] |
| P3.W19.T5 | **Power swap menu art** — Clean layout showing 3 options (replace slot 1, replace slot 2, discard). Power icons and colors. Controller prompt icons (A to select, B to cancel). | 2h | [ ] |

**Weeks 17-19 Acceptance Criteria:**
- [ ] All placeholder rectangles replaced with pixel art sprites
- [ ] Player has complete animation set (idle, walk, melee combo, dash, ritual, death, power glow)
- [ ] All 5 bosses have complete animation sets matching their behavior
- [ ] All 5 minion types have basic animations
- [ ] All 5 environment tilesets are complete and tiling correctly
- [ ] HUD, hub menu, and power swap menu use final art
- [ ] Visual consistency: all art uses the same palette, resolution, and style
- [ ] Game still runs at 60fps with all art assets

---

### Weeks 20-21 — VFX Polish

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P3.W20.T1 | **Fireball VFX** — Orange projectile with ember particle trail. Impact burst (orange particles). Fire patch glow on ground (animated flicker). | 3h | [ ] |
| P3.W20.T2 | **Telekinesis VFX** — Purple glow on grabbed target. Purple particle stream from player hand to target. Impact burst on throw. Purple aura during grab. | 3h | [ ] |
| P3.W20.T3 | **Blink VFX** — Green afterimage at origin (fades over 0.3s). Player dissolves into green particles. Reforms at destination with green flash. Brief green screen-edge glow. | 3h | [ ] |
| P3.W20.T4 | **Time Freeze VFX** — Desaturation shader (polish and tune). Player white/silver glow. Crystalline overlay on frozen elements. Clock-tick particle effect (small white particles pulsing). Edge-of-screen white vignette. | 4h | [ ] |
| P3.W20.T5 | **Hit feedback polish** — Tune screen shake (different intensities for melee, fireball, boss hit). Freeze-frame timing. Hit spark particles. Damage number pop-ups (optional — try it, cut if it clutters the screen). | 4h | [ ] |
| P3.W20.T6 | **Melee slash effect** — Visual arc/slash trail on each melee swing. Color: white base, tinted by equipped power color. Brief, impactful. | 2h | [ ] |
| P3.W20.T7 | **Dash trail effect** — Polish the afterimage trail. 3 ghost copies, decreasing opacity, slight stretch. Player's power-color tint on the trail. | 2h | [ ] |
| P3.W21.T1 | **Ritual animation VFX** — Energy stream from boss to player (power-colored particles). Screen darkens around the ritual. Flash on completion. ESCALATION: Boss 1 ritual is clean/clinical. Boss 2 has more particles. Boss 3 has screen shake. Boss 4 has intense distortion/flicker. Boss 5 (empty ritual) has the buildup but NO flash — the particles fizzle out. | 5h | [ ] |
| P3.W21.T2 | **Boss-specific VFX** — Hothead fire aura (Phase 4 berserk), Hurler debris shield orbiting, Blitzer blink telegraphs and path preview, Warden slow-aura zones and arena boundary, Hunter smoke bombs and flash grenades. | 6h | [ ] |
| P3.W21.T3 | **Environmental VFX** — Fire jets (animated flame), EMP zones (static/interference), oil patch ignition, time-distortion shimmer, trap telegraphs (red flash before activation). | 4h | [ ] |
| P3.W21.T4 | **Scene transition effect** — Fade to black / fade from black on room transitions. Brief (0.3-0.5s). Ending sequence: slow fade to black (2-3 seconds). | 2h | [ ] |

**Weeks 20-21 Acceptance Criteria:**
- [ ] All 4 powers have distinct, color-coded VFX
- [ ] Hit feedback feels impactful (screen shake, freeze-frame, particles)
- [ ] Ritual animation escalates visibly from Boss 1 to Boss 5
- [ ] Boss 5 empty ritual is noticeably different (no completion flash)
- [ ] Boss-specific effects are clear and readable during combat
- [ ] No VFX obscures gameplay readability
- [ ] 60fps maintained with all effects active

---

### Weeks 22-23 — Audio + Narrative

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P3.W22.T1 | **Music — Hub menu track** — Dark ambient, minimal, tension. Loop length: 1-2 minutes. Low-key, doesn't overstay its welcome. AI-generated (Suno/Udio) or royalty-free. | 3h | [ ] |
| P3.W22.T2 | **Music — Boss 1 (Hothead)** — Aggressive, driving, fast tempo. Fire-themed (crackling textures?). Builds intensity across phases. | 3h | [ ] |
| P3.W22.T3 | **Music — Boss 2 (Hurler)** — Tense, defensive, building pressure. Objects crashing as rhythm elements? Distinct from Boss 1. | 3h | [ ] |
| P3.W22.T4 | **Music — Boss 3 (Blitzer)** — Unpredictable, shifting tempo, glitchy. Matches the teleporting chaos. Electronic elements. | 3h | [ ] |
| P3.W22.T5 | **Music — Boss 4 (Warden)** — Slow, oppressive, heavy. Time-distortion audio effects (pitch shifting, stretching). Most unsettling track. | 3h | [ ] |
| P3.W22.T6 | **Music — Boss 5 (Hunter)** — Industrial, mechanical, methodical. No supernatural elements — grounded, human threat. The "reality check" track. | 3h | [ ] |
| P3.W22.T7 | **SFX — Player actions** — Melee swing (3 slightly different swoosh sounds for combo variety), dash (whoosh), hit landed (impact thud), damage taken (pain grunt or thud), death (collapse), interact button press. | 3h | [ ] |
| P3.W23.T1 | **SFX — Powers** — Fireball cast (ignition), fireball impact (explosion), fire patch crackle. TK grab (hum), TK throw (whoosh), TK impact. Blink (phase-out whoosh, phase-in pop). Time Freeze (clock stop, ambient silence, clock resume). | 4h | [ ] |
| P3.W23.T2 | **SFX — Bosses** — Each boss needs: attack sound, damage taken, phase transition (health threshold hit — brief roar/flash), death. Plus unique sounds: Hothead fire roar, Hurler debris crash, Blitzer blink pop, Warden time-warp hum, Hunter gadget clicks. | 4h | [ ] |
| P3.W23.T3 | **SFX — Environment** — Fire jet hiss, trap activation click, door open, EMP buzz, oil ignition, switch activated, room transition whoosh. | 3h | [ ] |
| P3.W23.T4 | **SFX — Ritual** — Escalating steal sound: starts as a low hum (Boss 1), adds distortion (Boss 2-3), becomes intense/aggressive (Boss 4). Boss 5 empty ritual: hum builds then abruptly cuts to silence. | 3h | [ ] |
| P3.W23.T5 | **Narrative — Dossiers** — Write 5 target dossiers (see GDD Section 7 examples for tone reference). Boss 1: clinical briefing. Boss 2: slightly personal. Boss 3: hunting language creeps in. Boss 4: obsessive first-person. Boss 5: barely coherent, desperate need. | 3h | [ ] |
| P3.W23.T6 | **Narrative — Environmental details** — Add text pop-ups or visual details to approach rooms: personal belongings of targets, evidence of their lives, signs of the Hunter's surveillance (Boss 5 rooms). 2-3 details per boss zone. Keep it subtle. | 3h | [ ] |
| P3.W23.T7 | **Narrative — Ending silence** — Tune the ending: duration of silence (test 5, 8, 10 seconds — pick what feels right), ambient sound during silence (room tone, distant hum, nothing?), fade speed to credits, credit text content and style. | 2h | [ ] |

**Weeks 22-23 Acceptance Criteria:**
- [ ] 6 music tracks (hub + 5 boss zones) implemented and looping correctly
- [ ] Music intensity matches gameplay tone per boss
- [ ] All player actions have sound effects
- [ ] All 4 powers have distinct audio
- [ ] Boss-specific sounds are implemented
- [ ] Ritual audio escalates from Boss 1 to Boss 5
- [ ] 5 dossiers written with tone escalation from clinical to obsessive
- [ ] Environmental storytelling details present in approach rooms
- [ ] Ending silence duration feels intentional (tested)

---

### Week 24 — Final Testing + Build

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P3.W24.T1 | **Full playthrough #3** — Play the complete game with all art, audio, and VFX. Note any remaining issues. This should feel like a finished game. | 3h | [ ] |
| P3.W24.T2 | **Controller polish** — Test with at least 2 different controller types (Xbox, PlayStation, or generic). Verify all inputs map correctly. Test rumble/vibration if supported (hit feedback, ritual). Fix any dead zones or sensitivity issues. | 3h | [ ] |
| P3.W24.T3 | **Keyboard+mouse polish** — Verify all keyboard bindings work. Mouse aiming feels natural. No conflicts between bindings. | 2h | [ ] |
| P3.W24.T4 | **Bug fix pass** — Address all remaining bugs from the bug list. Priority: game-breaking > gameplay-affecting > visual > audio > cosmetic. | 6h | [ ] |
| P3.W24.T5 | **Performance pass** — Profile the game. Check for frame drops, memory leaks, loading hitches. Optimize particle systems if needed. Confirm 60fps throughout. | 3h | [ ] |
| P3.W24.T6 | **Fresh-eyes playtest** — Have at least 1 person who has NEVER seen the game play it start to finish with a controller. Watch silently. Note: where they get confused, where they get stuck, where they have fun, whether they understand the power swap, whether the ending lands. | 4h | [ ] |
| P3.W24.T7 | **Final adjustments** — Based on fresh-eyes feedback, make final tweaks. This is NOT a redesign — small adjustments only (damage numbers, timing, clarity). | 3h | [ ] |
| P3.W24.T8 | **Build export** — Export Godot project to PC (Windows .exe, Linux, macOS if possible). Test exported builds on at least one machine that isn't your dev machine. | 3h | [ ] |

**Week 24 Acceptance Criteria:**
- [ ] Full game playable start to finish with zero crashes
- [ ] Works on 2+ controller types
- [ ] Works with keyboard+mouse
- [ ] 60fps throughout
- [ ] Fresh-eyes player completed the game and understood the core loop
- [ ] Exported builds run correctly on a non-dev machine

---

### MILESTONE GATE 3: POLISH COMPLETE (End of Week 24)

**Final check against the Definition of Done (GDD Section 15):**

| # | Criterion | Pass? |
|---|---|---|
| 1 | New player completes 5 bosses in 2-3 hours | [ ] |
| 2 | All 4 powers feel distinct and useful | [ ] |
| 3 | Power swap creates tension at least twice | [ ] |
| 4 | Each boss teaches their power through behavior | [ ] |
| 5 | Ritual steal moment feels deliberate and satisfying | [ ] |
| 6 | Deaths feel fair | [ ] |
| 7 | Tone darkens Boss 1 → Boss 5 | [ ] |
| 8 | 60fps, no crashes | [ ] |
| 9 | Controller and keyboard both work | [ ] |
| 10 | Pitch understandable in 30 seconds of watching | [ ] |
| 11 | Energy regen pace feels natural | [ ] |
| 12 | Dash feels responsive and reliable | [ ] |
| 13 | Boss 4 time-slow reads as mechanic, not bug | [ ] |
| 14 | Silent ending lands emotionally | [ ] |

**All 14 must pass. If any fail, address in Week 24 adjustments before moving to Phase 4.**

---

## PHASE 4: SHIP (Weeks 25-28)

**Goal:** Prepare marketing materials and release.

---

### Week 25 — Final Bug Fixes

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P4.W25.T1 | **Address remaining bug list** — Fix any bugs discovered during Phase 3 testing that weren't addressed. Regression test all fixes. | 8h | [ ] |
| P4.W25.T2 | **Edge case testing** — Test unusual scenarios: mash power swap rapidly, die during ritual, pause during boss phase transition, disconnect controller mid-game, alt-tab during Time Freeze. | 4h | [ ] |
| P4.W25.T3 | **Save state (if needed)** — If the game needs save/load (resume from hub after quitting), implement it now. GameManager persists: bosses defeated, current powers, mission progress. If the game is short enough to complete in one sitting, skip this. | 4h | [ ] |
| P4.W25.T4 | **Credits content** — Write credits text: your name, tools used (Godot, Aseprite, etc.), music credits/licenses, special thanks. Keep it short. | 1h | [ ] |

---

### Week 26 — Itch.io Page

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P4.W26.T1 | **Itch.io account setup** — Create or update itch.io developer page. Set up project page for POWERSTEAL. | 1h | [ ] |
| P4.W26.T2 | **Game page copy** — Write the itch.io description. Include: elevator pitch (1 paragraph), key features (bullet list), controls reference, system requirements, screenshots. | 3h | [ ] |
| P4.W26.T3 | **Screenshots** — Capture 5-8 screenshots showing: melee combat, each power in use, a boss fight, the ritual moment, the hub menu, the power swap screen. Focus on moments that communicate the game's identity. | 2h | [ ] |
| P4.W26.T4 | **Cover image + banner** — Create itch.io cover image (630x500) and banner. Use the game's color palette (dark noir + power color accents). Title treatment. | 3h | [ ] |
| P4.W26.T5 | **Upload builds** — Upload Windows, Linux, and macOS builds to itch.io. Set pricing (free for portfolio project). Tag appropriately: action, top-down, boss-rush, pixel-art, dark, controller-support. | 2h | [ ] |

---

### Week 27 — Trailer

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P4.W27.T1 | **Trailer script** — Plan a 45-60 second trailer. Structure: hook (3s of boss fight action), title card, montage (each power shown in 3-5s), ritual steal moment (signature shot), Boss 5 tease (mystery), end card with itch.io link. | 2h | [ ] |
| P4.W27.T2 | **Trailer capture** — Record gameplay footage for each section of the trailer. Play through specific moments for clean captures. No HUD for cinematic shots, HUD for gameplay shots. | 4h | [ ] |
| P4.W27.T3 | **Trailer editing** — Cut the trailer using free tools (DaVinci Resolve, Kdenlive, etc.). Add title cards, music (Boss 1 or 5 track), pacing. Aim for PUNCHY — cut on hits, match music beats. | 6h | [ ] |
| P4.W27.T4 | **Upload trailer** — Upload to YouTube (unlisted or public). Embed on itch.io page. | 1h | [ ] |

---

### Week 28 — Release

| ID | Task | Est. Hours | Status |
|---|---|---|---|
| P4.W28.T1 | **Final build verification** — Download builds from itch.io and test them. Verify they work on a clean system. Check file sizes are reasonable. | 2h | [ ] |
| P4.W28.T2 | **Release** — Set itch.io page to public. Publish. | 0.5h | [ ] |
| P4.W28.T3 | **Announce** — Share on relevant communities: Reddit (r/gamedev, r/indiegaming, r/godot), Twitter/X, Discord servers (Godot, indie dev). Include trailer link and itch.io link. | 2h | [ ] |
| P4.W28.T4 | **Portfolio page** — Add POWERSTEAL to your portfolio/website. Include: description, trailer embed, link to play, and a brief postmortem paragraph (what you learned). | 2h | [ ] |
| P4.W28.T5 | **Retrospective** — Write a personal retrospective (just for you): what went well, what was harder than expected, what you'd do differently, what you want to build next. This is the most valuable document you'll produce. | 2h | [ ] |

---

## TOTAL HOURS ESTIMATE

| Phase | Weeks | Est. Hours |
|---|---|---|
| Phase 1: Prototype | 1-4 | ~120h |
| Phase 2: Content Build | 5-16 | ~280h |
| Phase 3: Polish | 17-24 | ~200h |
| Phase 4: Ship | 25-28 | ~50h |
| **TOTAL** | **28 weeks** | **~650h** |

At ~25 productive hours/week (sustainable solo pace with 1 day off), this is **26 working weeks** — fits within the 28-week schedule with 2 weeks of buffer.

**If you're behind schedule:** Cut Phase 4 to 2 weeks (skip trailer, simplify itch.io page). Cut minion variety (use one enemy type with color swaps). Reduce approach rooms from 2-3 to 1-2 per boss. These are the safest cuts.

**If you're ahead of schedule:** Add power synergies (post-launch feature pulled forward). Add a walkable hub. Add a speedrun timer. Do NOT add more bosses — that's a sequel.

---

*Print this document. Check off tasks as you complete them. Update weekly. If a week's tasks take significantly longer than estimated, re-evaluate the schedule before it cascades.*
