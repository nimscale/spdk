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
## *
##  \file
##  Endian conversion functions
##

proc from_be16*(`ptr`: pointer): uint16 {.inline, cdecl.} =
  var tmp: ptr uint8
  return (cast[uint16](tmp[0]) shl 8) or tmp[1]

proc to_be16*(`out`: pointer; `in`: uint16) {.inline, cdecl.} =
  var tmp: ptr uint8
  tmp[0] = (`in` shr 8) and 0x000000FF
  tmp[1] = `in` and 0x000000FF

proc from_be32*(`ptr`: pointer): uint32 {.inline, cdecl.} =
  var tmp: ptr uint8
  return (cast[uint32](tmp[0]) shl 24) or (cast[uint32](tmp[1]) shl 16) or
      (cast[uint32](tmp[2]) shl 8) or (cast[uint32](tmp[3]))

proc to_be32*(`out`: pointer; `in`: uint32) {.inline, cdecl.} =
  var tmp: ptr uint8
  tmp[0] = (`in` shr 24) and 0x000000FF
  tmp[1] = (`in` shr 16) and 0x000000FF
  tmp[2] = (`in` shr 8) and 0x000000FF
  tmp[3] = `in` and 0x000000FF

proc from_be64*(`ptr`: pointer): uint64 {.inline, cdecl.} =
  var tmp: ptr uint8
  return (cast[uint64](tmp[0]) shl 56) or (cast[uint64](tmp[1]) shl 48) or
      (cast[uint64](tmp[2]) shl 40) or (cast[uint64](tmp[3]) shl 32) or
      (cast[uint64](tmp[4]) shl 24) or (cast[uint64](tmp[5]) shl 16) or
      (cast[uint64](tmp[6]) shl 8) or (cast[uint64](tmp[7]))

proc to_be64*(`out`: pointer; `in`: uint64) {.inline, cdecl.} =
  var tmp: ptr uint8
  tmp[0] = (`in` shr 56) and 0x000000FF
  tmp[1] = (`in` shr 48) and 0x000000FF
  tmp[2] = (`in` shr 40) and 0x000000FF
  tmp[3] = (`in` shr 32) and 0x000000FF
  tmp[4] = (`in` shr 24) and 0x000000FF
  tmp[5] = (`in` shr 16) and 0x000000FF
  tmp[6] = (`in` shr 8) and 0x000000FF
  tmp[7] = `in` and 0x000000FF
