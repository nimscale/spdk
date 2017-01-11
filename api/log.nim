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
##  Logging interfaces
## 

## 
##  Default: 1 - noticelog messages will print to stderr and syslog.
##  Can be set to 0 to print noticelog messages to syslog only.
## 

var spdk_g_notice_stderr_flag* {.importc: "spdk_g_notice_stderr_flag",
                               dynlib: libspdk.}: cuint

## rivasiv : we will need that to be used directly
## #define SPDK_NOTICELOG(...) \
## 	spdk_noticelog(NULL, 0, NULL, __VA_ARGS__)
## #define SPDK_WARNLOG(...) \
## 	spdk_warnlog(NULL, 0, NULL, __VA_ARGS__)
## #define SPDK_ERRLOG(...) \
## 	spdk_errlog(__FILE__, __LINE__, __func__, __VA_ARGS__)
## 
## #ifdef DEBUG
## #define SPDK_LOG_REGISTER_TRACE_FLAG(str, flag) \
## bool flag = false; \
## __attribute__((constructor)) static void register_trace_flag_##flag(void) \
## { \
## 	spdk_log_register_trace_flag(str, &flag); \
## }
## 
## #define SPDK_TRACELOG(FLAG, ...)							\
## 	do {										\
## 		extern bool FLAG;							\
## 		if (FLAG) {								\
## 			spdk_tracelog(__FILE__, __LINE__, __func__, __VA_ARGS__);	\
## 		}									\
## 	} while (0)
## 
## #define SPDK_TRACEDUMP(FLAG, LABEL, BUF, LEN)						\
## 	do {										\
## 		extern bool FLAG;							\
## 		if (FLAG) {								\
## 			spdk_trace_dump((LABEL), (BUF), (LEN));				\
## 		}									\
## 	} while (0)
## 
## #else
## #define SPDK_LOG_REGISTER_TRACE_FLAG(str, flag)
## #define SPDK_TRACELOG(...) do { } while (0)
## #define SPDK_TRACEDUMP(...) do { } while (0)
## #endif
## 
## __attribute__ are not supported by nim

proc spdk_set_log_facility*(facility: cstring): cint {.cdecl,
    importc: "spdk_set_log_facility", dynlib: libspdk.}
proc spdk_set_log_priority*(priority: cstring): cint {.cdecl,
    importc: "spdk_set_log_priority", dynlib: libspdk.}
proc spdk_noticelog*(file: cstring; line: cint; `func`: cstring; format: cstring) {.
    varargs, cdecl, importc: "spdk_noticelog", dynlib: libspdk.}
  ##  __attribute__((__format__(__printf__, 4, 5)))
proc spdk_warnlog*(file: cstring; line: cint; `func`: cstring; format: cstring) {.
    varargs, cdecl, importc: "spdk_warnlog", dynlib: libspdk.}
  ##  __attribute__((__format__(__printf__, 4, 5)))
proc spdk_tracelog*(file: cstring; line: cint; `func`: cstring; format: cstring) {.
    varargs, cdecl, importc: "spdk_tracelog", dynlib: libspdk.}
  ## __attribute__((__format__(__printf__, 4, 5)))
proc spdk_errlog*(file: cstring; line: cint; `func`: cstring; format: cstring) {.varargs,
    cdecl, importc: "spdk_errlog", dynlib: libspdk.}
  ## __attribute__((__format__(__printf__, 4, 5)))
proc spdk_trace_dump*(label: cstring; buf: ptr uint8; len: csize) {.cdecl,
    importc: "spdk_trace_dump", dynlib: libspdk.}
proc spdk_log_register_trace_flag*(name: cstring; enabled: ptr bool) {.cdecl,
    importc: "spdk_log_register_trace_flag", dynlib: libspdk.}
proc spdk_log_get_trace_flag*(flag: cstring): bool {.cdecl,
    importc: "spdk_log_get_trace_flag", dynlib: libspdk.}
proc spdk_log_set_trace_flag*(flag: cstring): cint {.cdecl,
    importc: "spdk_log_set_trace_flag", dynlib: libspdk.}
proc spdk_log_clear_trace_flag*(flag: cstring): cint {.cdecl,
    importc: "spdk_log_clear_trace_flag", dynlib: libspdk.}
proc spdk_log_get_num_trace_flags*(): csize {.cdecl,
    importc: "spdk_log_get_num_trace_flags", dynlib: libspdk.}
proc spdk_log_get_trace_flag_name*(idx: csize): cstring {.cdecl,
    importc: "spdk_log_get_trace_flag_name", dynlib: libspdk.}
proc spdk_open_log*() {.cdecl, importc: "spdk_open_log", dynlib: libspdk.}
proc spdk_close_log*() {.cdecl, importc: "spdk_close_log", dynlib: libspdk.}