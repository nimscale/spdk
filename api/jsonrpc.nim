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
##  JSON-RPC 2.0 server implementation
##

import json

const
  SPDK_JSONRPC_ERROR_PARSE_ERROR* = - 32700
  SPDK_JSONRPC_ERROR_INVALID_REQUEST* = - 32600
  SPDK_JSONRPC_ERROR_METHOD_NOT_FOUND* = - 32601
  SPDK_JSONRPC_ERROR_INVALID_PARAMS* = - 32602
  SPDK_JSONRPC_ERROR_INTERNAL_ERROR* = - 32603

type
  sockaddr {.importc: "struct sockaddr".} = object

type
  spdk_jsonrpc_server* = object

  spdk_jsonrpc_server_conn* = object


## *
##  User callback to handle a single JSON-RPC request.
##
##  The user should respond by calling one of spdk_jsonrpc_begin_result() or
##   spdk_jsonrpc_send_error_response().
##

type
  spdk_jsonrpc_handle_request_fn* = proc (conn: ptr spdk_jsonrpc_server_conn;
                                       `method`: ptr spdk_json_val;
                                       params: ptr spdk_json_val;
                                       id: ptr spdk_json_val) {.cdecl.}

proc spdk_jsonrpc_server_listen*(listen_addr: ptr sockaddr; addrlen: uint32; # socklen_t --> uint32
                                handle_request: spdk_jsonrpc_handle_request_fn): ptr spdk_jsonrpc_server {.
    cdecl, importc: "spdk_jsonrpc_server_listen", dynlib: libspdk.}
proc spdk_jsonrpc_server_poll*(server: ptr spdk_jsonrpc_server): cint {.cdecl,
    importc: "spdk_jsonrpc_server_poll", dynlib: libspdk.}
proc spdk_jsonrpc_server_shutdown*(server: ptr spdk_jsonrpc_server) {.cdecl,
    importc: "spdk_jsonrpc_server_shutdown", dynlib: libspdk.}
proc spdk_jsonrpc_begin_result*(conn: ptr spdk_jsonrpc_server_conn;
                               id: ptr spdk_json_val): ptr spdk_json_write_ctx {.
    cdecl, importc: "spdk_jsonrpc_begin_result", dynlib: libspdk.}
proc spdk_jsonrpc_end_result*(conn: ptr spdk_jsonrpc_server_conn;
                             w: ptr spdk_json_write_ctx) {.cdecl,
    importc: "spdk_jsonrpc_end_result", dynlib: libspdk.}
proc spdk_jsonrpc_send_error_response*(conn: ptr spdk_jsonrpc_server_conn;
                                      id: ptr spdk_json_val; error_code: cint;
                                      msg: cstring) {.cdecl,
    importc: "spdk_jsonrpc_send_error_response", dynlib: libspdk.}
