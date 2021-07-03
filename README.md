# godot-nim-stub

This is a stub project used to make creating Godot projects with Nim a little bit easier.

This is a fork of [pragmagic/godot-nim-stub](https://github.com/pragmagic/godot-nim-stub) where I have made a few improvements.

- The nakefile now properly creates the Godot API.
- I've created a little utility called `gdu` to make things easier for developers. At the moment, `gdu` is only used to automatically generate template scripts, but its functionality may expand in the future.

## Prerequisites:

1. Ensure `~/.nimble/bin` is on your PATH. (`C:\Users\<your_name>\.nimble\bin` on Windows.)
2. Set the `GODOT_BIN` environment variable to point to your Godot executable.
3. `nimble install nake`
4. `nimble install godot@0.7.28` **and** `nimble install godot@0.8.3`

## Usage:

1. Run `gdu --name=<component_name> --node=<node_type>` to create new `.nim` and `.gdns` files for you. `import <component_name>` will also automatically be appended to `stub.nim` for you.

2. Run `nake build` to compile all of your components.

3. Do everything else in Godot!

## Notes:

- Don't create GDNative scripts in Godot itself - use `gdu` for that - and instead *load* them onto nodes after the scripts have been created.

- You need to have *two* versions of [pragmagic/godot-nim](https://github.com/pragmagic/godot-nim) installed: `0.7.28` and `0.8.3`. Why? Hell if I know.