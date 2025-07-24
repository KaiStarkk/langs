import ui, os, parsecfg

# Configuration file path
const configFile = "config.ini"

# Key for directory pairs section
const dirPairsSection = "DirectoryPairs"

# Load directory pairs from the configuration file
proc loadDirectoryPairs(): seq[(string, string)] =
  var pairs: seq[(string, string)] = @[]
  if fileExists(configFile):
    let cfg = loadConfig(configFile)
    for key, value in cfg.items(dirPairsSection):
      pairs.add((key, value))
  return pairs

# Save directory pairs to the configuration file
proc saveDirectoryPairs(pairs: seq[(string, string)]) =
  var cfg: Config
  if fileExists(configFile):
    cfg = loadConfig(configFile)
  else:
    cfg = newConfig()

  cfg.delSection(dirPairsSection)  # Clear existing section
  for pair in pairs:
    cfg.setSectionKey(dirPairsSection, pair[0], pair[1])
  cfg.writeConfig(configFile)

# Scan directories for newer files and synchronize
proc scanAndSync(mainwin: Window, dirPairs: seq[(string, string)]) =
  for (sourceDir, targetDir) in dirPairs:
    if not (dirExists(sourceDir) and dirExists(targetDir)):
      msgBoxError(mainwin, "Invalid Directories", fmt"One or both directories do not exist:\n{sourceDir}\n{targetDir}")
      continue

    let sourceFiles = walkFiles(sourceDir).filterIt(it.endsWith(".srm") or it.endsWith(".sav") or it.endsWith(".state"))
    let targetFiles = walkFiles(targetDir).toTable()  # Use a table for quick lookup
    var actions = @[]

    for file in sourceFiles:
      let relativePath = file.stripPrefix(sourceDir)
      let targetFile = joinPath(targetDir, relativePath)
      if not targetFile in targetFiles or getLastModTime(file) > getLastModTime(targetFile):
        actions.add((file, targetFile))

    if actions.len > 0:
      var msg = "The following files are newer and will be copied:\n\n"
      for (src, dest) in actions:
        msg &= fmt"{src} -> {dest}\n"
      if msgBoxYesNo(mainwin, "Synchronization", msg) == 1:
        for (src, dest) in actions:
          try:
            copyFile(src, dest)
          except:
            msgBoxError(mainwin, "Error Copying File", fmt"Could not copy:\n{src} -> {dest}")
    else:
      msgBox(mainwin, "Synchronization", "All files are up-to-date.")

# Main procedure for the UI
proc main*() =
  var mainwin = newWindow("Directory Pair Manager", 640, 480, true)
  mainwin.margined = true

  let box = newVerticalBox(true)
  mainwin.setChild(box)

  # Directory pairs list
  var dirPairs = loadDirectoryPairs()
  var pairList = newCombobox()
  for pair in dirPairs:
    pairList.add fmt"{pair[0]} -> {pair[1]}"
  box.add(pairList)

  # Input fields for new directory pair
  var sourceEntry = newEntry()
  sourceEntry.text = "Source Directory"
  box.add(sourceEntry)

  var targetEntry = newEntry()
  targetEntry.text = "Target Directory"
  box.add(targetEntry)

  # Add pair button
  let addPairButton = newButton("Add Pair")
  addPairButton.onClick = proc() =
    let sourceDir = sourceEntry.text
    let targetDir = targetEntry.text
    if dirExists(sourceDir) and dirExists(targetDir):
      dirPairs.add((sourceDir, targetDir))
      pairList.add fmt"{sourceDir} -> {targetDir}"
      saveDirectoryPairs(dirPairs)
      sourceEntry.text = "Source Directory"
      targetEntry.text = "Target Directory"
    else:
      msgBoxError(mainwin, "Invalid Directories", "One or both directories do not exist.")
  box.add(addPairButton)

  # Scan button
  let scanButton = newButton("Scan")
  scanButton.onClick = proc() = scanAndSync(mainwin, dirPairs)
  box.add(scanButton)

  # Show main window and start event loop
  show(mainwin)
  mainLoop()

init()
main()
