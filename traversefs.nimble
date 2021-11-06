# Package

version       = "0.1.0"
author        = "Sean https://github.com/shogan"
description   = "Traverses a target filesystem directory & outputs the collected hierarchy to JSON"
license       = "MIT"
srcDir        = "src"
bin           = @["traversefs"]


# Dependencies

requires "nim >= 1.6.0"
requires "docopt == 0.6.8"