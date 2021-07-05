import cligen, strutils, os, algorithm, terminal, osproc, godotapigen, times

proc genGodotApi() =
  let godotBin = getEnv("GODOT_BIN")
  if godotBin.len == 0:
    echo "GODOT_BIN environment variable is not set"
    quit -1
  if not fileExists(godotBin):
    echo "Invalid GODOT_BIN path: " & godotBin
    quit -1

  const targetDir = "src"/"godotapi"
  createDir(targetDir)

  const jsonFile = targetDir/"api.json"

  if not fileExists(jsonFile) or godotBin.getLastModificationTime() > jsonFile.getLastModificationTime():
    # pragmagic's original nakefile was broken here - it works now.
    discard execCmd("$1 --gdnative-generate-json-api $2" % [godotBin, jsonFile])

    if not fileExists(jsonFile):
      echo "Failed to generate api.json"
      quit -1

    genApi(targetDir, jsonFile)
    echo "Godot API generated successfully."
  else:
    echo "Godot API already exists."

proc build() =
  ## Builds your scripts for the current platform.
  genGodotApi()
  let bitsPostfix = when sizeof(int) == 8: "_64" else: "_32"
  let libFile =
    when defined(windows):
      "nim" & bitsPostfix & ".dll"
    elif defined(ios):
      "nim_ios" & bitsPostfix & ".dylib"
    elif defined(macosx):
      "nim_mac.dylib"
    elif defined(android):
      "libnim_android.so"
    elif defined(linux):
      "nim_linux" & bitsPostfix & ".so"
    else: nil
  createDir("_dlls")
  setCurrentDir("src")
  quit execCmd("nimble c ../src/stub.nim -o:../_dlls/$1" % libFile)
proc clean() =
  ## Remove files produced by building.
  removeDir(".nimcache")
  removeDir("src"/".nimcache")
  removeDir("src"/"godotapi")
  removeDir("_dlls")

proc getValidNodes(): seq[string] =
  # get the name of every godot node by walking the godotapi directory
  for f in walkDir("src/godotapi"):
    if f.path.endsWith(".nim"):
      result.add f.path.split("\\")[^1][0..^5]
proc probableObjName(node: string): string =
  # this spits out what is *probably* the object name of a given node
  for x in node.split("_"):
    result.add x.capitalizeAscii
proc newScript(name: string, node: string) =
  ## Creates a new script.

  genGodotApi()

  let validNodes = getValidNodes()

  let
    uppername = name.capitalizeAscii
    lowername = name.toLower
    lowernode = node.toLower

  if validNodes.binarySearch(node) == -1:
    echo "'$1' is not a valid node type." % node
    quit -1

  # create the .nim file
  writeFile("src/$1.nim" % lowername,
"""import godot
import godotapi / [$1]

gdobj $2 of $3:

  method ready*() =
    discard

  method process*(delta: float64) =
    discard
""" % [lowernode, uppername, lowernode.probableObjName])

  # create the .gdns file
  writeFile("scripts/$1.gdns" % uppername,
"""[gd_resource type="NativeScript" load_steps=2 format=2]

[ext_resource path="res://nimlib.gdnlib" type="GDNativeLibrary" id=1]

[resource]

resource_name = "$1"
library = ExtResource( 1 )
class_name = "$1"

""" % uppername)

  # append the new component to the stub
  var stub = open("src/stub.nim", fmAppend)
  stub.write "\nimport " & lowername
  stub.close()

  echo "Created new script '$1' of type '$2'." % [uppername, lowernode]
  quit 0

proc delScript(name: string) =
  ## Deletes an existing script.

  let
    uppername = name.capitalizeAscii
    lowername = name.toLower

  if not fileExists("scripts/$1.gdns" % uppername):
    echo "'$1' does not exist. (Nim-style case sensitivity?)" % uppername
    quit -1

  echo "Are you sure you want to delete the script '$1'? (y/N)" % uppername
  case getch().toLowerAscii
  of 'y':
    removeFile("src/$1.nim" % lowername)
    removeFile("scripts/$1.gdns" % uppername)

    let contents = readFile("src/stub.nim")
    var stub = open("src/stub.nim", fmWrite)
    stub.write(contents.replace("import $1" % lowername, "").replace("\n\n", ""))
    stub.close()

    echo "Successfully deleted script '$1'." % uppername
  else:
    echo "Aborted."

dispatchMulti(
  [build],
  [clean],
  [newScript, help={"name": "The name for the new script",
    "node": "The Godot node type for the new script"}
  ],
  [delScript, help={"name": "The name of the script you want to delete"}])