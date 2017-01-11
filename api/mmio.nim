 {.deadCodeElim: on.}
when defined(windows):
  const
    libspdk* = "libspdk.dll"
elif defined(macosx):
  const
    libspdk* = "libspdk.dylib"
else:
  const
    libspdk* = "libspdk.so"
## -
##    BSD LICENSE
##
##    Copyright (c) Intel Corporation.
##    All rights reserved.
##
##    Redistribution and use in source and binary forms, with or without
##    modification, are permitted provided that the following conditions
##    are met:
##
##      * Redistributions of source code must retain the above copyright
##        notice, this list of conditions and the following disclaimer.
##      * Redistributions in binary form must reproduce the above copyright
##        notice, this list of conditions and the following disclaimer in
##        the documentation and/or other materials provided with the
##        distribution.
##      * Neither the name of Intel Corporation nor the names of its
##        contributors may be used to endorse or promote products derived
##        from this software without specific prior written permission.
##
##    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
##    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
##    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
##    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
##    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
##    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
##    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
##    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
##    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
##    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## * \file
##  Memory-mapped I/O utility functions
##

when defined(cpu64):  # cpu64 those symbols check if a program is built for a particular architecture, not running on it (say, if a 32-bit exe is running on 64 bit system)
  const
    SPDK_MMIO_64BIT = 1
else:
  const
    SPDK_MMIO_64BIT = 0

proc spdk_mmio_read_4*(`addr`: ptr uint32): uint32 {.inline, cdecl.} =
  return `addr`[]

proc spdk_mmio_write_4*(`addr`: ptr uint32; val: uint32) {.inline, cdecl.} =
  `addr`[] = val

proc spdk_mmio_read_8*(`addr`: ptr uint64): uint64 {.inline, cdecl.} =
  var val: uint64
  var addr32: ptr uint32 = cast[ptr uint32](`addr`[])
  if 1 == SPDK_MMIO_64BIT:
    val = `addr`[]
  else:
    ##
    ##  Read lower 4 bytes before upper 4 bytes.
    ##  This particular order is required by I/OAT.
    ##  If the other order is required, use a pair of spdk_mmio_read_4() calls.
    ##
    val = cast[uint64](addr32[0])
    val = val or cast[uint64](addr32[1]) shl 32
  return val

proc spdk_mmio_write_8*(`addr`: ptr uint64; val: uint64) {.inline, cdecl.} =
  var addr32: ptr uint32
  if SPDK_MMIO_64BIT == 1:
    `addr`[] = val
  else:
    addr32[0] = cast[uint32](val)
    addr32[1] = (uint32)(val shr 32)
