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
##    Copyright (C) 2008-2012 Daisuke Aoyama <aoyama@peach.ne.jp>.
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
##  Configuration file parser
## 

type
  spdk_conf_value* = object
    next*: ptr spdk_conf_value
    value*: cstring

  spdk_conf_item* = object
    next*: ptr spdk_conf_item
    key*: cstring
    val*: ptr spdk_conf_value

  spdk_conf_section* = object
    next*: ptr spdk_conf_section
    name*: cstring
    num*: cint
    item*: ptr spdk_conf_item

  spdk_conf* = object
    file*: cstring
    current_section*: ptr spdk_conf_section
    section*: ptr spdk_conf_section


proc spdk_conf_allocate*(): ptr spdk_conf {.cdecl, importc: "spdk_conf_allocate",
                                        dynlib: libspdk.}
proc spdk_conf_free*(cp: ptr spdk_conf) {.cdecl, importc: "spdk_conf_free",
                                      dynlib: libspdk.}
proc spdk_conf_read*(cp: ptr spdk_conf; file: cstring): cint {.cdecl,
    importc: "spdk_conf_read", dynlib: libspdk.}
proc spdk_conf_find_section*(cp: ptr spdk_conf; name: cstring): ptr spdk_conf_section {.
    cdecl, importc: "spdk_conf_find_section", dynlib: libspdk.}
##  Configuration file iteration

proc spdk_conf_first_section*(cp: ptr spdk_conf): ptr spdk_conf_section {.cdecl,
    importc: "spdk_conf_first_section", dynlib: libspdk.}
proc spdk_conf_next_section*(sp: ptr spdk_conf_section): ptr spdk_conf_section {.
    cdecl, importc: "spdk_conf_next_section", dynlib: libspdk.}
proc spdk_conf_section_match_prefix*(sp: ptr spdk_conf_section; name_prefix: cstring): bool {.
    cdecl, importc: "spdk_conf_section_match_prefix", dynlib: libspdk.}
proc spdk_conf_section_get_nmval*(sp: ptr spdk_conf_section; key: cstring; idx1: cint;
                                 idx2: cint): cstring {.cdecl,
    importc: "spdk_conf_section_get_nmval", dynlib: libspdk.}
proc spdk_conf_section_get_nval*(sp: ptr spdk_conf_section; key: cstring; idx: cint): cstring {.
    cdecl, importc: "spdk_conf_section_get_nval", dynlib: libspdk.}
proc spdk_conf_section_get_val*(sp: ptr spdk_conf_section; key: cstring): cstring {.
    cdecl, importc: "spdk_conf_section_get_val", dynlib: libspdk.}
proc spdk_conf_section_get_intval*(sp: ptr spdk_conf_section; key: cstring): cint {.
    cdecl, importc: "spdk_conf_section_get_intval", dynlib: libspdk.}
proc spdk_conf_set_as_default*(cp: ptr spdk_conf) {.cdecl,
    importc: "spdk_conf_set_as_default", dynlib: libspdk.}