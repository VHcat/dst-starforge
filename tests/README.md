Run from the repository root with Lua 5.1:

```sh
lua tests/run.lua
lua tests/run.lua permissions
```

The suites execute the original mod components with minimal mocked game services.
They do not start DST, connect to Steam, send RPCs, or modify saves.
Run in-game multiplayer and save/load checks before publishing a playable release.

Each fix adds a focused suite; the runner defaults to all committed suites.
The tests use only the Lua standard library. Lupa's `lua51.LuaRuntime` may also
execute the runner when a standalone Lua interpreter is unavailable.
