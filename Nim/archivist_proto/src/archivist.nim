# =========== IMPORTS ============
import os, strutils, httpclient, json, re

# ========== CONSTANTS ===========
let ROOT_DIR = "/mnt/rust/books/Brandon Sanderson/"
let CD_PATTERN = re"^(CD|Disc|Part)[\S._-]?\d{1,3}$"

# ============ TYPES =============
type

  DirNode = ref object
    path: string
    parent: DirNode
    children: seq[DirNode]
    info: FileInfo

  Book = object
    path: string
    author: string
    series: string
    title: string
    newPath: string
    approved: bool

# ============ UTILS =============
proc printDirNode(self: DirNode; indent: int = 0) =
  echo "   ".repeat(indent) & "\\__" & splitPath(self.path).tail
  for child in self.children: printDirNode child, indent + 1

proc isCDDir(node: DirNode): bool = return splitPath(node.path).tail.match(CD_PATTERN)

proc isLeafDir(node: DirNode): bool =
  if node.info.kind != pcDir or isCDDir node: return false
  for child in node.children: 
    if child.info.kind == pcDir and not isCDDir child: return false
  return true

proc lookup(self: DirNode): Book =
  # TODO: Likely need to formal uri, removing '-' and spaces, etc. Check URI module.
  let query = self.path[ROOT_DIR.len..^1].replace("/", " ").replace(re" Book \d*\.*\d*")
  let url = "https://www.googleapis.com/books/v1/volumes?maxResults=1&q=$#" % query
  echo url
  let response = newHttpClient().getContent(url)
  # let data = parseJson response
  echo response
  sleep 4
  assert(2==3)

# ============ PROCS =============
proc readDir(path: string, parent: DirNode = nil): DirNode =
  result = DirNode(
    path: path,
    parent: parent,
    children: @[],
    info: getFileInfo(path)
  )
  if result.info.kind == pcDir:
    for entry in os.walkDir(path):
      if entry.path notin [".", ".."]:
        try: result.children.add(readDir(entry.path, result))
        except OSError: echo "Cannot access: ", entry.path

proc leaves(self: DirNode): seq[DirNode] =
  if isLeafDir(self): result.add(self)
  for child in self.children: result.add(child.leaves())

proc match(self: seq[DirNode]): seq[Book] =
  for node in self:
    result.add lookup node

proc mapPaths(): auto = discard

proc hardlinkFiles(): auto = discard

proc extractBookNames(path: string): string = result = splitPath(path).tail.replace("_", " ").replace("-", " ")

# ============ MAIN ==============
proc main() =
  let tree = readDir ROOT_DIR
  let leaves = leaves tree
  let matches = match leaves

if isMainModule: main()

