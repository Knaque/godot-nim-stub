import cligen, strutils, os, std/macros, algorithm

macro asArray(oa: static seq[string]): untyped =
  # macro provided by ElegantBeef to turn seqs into arrays at compile time
  result = nnkBracket.newNimNode()
  for x in oa:
    result.add newLit(x)

proc getNodeNames(): seq[string] {.compileTime.} =
  # get the name of every godot node by walking the godotapi directory
  for f in walkDir("src/godotapi"):
    if f.path.endsWith(".nim"):
      result.add f.path.split("\\")[^1][0..^5]

const nodeNames = getNodeNames().asArray

proc isValidNode(node: string): bool = nodeNames.binarySearch(node) != -1

proc probableObjName(node: string): string =
  # this spits out what is *probably* the object name of a given node
  for x in node.split("_"):
    result.add x.capitalizeAscii

proc newscript(name: string, node: string) =
  # cli command
  let
    uppername = name.capitalizeAscii
    lowername = name.toLower
    lowernode = node.toLower

  if not isValidNode(lowernode):
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

dispatch(newscript)