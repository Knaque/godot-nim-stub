# godot-nim-stub

This is a stub project used to make creating Godot projects with Nim a little bit easier.

This is a fork of [pragmagic/godot-nim-stub](https://github.com/pragmagic/godot-nim-stub) where I have made a few improvements. Most notably, I've replaced the nakefile with a little utility program called `gdu`. `gdu` can perform all the functions of the original nakefile (`gdu build`, `gdu clean`), but also provides `gdu newScript` and `gdu delScript` commands to make things a little easier.

## Prerequisites:

1. Ensure `~/.nimble/bin` is on your PATH. (`C:\Users\<your_name>\.nimble\bin` on Windows.)
2. Set the `GODOT_BIN` environment variable to point to your Godot executable.
3. `nimble install godot@0.7.28` **and** `nimble install godot@0.8.3`

## Usage:

1. Clone this stub with `git clone --depth=1 https://github.com/knaque/godot-nim-stub.git <project_name>`.

2. Build `gdu` with `nim c gdu`.

3. Run `gdu build` to generate the Godot API and build your project for the current platform.

4. Run `gdu newScript --name=<component_name> --node=<node_type>` to create new `.nim` and `.gdns` files for you. `import <component_name>` will also automatically be appended to `stub.nim`.

5. Write your Nim code in your editor of choice.

6. When you want to delete a script, run `gdu delscript --name=<component_name>` to remove the `.nim` and `.gdns` files associated with that name, as well as the `import <component_name>` from `stub.nim`.

7. Don't forget to rebuild (`gdu build`) whenever you edit your scripts if you actually want to see your changes.

7. Do everything else in Godot!

## Notes:

- Don't create GDNative scripts in Godot itself - use `gdu` for that - and instead *load* them onto nodes after the scripts have been created.

- You need to have *two* versions of [pragmagic/godot-nim](https://github.com/pragmagic/godot-nim) installed: `0.7.28` and `0.8.3`. Why? Hell if I know.