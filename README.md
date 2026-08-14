# POWERSTEAL

> You are the villain. Hunt down people with superpowers, kill them, steal their
> abilities. Keep only two. Become something inhuman.

**POWERSTEAL** is a top-down, fast-paced 2D action game inspired by the predatory
power-theft of Sylar from *Heroes*, the speed and lethality of *Hotline Miami*,
and the boss-driven progression of *Mega Man*. You play a villain protagonist
who hunts superpowered targets, ritually steals each boss's ability after
defeating them — and can only hold **two powers at a time**, forcing constant
trade-off decisions.

Built with **Godot 4.6**.

---

## Current status

This is a playable prototype implementing the full core loop:

- 5 boss encounters (Hothead, Hurler, Blitzer, Warden, Hunter)
- 4 stealable powers (Fireballs, Telekinesis, Blink, Time Freeze)
- Manual **ritual** power theft with a hold-to-steal interaction
- Two-slot **power swap** menu with replace/discard choices
- **Energy** meter (passive regen) that gates power usage
- Hub mission select with dossiers and progression tracking
- Pause menu, settings menu (video + input rebinding), and save/load

For the long-term roadmap, see [`PROJECT_TASKS.md`](PROJECT_TASKS.md) and the
[`GAME_DESIGN_DOCUMENT.md`](GAME_DESIGN_DOCUMENT.md).

---

## Features

### The loop

```
Hub → approach rooms → boss fight → ritual → power swap → Hub
```

Each boss teaches you its ability by using it against you first. After the kill
you hold the interact button to perform the ritual and absorb it.

### Powers

| Power | Source | Description |
|---|---|---|
| Fireballs | Boss 1 — Hothead | Ranged projectile that leaves burning fire patches |
| Telekinesis | Boss 2 — Hurler | Grab and throw objects/enemies |
| Blink | Boss 3 — Blitzer | Teleport short distances, passing through walls |
| Time Freeze | Boss 4 — Warden | Freeze time briefly |

### Bosses

| # | Name | Power | Theme |
|---|---|---|---|
| 1 | Hothead | Fireballs | Pyrokinetic charger with fire trails and rings |
| 2 | Hurler | Telekinesis | Kiting thrower who depletes the arena around them |
| 3 | Blitzer | Blink | Phase-shifting teleporter with telegraphed blinks |
| 4 | Warden | Time Freeze | Time-distorting pursuer with slow fields |
| 5 | Hunter | None | The hunter of hunters — final encounter |

---

## Controls

| Action | Keyboard + Mouse | Controller |
|---|---|---|
| Move | WASD | Left stick |
| Aim | Mouse | Right stick |
| Melee | Left Mouse | R1 / RB |
| Dash | Space | L1 / LB |
| Power 1 | Right Mouse | R2 / RT |
| Power 2 | Middle Mouse | L2 / LT |
| Interact / Ritual | E | A / X |
| Pause | Esc | Start |

Most keyboard/mouse bindings are remappable from the in-game Settings menu.

---

## Running the project

1. Install [Godot 4.6](https://godotengine.org/download) (or newer 4.x).
2. Open the project in Godot:
   ```sh
   godot --path .
   ```
   or import the `project.godot` file from the Godot project manager.
3. Press **F5** (or the Play button) to run. The main scene is the Hub menu.

### Running from the command line

```sh
godot --path .            # run the game
godot --headless --quit   # validate that the project imports cleanly
```

---

## Project structure

```
scenes/
  bosses/         # One folder per boss (script, scene, minions)
  player/         # Player scene + powers/
  rooms/          # Boss arenas and test room
  ui/             # Hub, pause, settings, power swap, ritual prompt
scripts/
  autoload/       # GameManager, PowerManager, InputManager, SettingsManager
assets/           # Art and other game assets
```

- `GAME_DESIGN_DOCUMENT.md` — full design document
- `PROJECT_TASKS.md` — 28-week task breakdown and roadmap

---

## Exporting

Export presets for macOS and Windows are configured in `export_presets.cfg`.
Generated build artifacts in `build/` are git-ignored.
