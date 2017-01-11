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
##  Net framework abstraction layer
##

type
  iovec {.importc: "struct iovec", final.} = object

const
  IDLE_INTERVAL_TIME_IN_US* = 5000

proc spdk_net_framework_get_name*(): cstring {.cdecl,
    importc: "spdk_net_framework_get_name", dynlib: libspdk.}
proc spdk_net_framework_start*(): cint {.cdecl, importc: "spdk_net_framework_start",
                                      dynlib: libspdk.}
proc spdk_net_framework_clear_socket_association*(sock: cint) {.cdecl,
    importc: "spdk_net_framework_clear_socket_association", dynlib: libspdk.}
proc spdk_net_framework_fini*(): cint {.cdecl, importc: "spdk_net_framework_fini",
                                     dynlib: libspdk.}
proc spdk_net_framework_idle_time*(): cint {.cdecl,
    importc: "spdk_net_framework_idle_time", dynlib: libspdk.}
const
  SPDK_IFNAMSIZE* = 32
  SPDK_MAX_IP_PER_IFC* = 32

type
  INNER_C_STRUCT_457965563* = object
    tqe_next*: ptr spdk_interface ##  next element
    tqe_prev*: ptr ptr spdk_interface ##  address of previous next element

  spdk_interface* = object
    name*: array[SPDK_IFNAMSIZE, char]
    index*: uint32
    num_ip_addresses*: uint32  ##  number of IP addresses defined
    ip_address*: array[SPDK_MAX_IP_PER_IFC, uint32] ## TBD:	TAILQ_ENTRY(spdk_interface)	tailq;
    tailq*: INNER_C_STRUCT_457965563


proc spdk_interface_add_ip_address*(ifc_index: cint; ip_addr: cstring): cint {.cdecl,
    importc: "spdk_interface_add_ip_address", dynlib: libspdk.}
proc spdk_interface_delete_ip_address*(ifc_index: cint; ip_addr: cstring): cint {.
    cdecl, importc: "spdk_interface_delete_ip_address", dynlib: libspdk.}
proc spdk_interface_get_list*(): pointer {.cdecl,
                                        importc: "spdk_interface_get_list",
                                        dynlib: libspdk.}
proc spdk_sock_getaddr*(sock: cint; saddr: cstring; slen: cint; caddr: cstring;
                       clen: cint): cint {.cdecl, importc: "spdk_sock_getaddr",
                                        dynlib: libspdk.}
proc spdk_sock_connect*(ip: cstring; port: cint): cint {.cdecl,
    importc: "spdk_sock_connect", dynlib: libspdk.}
proc spdk_sock_listen*(ip: cstring; port: cint): cint {.cdecl,
    importc: "spdk_sock_listen", dynlib: libspdk.}
proc spdk_sock_accept*(sock: cint): cint {.cdecl, importc: "spdk_sock_accept",
                                       dynlib: libspdk.}
proc spdk_sock_close*(sock: cint): cint {.cdecl, importc: "spdk_sock_close",
                                      dynlib: libspdk.}
proc spdk_sock_recv*(sock: cint; buf: pointer; len: csize): csize {.cdecl,
    importc: "spdk_sock_recv", dynlib: libspdk.}
proc spdk_sock_writev*(sock: cint; iov: ptr iovec; iovcnt: cint): csize {.cdecl,
    importc: "spdk_sock_writev", dynlib: libspdk.}
proc spdk_sock_set_recvlowat*(sock: cint; nbytes: cint): cint {.cdecl,
    importc: "spdk_sock_set_recvlowat", dynlib: libspdk.}
proc spdk_sock_set_recvbuf*(sock: cint; sz: cint): cint {.cdecl,
    importc: "spdk_sock_set_recvbuf", dynlib: libspdk.}
proc spdk_sock_set_sendbuf*(sock: cint; sz: cint): cint {.cdecl,
    importc: "spdk_sock_set_sendbuf", dynlib: libspdk.}
proc spdk_sock_is_ipv6*(sock: cint): bool {.cdecl, importc: "spdk_sock_is_ipv6",
                                        dynlib: libspdk.}
proc spdk_sock_is_ipv4*(sock: cint): bool {.cdecl, importc: "spdk_sock_is_ipv4",
                                        dynlib: libspdk.}
