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
##  PCI driver abstraction layer
## 

type
  spdk_pci_device* = object
  

proc spdk_pci_enumerate*(enum_cb: proc (enum_ctx: pointer;
                                     pci_dev: ptr spdk_pci_device): cint {.cdecl.};
                        enum_ctx: pointer): cint {.cdecl,
    importc: "spdk_pci_enumerate", dynlib: libspdk.}
proc spdk_pci_device_get_domain*(dev: ptr spdk_pci_device): uint16 {.cdecl,
    importc: "spdk_pci_device_get_domain", dynlib: libspdk.}
proc spdk_pci_device_get_bus*(dev: ptr spdk_pci_device): uint8 {.cdecl,
    importc: "spdk_pci_device_get_bus", dynlib: libspdk.}
proc spdk_pci_device_get_dev*(dev: ptr spdk_pci_device): uint8 {.cdecl,
    importc: "spdk_pci_device_get_dev", dynlib: libspdk.}
proc spdk_pci_device_get_func*(dev: ptr spdk_pci_device): uint8 {.cdecl,
    importc: "spdk_pci_device_get_func", dynlib: libspdk.}
proc spdk_pci_device_get_vendor_id*(dev: ptr spdk_pci_device): uint16 {.cdecl,
    importc: "spdk_pci_device_get_vendor_id", dynlib: libspdk.}
proc spdk_pci_device_get_device_id*(dev: ptr spdk_pci_device): uint16 {.cdecl,
    importc: "spdk_pci_device_get_device_id", dynlib: libspdk.}
proc spdk_pci_device_get_subvendor_id*(dev: ptr spdk_pci_device): uint16 {.cdecl,
    importc: "spdk_pci_device_get_subvendor_id", dynlib: libspdk.}
proc spdk_pci_device_get_subdevice_id*(dev: ptr spdk_pci_device): uint16 {.cdecl,
    importc: "spdk_pci_device_get_subdevice_id", dynlib: libspdk.}
proc spdk_pci_device_get_class*(dev: ptr spdk_pci_device): uint32 {.cdecl,
    importc: "spdk_pci_device_get_class", dynlib: libspdk.}
proc spdk_pci_device_get_device_name*(dev: ptr spdk_pci_device): cstring {.cdecl,
    importc: "spdk_pci_device_get_device_name", dynlib: libspdk.}
proc spdk_pci_device_cfg_read8*(dev: ptr spdk_pci_device; value: ptr uint8;
                               offset: uint32): cint {.cdecl,
    importc: "spdk_pci_device_cfg_read8", dynlib: libspdk.}
proc spdk_pci_device_cfg_write8*(dev: ptr spdk_pci_device; value: uint8;
                                offset: uint32): cint {.cdecl,
    importc: "spdk_pci_device_cfg_write8", dynlib: libspdk.}
proc spdk_pci_device_cfg_read16*(dev: ptr spdk_pci_device; value: ptr uint16;
                                offset: uint32): cint {.cdecl,
    importc: "spdk_pci_device_cfg_read16", dynlib: libspdk.}
proc spdk_pci_device_cfg_write16*(dev: ptr spdk_pci_device; value: uint16;
                                 offset: uint32): cint {.cdecl,
    importc: "spdk_pci_device_cfg_write16", dynlib: libspdk.}
proc spdk_pci_device_cfg_read32*(dev: ptr spdk_pci_device; value: ptr uint32;
                                offset: uint32): cint {.cdecl,
    importc: "spdk_pci_device_cfg_read32", dynlib: libspdk.}
proc spdk_pci_device_cfg_write32*(dev: ptr spdk_pci_device; value: uint32;
                                 offset: uint32): cint {.cdecl,
    importc: "spdk_pci_device_cfg_write32", dynlib: libspdk.}
proc spdk_pci_device_get_serial_number*(dev: ptr spdk_pci_device; sn: cstring;
                                       len: csize): cint {.cdecl,
    importc: "spdk_pci_device_get_serial_number", dynlib: libspdk.}
proc spdk_pci_device_has_non_uio_driver*(dev: ptr spdk_pci_device): cint {.cdecl,
    importc: "spdk_pci_device_has_non_uio_driver", dynlib: libspdk.}
proc spdk_pci_device_unbind_kernel_driver*(dev: ptr spdk_pci_device): cint {.cdecl,
    importc: "spdk_pci_device_unbind_kernel_driver", dynlib: libspdk.}
proc spdk_pci_device_bind_uio_driver*(dev: ptr spdk_pci_device): cint {.cdecl,
    importc: "spdk_pci_device_bind_uio_driver", dynlib: libspdk.}
proc spdk_pci_device_switch_to_uio_driver*(pci_dev: ptr spdk_pci_device): cint {.
    cdecl, importc: "spdk_pci_device_switch_to_uio_driver", dynlib: libspdk.}
proc spdk_pci_device_claim*(dev: ptr spdk_pci_device): cint {.cdecl,
    importc: "spdk_pci_device_claim", dynlib: libspdk.}