# anti_noclip

A fast, modular server-side anti-cheat built to stop noclip, wall-phasing, and speed exploits on Roblox. 

Most anti-cheats can be bypassed because they trust the client. This framework operates on a **zero-trust model**, which handles 100% of player position and velocity validation strictly on the server via `RunService.Heartbeat`.

## Features
* The configuration module is hidden inside `ServerStorage`. This stops exploiters from reverse-engineering or reading your detection limits via local memory dumps.
* Combines 3D bounding box checks (`GetPartBoundsInBox`) with forward/backward raycasting to catch fast players phasing through thin walls between frames.
* Automatically reads `AssemblyLinearVelocity` to ignore valid server impulses (like knockbacks, pads, or explosions), preventing annoying false-positives.
* Explicitly flushes player dictionaries on `PlayerRemoving` to keep server memory clean over long uptimes.
* Uses a decaying violation counter instead of instant kicks. It easily handles minor network latency spikes while aggressively dropping the hammer on persistent hackers.

## File Structure (Rojo Optimized)
Built to integrate seamlessly with modern industry workflows like Rojo and VS Code:

```text
roblox-anti-noclip/
├── src/
│   ├── ServerScriptService/
│   │   └── AntiNoclip.server.luau    # Core validation loop
│   └── ServerStorage/
│       └── NoclipConfig.luau          # Secure server-only settings
├── default.project.json               # Rojo sync map
└── README.md                          # Documentation
```

## Configuration Setup
You can easily change values inside `src/ServerStorage/NoclipConfig.luau` without messing up the main logic loop:

```lua
local NoclipConfig = {
    MAX_SPEED_LIMIT = 40,
    TELEPORT_BACK = true,
    MAX_VIOLATIONS = 10,
    SURFACE_BUFFER = 0.8,
    WALL_COLLISION_GROUP = "Default"
}
return NoclipConfig
```

## Commissions
I specialize in writing highly optimized, defensive backend infrastructure, data security, and exploit prevention systems. If you need a scripter who knows how to write clean, modular, and un-exploitable code, hit me up :)

* **GitHub:** @anti-noclip
