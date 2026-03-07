# POWERSTEAL — Game Design Document

**Version:** 1.0
**Date:** March 6, 2026
**Author:** Solo Developer
**Status:** Pre-Production

---

## 1. Executive Summary

### Elevator Pitch

*You are the villain. Hunt down people with superpowers, kill them, steal their abilities. Keep only two. Become something inhuman.*

**POWERSTEAL** is a top-down, fast-paced 2D action game inspired by the predatory power-theft of Sylar from *Heroes*, the speed and lethality of *Hotline Miami*, and the boss-driven progression of *Mega Man*. The player is a villain protagonist who hunts superpowered targets across a linear sequence of multi-room encounters, ritually stealing each boss's ability after defeating them — but can only hold two powers at a time, forcing constant trade-off decisions.

### Key Differentiators

- **Villain fantasy done right.** You're not an anti-hero. You're a predator. The game doesn't apologize for it.
- **Fight the power before you own it.** Every boss teaches you what their ability does by using it against you. When you steal it, you already understand it.
- **Forced scarcity.** Two power slots means every acquisition is a sacrifice. What you give up matters as much as what you gain.
- **Ritual theft.** Power acquisition is a deliberate, manual act — not a passive pickup. It's the game's signature moment.

### Project Parameters

| Parameter | Value |
|---|---|
| Genre | Top-down 2D action |
| Engine | Godot 4.x |
| Platform | PC (controller-first, keyboard supported) |
| Timeline | 28 weeks (~7 months) |
| Team | Solo developer |
| Art Style | Pixel art, noir palette, power-coded color accents |
| Target Length | 2-3 hours |
| Boss Count | 5 (4 power-granting + 1 final) |
| Project Goal | Portfolio / learning project |

---

## 2. Game Pillars

These are the non-negotiable principles every design decision must support:

1. **Predator Fantasy.** The player must always feel like the hunter, not the hero. Tone, narrative, mechanics, and visuals must reinforce this.
2. **Meaningful Choice.** The two-power limit exists to create decisions that matter. Never undermine this with workarounds.
3. **Fast and Lethal.** Combat is twitchy, deaths are frequent, retries are instant. Respect the player's time, punish their mistakes.
4. **Boss-Centric.** Bosses are the game. Everything else exists to serve the boss encounters.

---

## 3. Core Gameplay Loop

```
[HUB MENU] → Select next target
      ↓
[APPROACH] → 2-3 rooms of traps, puzzles, thematic minions, and environmental challenges
      ↓
[BOSS FIGHT] → Multi-phase encounter in a dedicated arena (single room, escalating phases)
      ↓
[RITUAL] → Manual power theft (hold button on defeated boss)
      ↓
[POWER SWAP] → Choose to replace one of your two powers or discard the new one
      ↓
[RETURN TO HUB] → Next target unlocked
```

### Loop Timing Targets

| Phase | Target Duration |
|---|---|
| Approach (per boss) | 5-8 minutes |
| Boss fight (including deaths) | 8-15 minutes |
| Ritual + swap | 1-2 minutes |
| Hub interaction | < 1 minute |
| **Total per boss cycle** | **~15-25 minutes** |
| **Full game** | **~2-3 hours** |

---

## 4. Player Character

### Identity

The protagonist is unnamed (or player-named). They are not sympathetic. They discovered they can absorb the abilities of others through a specific ritual act, and this discovery has become an obsession. Each kill feeds the compulsion. By the end, the player should question whether the character (and by extension, themselves) has gone too far.

**Narrative Arc: Descent into Obsession.** The game begins with clinical purpose and ends with compulsion. Early targets are framed as threats or bad people. Later targets are increasingly sympathetic. The final boss — a hunter of hunters — forces the player to confront what they've become.

### Base Moveset (No Powers Required)

| Action | Input (Controller) | Description |
|---|---|---|
| Move | Left Stick | 8-directional movement, constant speed |
| Aim | Right Stick | Independent aim direction (twin-stick) |
| Melee Attack | R1 / RB | Auto-combo (3 swings on mash), short range, fast recovery |
| Dash | L1 / LB | Quick invincibility-frame dodge, 0.5s cooldown (no energy cost) |
| Power 1 | R2 / RT | Activate equipped power (slot 1) |
| Power 2 | L2 / LT | Activate equipped power (slot 2) |
| Interact / Ritual | Face Button (A/X) | Context-sensitive: interact with objects, perform ritual on defeated boss |
| Pause / Menu | Start | Pause, power info, settings |

### Combat Feel Targets

- **Speed:** Comparable to Hotline Miami / Hyper Light Drifter. Fast movement, instant attack startup.
- **Lethality:** Player dies in **5 hits**. Enough room to learn patterns, punishing enough that every hit matters. Enemies die in 2-4 melee hits.
- **Dodge:** Dash has ~4-6 invincibility frames. **Separate 0.5s cooldown** (not tied to energy meter). Always available. ~2 dashes per second maximum. Reliable defensive tool that doesn't compete with power usage.
- **Healing:** **None.** No health recovery during a boss sequence (approach rooms + boss fight). Full health restored only on room restart after death. Maximum tension — every hit is permanent.
- **Hit feedback:** Screen shake, brief freeze-frame on hit (2-3 frames), particle burst. Every hit must feel impactful.
- **Melee:** Auto-combo. Mash R1/RB for a 3-swing sequence. No timing windows. Simple, responsive, approachable. Each swing in the combo is slightly faster than the last, with a brief recovery after the 3rd hit.

---

## 5. Power System

### Core Rules

1. The player has **two power slots**. Initially both are empty.
2. Powers are acquired by performing a **manual ritual** on a defeated boss (hold interact button for ~2 seconds, unique animation plays).
3. When acquiring a new power with both slots full, a **swap menu** appears:
   - Replace Power Slot 1
   - Replace Power Slot 2
   - Discard new power
4. Discarded powers are **gone permanently** in that playthrough.
5. Powers consume **Energy**, which is a meter filled by dealing melee damage and successfully dodging attacks. This rewards aggressive, skilled play and fits the predator fantasy.

### Energy Meter

- **Maximum:** 100 units
- **Regeneration:** Passive time-based, **5 energy per second** (full bar in 20 seconds)
- **No active gain:** Energy does not increase from melee hits or dodges. Regen is constant and automatic.
- **Carry-over:** Energy carries over between rooms within a boss sequence. Good play in approach rooms fuels a stronger boss opener.
- **Starting value (first room of sequence):** 0 (builds via regen during gameplay)
- **Visual:** Bar under health, color-shifts to match most recently used power
- **Design note:** Dash is on a separate 0.5s cooldown and does NOT consume energy. Only powers use energy. This keeps dodge always accessible while powers require timing and resource awareness.

### Power Roster

#### Power 1: Fireballs (Orange) — Boss 1 Reward

| Property | Value |
|---|---|
| Type | Ranged offense |
| Input | Press trigger to fire a projectile in aim direction |
| Damage | High (kills most enemies in 1-2 hits) |
| Energy Cost | 20 per fireball |
| Special | Fireballs leave a small fire patch on impact (2-3s), dealing burn damage to enemies standing in it |
| Puzzle Use | Burn flammable obstacles, light torches/fuses, melt ice barriers |
| Visual | Orange projectile with ember trail, orange flash on impact, fire patch glows |

#### Power 2: Telekinesis (Purple) — Boss 2 Reward

| Property | Value |
|---|---|
| Type | Control / defense |
| Input | Hold trigger to grab nearest object/enemy in aim direction; release to throw |
| Damage | Variable (depends on what's thrown — enemies take impact damage, objects deal set damage) |
| Energy Cost | 15 to grab, +5 to throw (20 total) |
| Special | Can grab environmental objects (barrels, debris, switches). Grabbed enemies are stunned. Can deflect projectiles. |
| Puzzle Use | Move heavy blocks, activate distant switches, bridge gaps with objects |
| Visual | Purple glow on grabbed target, purple particle stream from hand to object, impact burst |

#### Power 3: Blink / Phase Shift (Green) — Boss 3 Reward

| Property | Value |
|---|---|
| Type | Mobility |
| Input | Press trigger to teleport short distance in aim direction |
| Damage | None (pure utility) |
| Energy Cost | 25 per blink |
| Special | Passes through walls, enemies, and obstacles. Brief invulnerability during transit (~10 frames). Can cross gaps. |
| Puzzle Use | Phase through barriers, cross chasms, reach isolated platforms, bypass locked doors |
| Visual | Green afterimage at origin, character dissolves into particles and reforms at destination, green flash |

#### Power 4: Time Freeze (White/Silver) — Boss 4 Reward

| Property | Value |
|---|---|
| Type | Utility |
| Input | Press trigger to activate. Duration: 2.5 seconds. |
| Damage | None (indirect — allows free melee hits on frozen enemies) |
| Energy Cost | 40 (most expensive power — high reward demands high cost) |
| Special | All enemies and projectiles freeze. Player moves at full speed. Melee damage during freeze is multiplied x1.5. Environmental hazards also freeze. |
| Puzzle Use | Freeze moving platforms in position, stop timed hazards, create windows to pass through cycling obstacles |
| Visual | Screen desaturates except player (who glows white/silver). Frozen elements have a crystalline overlay. Subtle clock-tick sound. |

### Power Balance Philosophy

- Each power must be useful in combat AND puzzles.
- No power should be strictly better than another — they serve different roles.
- The energy cost balances power impact: Time Freeze is the strongest effect but costs the most, forcing careful meter management.
- Players should feel tension when swapping powers. "I love Telekinesis but I need Blink for traversal" is the ideal dilemma.

### Power Combination Matrix

Powers are **independent** (no synergy combos). This is a deliberate scope decision. Each power works the same regardless of what's in the other slot. This cuts design/testing work roughly in half and avoids combinatorial balance nightmares.

Future consideration (post-launch): Add 1-2 subtle synergies as a reward for mastery players, but this is not in scope for the initial build.

---

## 6. Boss Design

### Design Principles

1. **Every boss uses their power against the player.** This is a tutorial and a threat simultaneously.
2. **Multi-room chase structure.** 2-3 connected rooms before the boss arena. Room 1-2 contain traps/puzzles themed around the boss's power. Room 3 (or final room) is the boss arena.
3. **Escalating difficulty within each fight.** Bosses gain new attack patterns at 75%, 50%, and 25% health.
4. **Death = restart current room.** No penalty. Fast retry loop. Player should die 3-10 times per boss on first attempt.
5. **Thematic minions.** Each boss zone has 1-2 simple enemy types that reflect the boss's power theme. Minions appear in approach rooms to provide light combat and preview the boss's abilities. They die in 2-4 melee hits and deal 1 hit of damage on contact/attack.

### Minion Roster

| Boss Zone | Minion Type | Behavior | Purpose |
|---|---|---|---|
| Hothead (Fire) | Fire Grunt | Walks toward player, lunges with a flaming punch. Leaves small fire patch on death. | Teaches fire hazard awareness. Builds energy before boss. |
| Hurler (TK) | Object Thrower | Stays at range, picks up nearby objects and lobs them at player. Harmless once environment is cleared. | Previews telekinetic attacks. Teaches dodging projectiles. |
| Blitzer (Blink) | Phase Dasher | Fast enemy that blinks short distances toward the player. Attacks once, then blinks away. | Previews unpredictable repositioning. Forces reaction speed. |
| Warden (Time) | Slow Drone | Floats in fixed patrol paths. Emits a slow-aura zone around itself. Does not attack directly — the slow zone IS the threat. | Previews time-slow mechanic. Teaches zone avoidance. |
| Hunter (None) | Gadget Sentry | Stationary turret or patrolling drone that fires projectiles. Can be destroyed. Some have EMP fields that disable powers in a small radius. | Previews technology-based threats. Teaches EMP zone awareness. |

**Minion Design Rules:**
- Maximum 3-4 minions per room. Approach rooms are tight, not arenas.
- Minions do NOT appear in boss arenas (bosses fight alone).
- All minions share a base AI template — walk/patrol, detect player, attack. Variations are in attack type and movement speed only.
- Minions are color-coded to match their boss's power color for visual consistency.

---

### Boss 1: THE HOTHEAD — Fireballs (Orange)

**Target Profile:** An aggressive, impulsive berserker who weaponizes fire through sheer fury. Hot-tempered, reckless, dangerous. The "easiest" target — chosen first because they're sloppy.

**Why First:** Player has NO powers. This fight teaches core mechanics: melee range, dash timing, pattern reading. The boss's aggression punishes passivity and rewards the player for being bold.

**UI Note:** The energy bar is **hidden** during Boss 1. The player has no powers to spend energy on, so showing an unusable resource would confuse new players. The energy bar appears for the first time after acquiring Fireballs.

**Approach Rooms (2 rooms):**
- **Room 1 (Reflex):** Corridor with fire jets on timed cycles. Player must dash through gaps. Teaches dash timing.
- **Room 2 (Mixed):** Room with breakable flammable barrels and fire traps. Environmental hazard awareness. Optional: lure a patrolling minion into a fire trap.

**Boss Arena:** Open room with scattered flammable barrels. Floor has oil patches that can ignite.

**Boss Behavior:**
| Health Phase | Behavior |
|---|---|
| 100-75% | Charges at player in straight lines, leaving fire trails. Throws single fireballs. Pauses after charges (punish window). |
| 75-50% | Charges become faster. Throws 3-fireball spread. Oil patches ignite periodically. |
| 50-25% | Adds a ground-slam that creates expanding fire ring (must be jumped/dashed through). Fire trails last longer. |
| 25-0% | Berserk mode. Constant fire aura deals contact damage. Faster everything. Shorter punish windows. |

**Design Intent:** Straightforward, aggressive, teaches fundamentals. Player should feel powerful after winning — "I beat this with nothing but a melee attack and a dash."

---

### Boss 2: THE HURLER — Telekinesis (Purple)

**Target Profile:** A defensive, calculating individual who keeps distance and uses the environment as a weapon. Never gets their hands dirty directly. Throws everything — furniture, debris, other people — at threats.

**Why Second:** Player now has Fireballs (ranged attack). This boss is designed to **counter ranged play**: they can catch projectiles with telekinesis **when facing the player**, forcing the player to flank or time shots during attack animations — rewarding positioning over spam.

**Approach Rooms (2 rooms):**
- **Room 1 (Power-gated):** Room with a heavy block obstructing the path and a fire-activated mechanism. Player uses Fireballs to light a fuse, opening the way. Validates that the player understands their new power.
- **Room 2 (Reflex):** Corridor with objects flying across the screen on set paths (telekinetically controlled). Dodge-focused.

**Boss Arena:** Cluttered room full of throwable objects — chairs, crates, metal beams. As the fight progresses, the boss's supply of objects **reduces but never fully empties** — throws become slower and weaker as supply dwindles, creating escalating windows of opportunity without removing the boss's core mechanic entirely.

**Boss Behavior:**
| Health Phase | Behavior |
|---|---|
| 100-75% | Throws single objects at player. Maintains distance. Catches fireballs **when facing the player** — flanking or timing shots during the boss's throw animation bypasses this. |
| 75-50% | Throws multiple objects simultaneously. Creates a shield of orbiting debris (must be broken through with melee). Object supply visibly thinning. |
| 50-25% | Lifts and throws large objects (pillars, half the floor). Slam attacks create shockwaves. Throws are slower due to depleted supply. |
| 25-0% | Desperate — lifts the player briefly (QTE/mash to escape), scrapes together remaining debris for weaker but frantic volleys. Supply is low, throws are weak but constant. |

**Design Intent:** Teaches the player that powers can be countered **conditionally** — not "fireballs don't work" but "fireballs work if you're smart about positioning." The depleting-but-never-empty supply creates a fight that gets progressively easier without removing the boss's identity.

---

### Boss 3: THE BLITZER — Blink / Phase Shift (Green)

**Target Profile:** An elusive, unpredictable fighter who never stays in one place. Blinks constantly — mid-sentence, mid-attack, mid-dodge. You can never pin them down. Cocky, taunting, treats the fight like a game.

**Why Third:** Player has two powers (likely Fireballs + Telekinesis). Both require a visible, reachable target. This boss is designed to **deny targeting**: constant teleportation, brief visibility windows, forced prediction. The player must read patterns, not react.

**Approach Rooms (3 rooms):**
- **Room 1 (Power-gated):** Room with a gap too wide to dash across. If the player has Fireballs, they can burn a rope to drop a bridge. If they have Telekinesis, they can move a platform. Multiple solutions based on loadout.
- **Room 2 (Reflex):** Trap corridor where hazards blink in and out of existence (thematic preview of the boss). Timing-based.
- **Room 3 (Mixed):** Small puzzle — activate switches in sequence, but each switch teleports you to a random position in the room. Disorienting, teaches the feeling of being blinked.

**Boss Arena:** Multi-platform room with pillars providing partial cover. Boss blinks between set positions (telegraphed by green particles appearing at destination ~0.5s before arrival).

**Boss Behavior:**
| Health Phase | Behavior |
|---|---|
| 100-75% | Blinks to a position, attacks once (melee slash), blinks away. Predictable 3-position rotation. Learning phase. |
| 75-50% | Rotation expands to 5 positions. Adds ranged attack (thrown knife) immediately after blinking. Faster tempo. |
| 50-25% | Blinks behind the player specifically. Telegraph window shortens to ~0.3s. Adds combo attacks (blink-slash-blink-slash). |
| 25-0% | Rapid chain blinks along a **set path** through the arena (not random). Player must read the route and intercept. Boss follows 2-3 repeating path patterns, attacking at each waypoint. Punish window: brief cooldown (~1.5s) between chain sequences. Pattern-based, not reaction-based. |

**Design Intent:** Pattern recognition boss. Requires patience and prediction, contrasting with the twitchy aggression of earlier fights. The telegraph system (green particles at destination) is critical — this boss is hard but fair. The final phase's set-path chain blinks reward players who study the pattern rather than reacting frame-by-frame.

---

### Boss 4: THE WARDEN — Time Freeze (White/Silver)

**Target Profile:** A composed, almost serene individual who controls time. Doesn't rush. Doesn't need to. Slows the player down, literally. Fighting them feels like wading through honey while they move normally. The most powerful target and the most unsettling.

**Why Fourth:** This is the skill wall. The player has three powers to choose from (holding two). They'll need every tool they've mastered. The time-slow mechanic **invalidates fast/twitchy play** — the player's core strength — forcing total adaptation.

**Time-Slow Implementation:** The boss reduces the player's **movement speed and attack speed by 50%**. Controls still respond instantly — the character simply moves and attacks slower. This is visually distinct from lag/bugs because: (a) a visible slow-time VFX aura surrounds the player, (b) the boss continues moving at normal speed, creating obvious contrast, (c) the UI shows a "SLOWED" indicator. The player's dash is also slowed (shorter distance, same i-frames).

**Approach Rooms (3 rooms):**
- **Room 1 (Power-gated):** Room with time-locked doors — mechanisms that only activate during brief windows. Tests precision timing. Fire/TK/Blink all offer different solutions.
- **Room 2 (Reflex):** Corridor where time alternates between normal and slow in waves. Traps that are easy in normal time become deadly in slow-time. Teaches the feel of being time-slowed.
- **Room 3 (Mixed):** Puzzle room where objects move at different time speeds. Player must sequence interactions based on timing. Cerebral, preparation for the boss.

**Boss Arena:** Clean, minimalist room (contrast with previous cluttered arenas). Few environmental objects. This fight is about the player vs. the boss's power. No distractions.

**Boss Behavior:**
| Health Phase | Behavior |
|---|---|
| 100-75% | Periodically slows the player (3-4 seconds) — 50% movement/attack speed reduction with visible slow-aura VFX. During slow periods, boss attacks normally. Player must dodge with reduced speed. Between slows, boss is passive — punish window. |
| 75-50% | Slow periods last longer (5s). Boss adds projectile attacks during slow (slow-moving for them, but the player struggles to dodge at half speed). Boss begins brief self-speed-ups (blurred fast attacks). |
| 50-25% | Boss can freeze specific zones of the arena (visible as shimmering time-distortion fields). Stepping in a frozen zone stops the player entirely for 1s. Boss places them strategically to cut off escape routes. |
| 25-0% | Full arena time distortion. Half the room is in slow-time, half is normal — boundary is visible as a wavering line of white particles. Boss fights from the normal-time side. Player must stay in normal time while the boss tries to force them into slow zones. |

**Design Intent:** The hardest boss. Deliberately frustrating — the player's mastered speed and aggression, and this boss takes it away. Victory requires patience, zone control, and power mastery. The reward (Time Freeze) is the most powerful ability, justifying the difficulty.

---

### Boss 5: THE HUNTER — Final Boss (No Power Reward)

**Target Profile:** A skilled, resourceful human with no superpowers. They hunt people who steal powers — people like the player. They've studied every target the player has killed. They know what you can do, and they've prepared for all of it. They are the consequence.

**Why Final:** This boss doesn't grant a power because they are the narrative mirror. They represent what happens when someone comes to stop the obsession. The fight is a test of everything the player has learned. The emotional question: *was it worth becoming this?*

**Approach Rooms (3 rooms):**
- **Room 1 (Mixed):** The Hunter has laid traps specifically designed to counter the player's known powers. If you use Fireballs, fire-resistant barriers redirect them back. If you use TK, objects are bolted down. Forces creative problem-solving.
- **Room 2 (Narrative):** A room with evidence of the Hunter's research — files on each previous boss, observations on the player's behavior. Worldbuilding through environment. Light puzzle (decode a lock combination from the research notes).
- **Room 3 (Reflex):** Gauntlet of technology-based traps (EMP zones that disable powers temporarily, trip mines, automated turrets). The Hunter's preparation is terrifying because it's *mundane* — no powers, just competence.

**Boss Arena:** Industrial/utilitarian space. The Hunter has prepared the arena with power-nullifying zones, traps, and gadgets.

**Boss Behavior:**
| Health Phase | Behavior |
|---|---|
| 100-75% | Uses gadgets: smoke bombs (obscure vision), flash grenades (stun), grapple wire (pulls player). Mobile, tactical, uses cover. Has EMP devices that create zones where powers don't work. |
| 75-50% | Deploys pre-scripted counters based on the player's equipped powers (not real-time AI — 2-3 hardcoded counter-strategies per power). Forces power switching and melee. Traps activate in the arena (floor panels, wall spikes). |
| 50-25% | Destroys parts of the arena, opening new areas. Becomes more aggressive — close-range combat with an electrified baton. EMP zones expand. Mixes gadgets (smoke bombs, flash grenades) with melee combos. |
| 25-0% | Final stand. Most of the arena is EMP'd — powers barely work. **Gadgets + melee hybrid:** Hunter uses flash grenades to create openings, grapple wire to pull player in, electrified baton combos, and smoke bombs to reposition. Not a pure melee duel — the Hunter fights dirty with every tool available. |

**Design Intent:** The final fight strips away what the player has been chasing the entire game — power — and asks if they can win without it. The Hunter is the moral counterpoint: someone who is dangerous through discipline, not theft. Narratively, this is the climax of the "descent into obsession" arc. Mechanically, the gadget+melee hybrid final phase keeps the fight varied and engaging even when powers are disabled — the Hunter is never just "stand and trade melee hits."

---

## 7. Narrative Design

### Story Structure

The story is minimal and environmental. No lengthy cutscenes. Tone shifts gradually through:

| Boss # | Tone | Player Feeling |
|---|---|---|
| 1 — Hothead | Justified. Target is aggressive, dangerous. World is better without them. | "This is necessary." |
| 2 — Hurler | Ambiguous. Target is defensive, afraid. They were hiding. | "They weren't hurting anyone..." |
| 3 — Blitzer | Uneasy. Target is playful, treats you like a game. Are you the monster? | "Am I enjoying this too much?" |
| 4 — Warden | Dark. Target is calm, philosophical. Questions your motives directly. Accepts death. | "What am I becoming?" |
| 5 — Hunter | Confrontation. This person exists because of what you've done. You ARE the threat. | "Am I the final boss of someone else's story?" |

### Storytelling Methods

- **Pre-mission briefings** in the hub menu: short text/dossier on the target. Tone shifts from clinical to obsessive.
- **Environmental storytelling** in approach rooms: the target's life, belongings, evidence of who they were.
- **Boss behavior:** early bosses fight aggressively (villainous). Later bosses fight defensively or reluctantly (sympathetic).
- **Post-kill ritual:** the animation becomes more intense/disturbing as the game progresses. Same action, escalating tone.
- **Ending:** After defeating the Hunter, the player character stands motionless over the body. No input is accepted. 5-10 seconds of silence — just the ambient sound of the arena. Then slow fade to black. Credits. No fanfare, no victory screen, no score. The silence is the statement.

### Example Dossiers (Tone Reference)

**Boss 1 — The Hothead (Clinical tone):**

> **TARGET: DESIGNATION "HOTHEAD"**
> Location: Industrial district, warehouse 14B.
> Ability: Pyrokinesis. Generates and projects fire through physical contact and directed bursts.
> Threat assessment: Moderate. Aggressive, poor impulse control. Known to cause collateral damage. Multiple arson incidents attributed.
> Approach: Direct engagement recommended. Target is reckless — exploit openings after committed attacks.
> Note: First acquisition. Proceed with caution.

**Boss 4 — The Warden (Obsessive tone):**

> I can feel the gap. Two powers and it's not enough. It's never enough. There's someone who can SLOW TIME. Think about that. Think about what that means — what I could do with that. What I could become.
> They call themselves the Warden. They think they're above it. Above me. Sitting in that clean little room, untouchable, looking down at everyone who has to live in real time.
> They won't slow me down. I've taken fire. I've taken minds. I've taken speed itself. Time is next.
> Time is MINE.

*Note the shift: Boss 1 dossier reads like a professional briefing — detached, formatted, analytical. Boss 4 dossier is first-person, fragmented, hungry. The protagonist's voice has taken over the mission files. Bosses 2 and 3 should fall on the gradient between these two extremes.*

---

## 8. Art Direction

### Visual Identity

**Base palette:** Dark, desaturated backgrounds. Black, dark gray, deep blue. Urban/industrial environments.

**Color language:** Each power has a signature color that appears in:
- The power's visual effects
- The boss's arena theme
- The UI elements when that power is equipped
- The energy bar tint

| Power | Color | Hex Reference |
|---|---|---|
| Fireballs | Orange | #FF6B1A |
| Telekinesis | Purple | #9B30FF |
| Blink | Green | #39FF14 |
| Time Freeze | White/Silver | #E0E0E0 |
| Player (base) | Red | #CC0000 |
| Hub/UI | Neutral gray | #444444 |

**Pixel art specifications:**
- Character sprites: 32x32 pixels (allows readable animations without excessive frame count)
- Tile size: 16x16 pixels
- Animation frames: 4-6 per action (walk, attack, dash, idle)
- Resolution: 480x270 native, scaled up (pixel-perfect rendering)
- Target framerate: 60fps

### AI-Assisted Art Pipeline

Given the solo dev constraint, the following AI tools can accelerate asset creation:
- **Sprite generation:** Use AI image generators for base sprite concepts, then manually clean up and animate in Aseprite or Pixelorama.
- **Tileset generation:** Generate tileset themes (industrial, urban, fire-damaged, etc.), then manually ensure seamless tiling.
- **VFX:** Particle effects can be prototyped with Godot's built-in particle system. Power colors make effects readable even with simple particles.
- **Sound:** AI music generation (Suno, Udio) for dark ambient tracks. Sound effects from Freesound.org or AI-generated.

---

## 9. Technical Architecture (Godot 4.x)

### Project Structure

```
res://
├── scenes/
│   ├── player/
│   │   ├── player.tscn          # Player scene (CharacterBody2D)
│   │   ├── player.gd            # Movement, melee, dash
│   │   └── powers/
│   │       ├── power_base.gd    # Base power class
│   │       ├── fireball.gd
│   │       ├── telekinesis.gd
│   │       ├── blink.gd
│   │       └── time_freeze.gd
│   ├── bosses/
│   │   ├── boss_base.gd         # Shared boss behavior (phases, health)
│   │   ├── hothead/
│   │   ├── hurler/
│   │   ├── blitzer/
│   │   ├── warden/
│   │   └── hunter/
│   ├── rooms/
│   │   ├── room_base.gd         # Room transition logic
│   │   ├── boss1_room1.tscn
│   │   ├── boss1_room2.tscn
│   │   ├── boss1_arena.tscn
│   │   └── ...
│   ├── ui/
│   │   ├── hud.tscn             # Health, energy, power icons
│   │   ├── hub_menu.tscn        # Mission select
│   │   ├── power_swap.tscn      # Post-ritual swap screen
│   │   └── pause_menu.tscn
│   └── effects/
│       ├── particles/
│       └── screen_effects/
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd      # Game state, progression
│   │   ├── power_manager.gd     # Power inventory, swap logic
│   │   └── input_manager.gd     # Controller/keyboard mapping
│   └── utils/
├── assets/
│   ├── sprites/
│   ├── tilesets/
│   ├── audio/
│   └── fonts/
└── project.godot
```

### Key Systems

**State Machine (Player & Bosses):** Use a hierarchical state machine for player states (Idle, Move, Attack, Dash, PowerUse, Stunned, Dead) and boss states (Idle, Phase1, Phase2, Phase3, Phase4, Stunned, Dead). Godot's `AnimationTree` with state machine mode handles this well.

**Power System Architecture:** Use a base `Power` class with virtual methods (`activate()`, `deactivate()`, `update()`). Each power inherits from this. The `PowerManager` autoload holds two `Power` references (slot1, slot2) and handles swap logic. This makes adding/removing powers clean.

**Energy System:** `PowerManager` handles a passive regen timer (5 energy/sec via `_process(delta)`). Energy persists across room transitions within a boss sequence — `GameManager` stores the current energy value before scene change and restores it after loading the next room. Energy resets to 0 only when starting a new boss sequence from the hub.

**Dash System:** Dash is on a separate 0.5s cooldown timer in `player.gd`, independent of the energy meter. Use a simple `Timer` node or a float countdown in `_process()`. Dash does NOT consume energy.

**Energy Bar Visibility:** The HUD energy bar is hidden by default. `PowerManager` emits a signal (`first_power_acquired`) when the player completes their first ritual (Boss 1). The HUD listens for this signal and reveals the energy bar permanently. `GameManager` persists this flag across sessions.

**Room Transition:** Each boss sequence is a series of scenes. `GameManager` tracks which room the player is in and the player's current energy. On death, reload current room scene with energy reset to room-entry value (prevents energy farming by dying). On completion, transition to next room with current energy preserved. Use `SceneTree.change_scene_to_packed()` with a brief fade transition.

**Controller Support:** Godot 4.x has built-in controller support via the Input Map. Define actions (move_up, move_down, aim_x, aim_y, melee, dash, power1, power2, interact) and map to both controller and keyboard. Twin-stick aiming uses `Input.get_vector()` for left stick and right stick separately.

### Performance Considerations

- Top-down 2D with pixel art is extremely lightweight. Godot handles this effortlessly.
- Particle effects should use `GPUParticles2D` for power visuals.
- **Time Freeze power (player uses):** Shader on a `CanvasLayer` that desaturates everything except the player. Set enemy speed multipliers to 0 and stop projectile movement via a global `time_frozen` flag checked in all enemy/projectile `_process()` methods. Duration tracked by `PowerManager`.
- **Time Slow (Warden boss uses on player):** Reduce player's `move_speed` and `attack_speed` by 50% via a `slow_multiplier` variable in `player.gd`. Apply a visual aura effect (shader or particle) to the player sprite. Dash distance is halved (same i-frames). The slow effect is toggled by the boss's state machine during specific phases. Critically: input response remains instant — only movement/animation speed changes. This prevents the "broken controller" feel.

---

## 10. Controls Reference

### Controller Layout (Xbox / PlayStation)

```
                    [LB/L1]  Dash          [RB/R1]  Melee Attack
                    [LT/L2]  Power 2       [RT/R2]  Power 1

    [Left Stick]    Move (8-dir)           [Right Stick]  Aim Direction

                    [A/X]    Interact / Ritual
                    [B/O]    Cancel
                    [Start]  Pause Menu
```

### Keyboard + Mouse Fallback

| Action | Key |
|---|---|
| Move | WASD |
| Aim | Mouse position |
| Melee | Left Mouse Button |
| Dash | Space |
| Power 1 | Right Mouse Button |
| Power 2 | Shift |
| Interact / Ritual | E |
| Pause | Escape |

---

## 11. Development Milestones

### Phase 1: Prototype (Weeks 1-4)

**Goal:** Prove the core loop works and feels good.

| Week | Deliverable |
|---|---|
| 1 | Player movement, melee (auto-combo), dash (0.5s cooldown) in a test room. Controller support. Basic tilemap. |
| 2 | One power implemented (Fireballs). Energy meter (passive regen, 5/sec). One simple enemy type (melee minion — walks toward player, attacks). |
| 3 | Boss framework: health phases, state machine. Boss 1 (Hothead) greyboxed with placeholder art. 2 approach rooms with traps. |
| 4 | Ritual animation + power swap menu. Full loop: hub menu → approach rooms → boss → steal power → return to hub. |

**Milestone Gate:** Play through the Boss 1 loop start to finish. Does combat feel good? Is the steal moment satisfying? If no, iterate before moving on.

### Phase 2: Content Build (Weeks 5-16)

**Goal:** Build all 5 boss encounters, approach rooms, and thematic minions.

| Week | Deliverable |
|---|---|
| 5-6 | Boss 2 (Hurler) + Telekinesis power + approach rooms. Hurler-themed minion (ranged object thrower). |
| 7-9 | Boss 3 (Blitzer) + Blink power + approach rooms. Blitzer-themed minion (fast, repositioning). Extra week for set-path blink chain system. |
| 10-12 | Boss 4 (Warden) + Time Freeze power + approach rooms. Warden-themed minion (slow aura). Extra time for player speed modification system, time-zone shaders, slow-aura VFX. **Hardest boss to implement — do not rush.** |
| 13-15 | Boss 5 (Hunter, no power) + approach rooms. Hunter-themed minion (gadget user). Pre-scripted power counter system (2-3 counters per power). EMP zone implementation. |
| 16 | Full game playable start to finish with greybox art. **Balance pass:** tune boss damage, energy costs, room layouts, minion placement. Playtest the entire game 3-5 times and adjust. |

**Milestone Gate:** All 5 boss encounters playable with greybox/placeholder art. Full game completable from start to finish. Balance feels fair — no boss is trivial, no boss feels impossible.

### Phase 3: Polish (Weeks 17-24)

**Goal:** Art, audio, feel, and narrative polish.

| Week | Deliverable |
|---|---|
| 17-19 | Final pixel art for player (all power visual states), all 5 bosses, all minion types, all environment tilesets. 3 weeks to account for volume. |
| 20-21 | VFX polish: particles, screen effects, power visuals, hit feedback, ritual animation escalation. |
| 22-23 | Audio: music (1 track per boss + hub = 6 tracks), SFX for all actions. Narrative text (5 dossiers, environmental details). |
| 24 | Final playtesting, bug fixing, controller polish. Build export. |

**Milestone Gate:** Someone who has never seen the game can play it start to finish on a controller with no guidance.

### Phase 4: Ship (Week 25-28)

| Task | Timeframe |
|---|---|
| Final bug fixes | Week 25 |
| Itch.io page setup | Week 26 |
| Trailer / screenshots | Week 27 |
| Release | Week 28 |

---

## 12. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Boss design takes longer than estimated | High | High | Prototype Boss 1 fully before committing to schedule. Each subsequent boss reuses the framework. Boss 4 and 5 have extra weeks allocated. |
| Art quality inconsistency (solo pixel art) | Medium | Medium | Use a strict palette (max 16-24 colors). AI-assist base sprites. Consistency > detail. |
| Time Freeze feels too expensive to use | Medium | Medium | At 40 energy (8 seconds of regen), players may hoard it. Playtest and adjust cost. Consider reducing to 30-35 if usage rate is too low. The power must feel worth the wait. |
| Time Freeze trivializes encounters when used | Medium | Medium | 2.5 second duration limits impact. If still too strong, reduce duration to 2s or remove the 1.5x melee damage bonus. |
| Passive energy regen encourages passive/kiting play | Medium | High | Monitor during playtesting. If players kite instead of engaging, consider: (a) boss abilities that punish distance, (b) reducing regen rate to 3-4/sec, (c) adding a small melee hit bonus back. Design bosses with gap-closers to discourage pure kiting. |
| Scope creep (wanting more bosses/features) | High | High | This document is the scope. Nothing ships that isn't in this document. Post-launch is for extras. |
| Burnout (solo dev, 7 months) | Medium | Critical | Phase 1 is 4 weeks. If it isn't fun at week 4, pivot or stop. Don't build content for a broken core. Take at least 1 day off per week. |
| Multi-room boss chases inflate level design time | Medium | Medium | Keep rooms small (single-screen or 2-screen max). Reuse tile assets across bosses. Puzzle complexity stays low. |
| Thematic minions expand art/animation scope | Medium | Medium | All minions share a base AI template — only attack type and speed differ. Sprites can be simple (16x16 or 24x24). Limit to 1 type per zone. If timeline slips, cut to one universal enemy type with color swaps. |
| "Descent into obsession" narrative feels forced | Low | Low | Keep it subtle. Environmental storytelling only. If it doesn't land, the gameplay carries the experience. |
| Boss 4 (Warden) time-slow feels like a bug, not a mechanic | Medium | High | Implement visible slow-aura VFX, "SLOWED" UI indicator, and clear sound cue. Player must instantly understand "the boss did this to me" not "my game is broken." Playtest with fresh eyes early. |
| Boss 5 (Hunter) pre-scripted counters feel predictable | Low | Medium | Script 2-3 counter-strategies per power and cycle them. Players won't see all counters in one run (they only have 2 powers). Feels adaptive even though it's authored. |

---

## 13. Scope Boundaries

### IN Scope (Must Ship)

- 5 boss encounters (4 power-granting + 1 final)
- 4 unique powers with distinct combat and puzzle applications
- 10-15 approach rooms total (2-3 per boss) with traps, puzzles, and thematic minions
- 5 thematic minion types (1 per boss zone, shared base AI)
- Menu-based hub with mission select and target dossiers
- Power swap system (2 slots, simple swap menu after ritual)
- Energy meter (passive time-based regen, 5/sec)
- Dash (0.5s cooldown, separate from energy)
- Controller (twin-stick) and keyboard+mouse support
- Basic pixel art (clean, readable, color-coded, noir palette with power color accents)
- Environmental storytelling (no cutscenes, no voice acting)
- 5 pre-mission dossiers with escalating tone (clinical → obsessive)
- Ritual steal animation with escalating intensity per boss
- Silent ending sequence (pause, fade to black, credits)
- Music (1 track per boss zone + hub = 6 tracks) and SFX

### OUT of Scope (Do Not Build)

- Multiple weapon types or weapon selection
- Skill trees, stat upgrades, or progression beyond powers
- Power synergy/combos between equipped powers
- Real-time adaptive boss AI (use pre-scripted counters only)
- Unlockable cosmetics
- Online features (leaderboards, multiplayer)
- New Game+ or difficulty modes
- Dialogue systems, NPCs, or voiced characters
- Open world / exploration / backtracking
- Achievements / collectibles
- Walkable hub (menu only)
- Any 5th power
- Cutscenes or cinematics

### POST-LAUNCH Consideration (Only If Game Ships Successfully)

- 1-2 additional bosses/powers
- Power synergy system (simple combos between specific pairs)
- New Game+ with harder boss variants
- Walkable hub that evolves with kills
- Leaderboard (speedrun timer)

---

## 14. Competitive Reference

| Game | What to Learn | What to Avoid |
|---|---|---|
| **Hotline Miami** | Speed, lethality, instant restart, top-down camera, screen shake, controller feel | One-hit kills (too punishing for boss fights with patterns) |
| **Mega Man** | Boss-gives-power structure, thematic stage enemies, boss design | Rigid weakness chains (your powers are independent) |
| **Hyper Light Drifter** | Pixel art + noir tone, dash-centric combat, environmental storytelling | Cryptic navigation (your game is linear) |
| **Hades** | Fast combat, energy/resource management, boss phase escalation | Roguelike randomness (your game is authored) |
| **Heroes (TV)** | Sylar's predator fantasy, power acquisition as identity, obsession narrative | Overexplaining motivation (show, don't tell) |
| **Diablo** | Top-down power fantasy, satisfying ability usage, energy/mana management | Loot systems, procedural content (out of scope) |
| **Katana Zero** | Pixel art + time manipulation, fast-paced action, dark narrative tone | Complex narrative branching (keep it simple) |
| **Transistor** | Powers on cooldowns, tactical timing, top-down action, power-swapping decisions | Turn-based planning mode (your game is fully real-time) |
| **Superhot** | Manipulating the player's relationship with time as a core mechanic (reference for Warden boss) | First-person perspective, full time-stop (your version is a slow, not a freeze) |

---

## 15. Definition of Done

The game is shippable when:

1. A new player can pick up a controller and complete the full game (5 bosses) in 2-3 hours
2. All 4 powers feel distinct and useful in both combat and puzzles
3. The power swap decision creates genuine tension at least twice per playthrough
4. Each boss teaches their power through their behavior before the player acquires it
5. The ritual steal moment feels deliberate and satisfying every time
6. Deaths feel fair (player can identify what they did wrong)
7. The tone darkens noticeably from Boss 1 to Boss 5 (dossiers, environment, ritual intensity)
8. The game runs at 60fps with no crashes on PC
9. Controller (twin-stick) and keyboard+mouse both work fully
10. Someone watching the game understands the pitch in 30 seconds
11. Energy regen pace feels natural — powers are available often enough to be fun, scarce enough to require thought
12. Dash feels responsive and reliable as the primary defensive tool (0.5s cooldown never frustrates)
13. Boss 4 (Warden) time-slow is clearly a boss mechanic, not a performance issue — tested with fresh eyes
14. The silent ending (pause, fade, credits) lands emotionally — tested with at least one person who played blind

---

*This document is the single source of truth for POWERSTEAL. If a feature isn't here, it doesn't ship. Revisit this document weekly to check scope drift.*
