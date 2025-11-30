# Package

version       = "0.1.0"
author        = "Kieran Hannigan"
description   = "Sync tool for the R36S handheld"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["r36sync"]


# Dependencies

requires "nim >= 2.2.0"

requires "ui >= 0.9.4"