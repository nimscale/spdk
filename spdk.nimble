#Package

version       = "16.08"
author        = "Nimscale"
description   = "SDPK bind for nim."
license       = "Apache Licence 2.0"

srcDir = "api"

# Dependencies

requires "nim >= 0.15.3"

task build, "Building SPDK!":
  setCommand "nim e build.nims"

