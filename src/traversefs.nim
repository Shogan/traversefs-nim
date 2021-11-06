import os
import options
import json
import docopt
import strutils

let doc = """
traversefs

Usage:
  traversefs [-p | --pretty] [-r | --recurse] PATH

Arguments:
  PATH          The path to begin traversing

Options:
  -h --help     Show this screen.
  --version     Show version.
  -p --pretty   Pretty print JSON
  -r --recurse  Recusively traverse paths.
"""

type
    PathObjectNodeType = enum
        file, directory

type
    PathObjectNode = object
        name: string
        relativePath: string
        absolutePath: string
        fileSizeBytes: Option[BiggestInt]
        nodeType: PathObjectNodeType
        children: seq[PathObjectNode]

proc listFilesInDir(path: string, hierarchy: var seq[PathObjectNode], recurse: bool): seq[PathObjectNode] =
    try:
        for pathObj in walkDir(path, false, true):
            # Don't handle links to files or dirs, only actual files / dirs
            if pathObj.kind == pcDir:
                var tempChildren = newSeq[PathObjectNode]()
                var recursiveChildren = newSeq[PathObjectNode]()
                if recurse:
                    recursiveChildren = listFilesInDir(pathObj.path, tempChildren, recurse);
                
                var node = PathObjectNode(name: pathObj.path,
                    relativePath: relativePath(pathObj.path, path),
                    absolutePath: absolutePath(pathObj.path),
                    nodeType: PathObjectNodeType.directory,
                    children: recursiveChildren
                )
                hierarchy.add(node);
            elif pathObj.kind == pcFile:
                var node = PathObjectNode(name: pathObj.path,
                    relativePath: relativePath(pathObj.path, path),
                    absolutePath: absolutePath(pathObj.path),
                    fileSizeBytes: option(getFileSize(pathObj.path)),
                    nodeType: PathObjectNodeType.file,
                    children: newSeq[PathObjectNode]()
                )
                hierarchy.add(node);
        return hierarchy
    except OSError:
        echo "Invalid path was supplied."

let args = docopt(doc, version = "traversefs 0.1.0")

if (args["PATH"]):
    let recurse: bool = parseBool($args["--recurse"])
    let prettyPrint: bool = parseBool($args["--pretty"])

    var hierarchy = newSeq[PathObjectNode]()
    let inputPath: string = $args["PATH"]

    try:
        var dirList = listFilesInDir(inputPath, hierarchy, recurse)
        var rootNode = PathObjectNode(
            name: inputPath,
            relativePath: relativePath(inputPath, getCurrentDir()),
            absolutePath: absolutePath(inputPath),
            nodeType: PathObjectNodeType.directory,
            children: dirList
        )
        if prettyPrint:
            echo pretty(%rootNode)
        else:
            echo(%rootNode)
    except OSError:
        echo "Invalid path was supplied."
