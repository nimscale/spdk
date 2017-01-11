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
##  Memory copy offload engine abstraction layer
##

type
  copy_completion_cb* = proc (`ref`: pointer; status: cint) {.cdecl.}
  copy_task* = object
    cb*: copy_completion_cb
    offload_ctx*: array[0, uint8]

  spdk_copy_engine* = object
    copy*: proc (cb_arg: pointer; dst: pointer; src: pointer; nbytes: uint64;
               cb: copy_completion_cb): int64 {.cdecl.}
    check_io*: proc () {.cdecl.}

  INNER_C_STRUCT_976134141* = object
    tqe_next*: ptr spdk_copy_module_if ##  next element
    tqe_prev*: ptr ptr spdk_copy_module_if ##  address of previous next element

  spdk_copy_module_if* = object
    module_init*: proc (): cint {.cdecl.} ## * Initialization function for the module.  Called by the spdk
                                     ##    application during startup.
                                     ##
                                     ##   Modules are required to define this function.
                                     ##
    ## * Finish function for the module.  Called by the spdk application
    ##    before the spdk application exits to perform any necessary cleanup.
    ##
    ##   Modules are not required to define this function.
    ##
    module_fini*: proc () {.cdecl.} ## * Function called to return a text string representing the
                                ##    module's configuration options for inclusion in an
                                ##    spdk configuration file.
                                ##
    config_text*: proc (fp: ptr FILE) {.cdecl.}
    get_ctx_size*: proc (): cint {.cdecl.} ## 	TAILQ_ENTRY(spdk_copy_module_if)	tailq;
    tailq*: INNER_C_STRUCT_976134141


proc spdk_copy_engine_register*(copy_engine: ptr spdk_copy_engine) {.cdecl,
    importc: "spdk_copy_engine_register", dynlib: libspdk.}
proc spdk_copy_submit*(copy_req: ptr copy_task; dst: pointer; src: pointer;
                      nbytes: uint64; cb: copy_completion_cb): int64 {.cdecl,
    importc: "spdk_copy_submit", dynlib: libspdk.}
proc spdk_copy_check_io*(): cint {.cdecl, importc: "spdk_copy_check_io",
                                dynlib: libspdk.}
proc spdk_copy_module_get_max_ctx_size*(): cint {.cdecl,
    importc: "spdk_copy_module_get_max_ctx_size", dynlib: libspdk.}
proc spdk_copy_module_list_add*(copy_module: ptr spdk_copy_module_if) {.cdecl,
    importc: "spdk_copy_module_list_add", dynlib: libspdk.}
## TBD need to be ported manually.
## #define SPDK_COPY_MODULE_REGISTER(init_fn, fini_fn, config_fn, ctx_size_fn)				\
## 	static struct spdk_copy_module_if init_fn ## _if = {						\
## 	.module_init 	= init_fn,									\
## 	.module_fini	= fini_fn,									\
## 	.config_text	= config_fn,									\
## 	.get_ctx_size	= ctx_size_fn,                                					\
## 	};  												\
## 	__attribute__((constructor)) static void init_fn ## _init(void)  				\
## 	{                                                           					\
## 	    spdk_copy_module_list_add(&init_fn ## _if);                  				\
## 	}
##
