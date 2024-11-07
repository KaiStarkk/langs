import os, strutils

type
  Book* = ref object
    author*: string
    series*: string
    title*: string

type
  PathMapping* = ref object
    oldPath*: string
    newPath*: string
    book*: Book
    approved*: bool

# Function to extract the book name from the directory path
proc extractBookName*(path: string): string =
  ## Extracts the book name from the directory path.
  # Assuming the last part of the path is the book name
  return splitPath(path).tail.replace("_", " ").replace("-", " ")

# Main procedure
proc main() =
  let rootDir = "/path/to/directory"       # Replace with your directory
  let prefixPath = "/new/prefix/path"      # Replace with your prefix path

when isMainModule:
  main()

