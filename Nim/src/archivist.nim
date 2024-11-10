# =========== IMPORTS ============
import os, strutils, httpclient, json, uri, re

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
proc `$`(node: DirNode): string = result = node.path

proc printDirNode(node: DirNode; indent: int = 0) =
  echo repeat("   ", indent) & "\\__" & splitPath(node.path).tail
  for child in node.children: printDirNode(child, indent + 1)

proc matchesCDPattern(node: DirNode): bool = return splitPath(node.path).tail.match(CD_PATTERN)

proc isLeafDir(node: DirNode): bool =
  if node.info.kind != pcDir or matchesCDPattern(node): return false
  for child in node.children: 
    if child.info.kind == pcDir and not matchesCDPattern(child): return false
  return true

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

# TODO: Adapt this into matchBooks(seq[DirNode]): seq[Book] =
proc matchBooks(author, title: string, apiKey: string): JsonNode =
  let client = newHttpClient()
  var query = ""
  if author.len > 0: query &= "inauthor:" & author & " "
  if title.len > 0: query &= "intitle:" & title & " "
  query = query.strip()
  let encodedQuery = encodeUrl(query)
  let url = "https://www.googleapis.com/books/v1/volumes?q=" & encodedQuery & "&key=" & apiKey
  try:
    let response = client.getContent(url)
    let jsonData = parseJson(response)
    return jsonData
  except:
    echo "Error fetching data from Google Books API."
    return %*{}

proc mapPaths(): auto = discard

proc hardlinkFiles(): auto = discard

proc extractBookNames(path: string): string = result = splitPath(path).tail.replace("_", " ").replace("-", " ")

# ============ MAIN ==============
proc main() =
  let tree = readDir(ROOT_DIR)
  echo tree.leaves()

if isMainModule: main()
