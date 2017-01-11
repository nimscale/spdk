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
##  Tracepoint library
##

const
  SPDK_TRACE_SIZE* = (32 * 1024)

const
  UCHAR_MAX = 255

type
  spdk_trace_entry* = object
    tsc*: uint64
    tpoint_id*: uint16
    poller_id*: uint16
    size*: uint32
    object_id*: uint64
    arg1*: uint64


##  If type changes from a uint8_t, change this value.

const
  SPDK_TRACE_MAX_OWNER* = (UCHAR_MAX + 1)

type
  spdk_trace_owner* = object
    `type`*: uint8
    id_prefix*: char


##  If type changes from a uint8_t, change this value.

const
  SPDK_TRACE_MAX_OBJECT* = (UCHAR_MAX + 1)

type
  spdk_trace_object* = object
    `type`*: uint8
    id_prefix*: char


const
  SPDK_TRACE_MAX_GROUP_ID* = 16
  SPDK_TRACE_MAX_TPOINT_ID* = (SPDK_TRACE_MAX_GROUP_ID * 64)

template SPDK_TPOINT_ID*(group, tpoint: untyped): untyped =
  ((group * 64) + tpoint)

type
  spdk_trace_tpoint* = object
    name*: array[24, char]
    short_name*: array[4, char]
    tpoint_id*: uint16
    owner_type*: uint8
    object_type*: uint8
    new_object*: uint8
    arg1_is_ptr*: uint8
    arg1_is_alias*: uint8
    arg1_name*: array[8, char]

  spdk_trace_history* = object
    lcore*: cint               ## * Logical core number associated with this structure instance.
    ## *
    ##  Circular buffer of spdk_trace_entry structures for tracing
    ##   tpoints on this core.  Debug tool spdk_trace reads this
    ##   buffer from shared memory to post-process the tpoint entries and
    ##   display in a human-readable format.
    ##
    entries*: array[SPDK_TRACE_SIZE, spdk_trace_entry] ## *
                                                    ##  Running count of number of occurrences of each tracepoint on this
                                                    ##   lcore.  Debug tools can use this to easily count tracepoints such as
                                                    ##   number of SCSI tasks completed or PDUs read.
                                                    ##
    tpoint_count*: array[SPDK_TRACE_MAX_TPOINT_ID, uint64] ## * Index to next spdk_trace_entry to fill in the circular buffer.
    next_entry*: uint32


const
  SPDK_TRACE_MAX_LCORE* = 128

type
  spdk_trace_histories* = object
    tsc_rate*: uint64
    tpoint_mask*: array[SPDK_TRACE_MAX_GROUP_ID, uint64]
    per_lcore_history*: array[SPDK_TRACE_MAX_LCORE, spdk_trace_history]
    owner*: array[UCHAR_MAX + 1, spdk_trace_owner]
    `object`*: array[UCHAR_MAX + 1, spdk_trace_object]
    tpoint*: array[SPDK_TRACE_MAX_TPOINT_ID, spdk_trace_tpoint]


proc spdk_trace_record*(tpoint_id: uint16; poller_id: uint16; size: uint32;
                       object_id: uint64; arg1: uint64) {.cdecl,
    importc: "spdk_trace_record", dynlib: libspdk.}
## * Returns the current tpoint mask.

proc spdk_trace_get_tpoint_mask*(group_id: uint32): uint64 {.cdecl,
    importc: "spdk_trace_get_tpoint_mask", dynlib: libspdk.}
## * Adds the specified tpoints to the current tpoint mask for the given tpoint group.

proc spdk_trace_set_tpoints*(group_id: uint32; tpoint_mask: uint64) {.cdecl,
    importc: "spdk_trace_set_tpoints", dynlib: libspdk.}
## * Clears the specified tpoints from the current tpoint mask for the given tpoint group.

proc spdk_trace_clear_tpoints*(group_id: uint32; tpoint_mask: uint64) {.cdecl,
    importc: "spdk_trace_clear_tpoints", dynlib: libspdk.}
## * Returns a mask of all tracepoint groups which have at least one tracepoint enabled.

proc spdk_trace_get_tpoint_group_mask*(): uint64 {.cdecl,
    importc: "spdk_trace_get_tpoint_group_mask", dynlib: libspdk.}
## * For each tpoint group specified in the group mask, enable all of its tpoints.

proc spdk_trace_set_tpoint_group_mask*(tpoint_group_mask: uint64) {.cdecl,
    importc: "spdk_trace_set_tpoint_group_mask", dynlib: libspdk.}
proc spdk_trace_init*(shm_name: cstring) {.cdecl, importc: "spdk_trace_init",
                                        dynlib: libspdk.}
proc spdk_trace_cleanup*() {.cdecl, importc: "spdk_trace_cleanup", dynlib: libspdk.}
const
  OWNER_NONE* = 0
  OBJECT_NONE* = 0

proc spdk_trace_register_owner*(`type`: uint8; id_prefix: char) {.cdecl,
    importc: "spdk_trace_register_owner", dynlib: libspdk.}
proc spdk_trace_register_object*(`type`: uint8; id_prefix: char) {.cdecl,
    importc: "spdk_trace_register_object", dynlib: libspdk.}
proc spdk_trace_register_description*(name: cstring; short_name: cstring;
                                     tpoint_id: uint16; owner_type: uint8;
                                     object_type: uint8; new_object: uint8;
                                     arg1_is_ptr: uint8; arg1_is_alias: uint8;
                                     arg1_name: cstring) {.cdecl,
    importc: "spdk_trace_register_description", dynlib: libspdk.}
type
  spdk_trace_register_fn* = object
    reg_fn*: proc () {.cdecl.}
    next*: ptr spdk_trace_register_fn


proc spdk_trace_add_register_fn*(reg_fn: ptr spdk_trace_register_fn) {.cdecl,
    importc: "spdk_trace_add_register_fn", dynlib: libspdk.}
##  metaprograming : TBD: this needed to be done manually in the nim code...
## #define SPDK_TRACE_REGISTER_FN(fn) 				\
## 	static void fn(void);					\
## 	struct spdk_trace_register_fn reg_ ## fn = {		\
## 		.reg_fn = fn,					\
## 		.next = NULL,					\
## 	};							\
## 	__attribute__((constructor)) static void _ ## fn(void)	\
## 	{							\
## 		spdk_trace_add_register_fn(&reg_ ## fn);	\
## 	}							\
## 	static void fn(void)
##
##
##
