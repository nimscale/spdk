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
##  NVMe driver public API
##

import
  pci, nvme_spec

const
  SPDK_NVME_DEFAULT_RETRY_COUNT* = (4)

var spdk_nvme_retry_count* {.importc: "spdk_nvme_retry_count", dynlib: libspdk.}: int32

## * \brief Opaque handle to a controller. Returned by \ref spdk_nvme_probe()'s attach_cb.

type
  spdk_nvme_ctrlr* = object


## *
##  \brief NVMe controller initialization options.
##
##  A pointer to this structure will be provided for each probe callback from spdk_nvme_probe() to
##  allow the user to request non-default options, and the actual options enabled on the controller
##  will be provided during the attach callback.
##

type
  spdk_nvme_ctrlr_opts* = object
    num_io_queues*: uint32 ## *
                         ##  Number of I/O queues to request (used to set Number of Queues feature)
                         ##
    ## *
    ##  Enable submission queue in controller memory buffer
    ##
    use_cmb_sqs*: bool         ## *
                     ##  Type of arbitration mechanism
                     ##
    arb_mechanism*: spdk_nvme_cc_ams


## *
##  Callback for spdk_nvme_probe() enumeration.
##
##  \param opts NVMe controller initialization options.  This structure will be populated with the
##  default values on entry, and the user callback may update any options to request a different
##  value.  The controller may not support all requested parameters, so the final values will be
##  provided during the attach callback.
##  \return true to attach to this device.
##

type
  spdk_nvme_probe_cb* = proc (cb_ctx: pointer; pci_dev: ptr spdk_pci_device;
                           opts: ptr spdk_nvme_ctrlr_opts): bool {.cdecl.}

## *
##  Callback for spdk_nvme_probe() to report a device that has been attached to the userspace NVMe driver.
##
##  \param opts NVMe controller initialization options that were actually used.  Options may differ
##  from the requested options from the probe call depending on what the controller supports.
##

type
  spdk_nvme_attach_cb* = proc (cb_ctx: pointer; pci_dev: ptr spdk_pci_device;
                            ctrlr: ptr spdk_nvme_ctrlr;
                            opts: ptr spdk_nvme_ctrlr_opts) {.cdecl.}

## *
##  Callback for spdk_nvme_probe() to report that a device attached to the userspace NVMe driver
##  has been removed from the system.
##
##  \param ctrlr NVMe controller instance that was removed.
##

type
  spdk_nvme_remove_cb* = proc (cb_ctx: pointer; ctrlr: ptr spdk_nvme_ctrlr) {.cdecl.}

## *
##  \brief Enumerate the NVMe devices attached to the system and attach the userspace NVMe driver
##  to them if desired.
##
##  \param cb_ctx Opaque value which will be passed back in cb_ctx parameter of the callbacks.
##  \param probe_cb will be called once per NVMe device found in the system.
##  \param attach_cb will be called for devices for which probe_cb returned true once that NVMe
##  controller has been attached to the userspace driver.
##  \param remove_cb will be called for devices that were attached in a previous spdk_nvme_probe()
##  call but are no longer attached to the system. Optional; specify NULL if removal notices are not
##  desired.
##
##  If called more than once, only devices that are not already attached to the SPDK NVMe driver
##  will be reported.
##
##  To stop using the the controller and release its associated resources,
##  call \ref spdk_nvme_detach with the spdk_nvme_ctrlr instance returned by this function.
##

proc spdk_nvme_probe*(cb_ctx: pointer; probe_cb: spdk_nvme_probe_cb;
                     attach_cb: spdk_nvme_attach_cb;
                     remove_cb: spdk_nvme_remove_cb): cint {.cdecl,
    importc: "spdk_nvme_probe", dynlib: libspdk.}
## *
##  \brief Detaches specified device returned by \ref spdk_nvme_probe()'s attach_cb from the NVMe driver.
##
##  On success, the spdk_nvme_ctrlr handle is no longer valid.
##
##  This function should be called from a single thread while no other threads
##  are actively using the NVMe device.
##
##

proc spdk_nvme_detach*(ctrlr: ptr spdk_nvme_ctrlr): cint {.cdecl,
    importc: "spdk_nvme_detach", dynlib: libspdk.}
## *
##  \brief Perform a full hardware reset of the NVMe controller.
##
##  This function should be called from a single thread while no other threads
##  are actively using the NVMe device.
##
##  Any pointers returned from spdk_nvme_ctrlr_get_ns() and spdk_nvme_ns_get_data() may be invalidated
##  by calling this function.  The number of namespaces as returned by spdk_nvme_ctrlr_get_num_ns() may
##  also change.
##

proc spdk_nvme_ctrlr_reset*(ctrlr: ptr spdk_nvme_ctrlr): cint {.cdecl,
    importc: "spdk_nvme_ctrlr_reset", dynlib: libspdk.}
## *
##  \brief Get the identify controller data as defined by the NVMe specification.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##

proc spdk_nvme_ctrlr_get_data*(ctrlr: ptr spdk_nvme_ctrlr): ptr spdk_nvme_ctrlr_data {.
    cdecl, importc: "spdk_nvme_ctrlr_get_data", dynlib: libspdk.}
## *
##  \brief Get the NVMe controller CAP (Capabilities) register.
##

proc spdk_nvme_ctrlr_get_regs_cap*(ctrlr: ptr spdk_nvme_ctrlr): spdk_nvme_cap_register {.
    cdecl, importc: "spdk_nvme_ctrlr_get_regs_cap", dynlib: libspdk.}
## *
##  \brief Get the NVMe controller VS (Version) register.
##

proc spdk_nvme_ctrlr_get_regs_vs*(ctrlr: ptr spdk_nvme_ctrlr): spdk_nvme_vs_register {.
    cdecl, importc: "spdk_nvme_ctrlr_get_regs_vs", dynlib: libspdk.}
## *
##  \brief Get the number of namespaces for the given NVMe controller.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##  This is equivalent to calling spdk_nvme_ctrlr_get_data() to get the
##  spdk_nvme_ctrlr_data and then reading the nn field.
##
##

proc spdk_nvme_ctrlr_get_num_ns*(ctrlr: ptr spdk_nvme_ctrlr): uint32 {.cdecl,
    importc: "spdk_nvme_ctrlr_get_num_ns", dynlib: libspdk.}
## *
##  \brief Determine if a particular log page is supported by the given NVMe controller.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##  \sa spdk_nvme_ctrlr_cmd_get_log_page()
##

proc spdk_nvme_ctrlr_is_log_page_supported*(ctrlr: ptr spdk_nvme_ctrlr;
    log_page: uint8): bool {.cdecl,
                          importc: "spdk_nvme_ctrlr_is_log_page_supported",
                          dynlib: libspdk.}
## *
##  \brief Determine if a particular feature is supported by the given NVMe controller.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##  \sa spdk_nvme_ctrlr_cmd_get_feature()
##

proc spdk_nvme_ctrlr_is_feature_supported*(ctrlr: ptr spdk_nvme_ctrlr;
    feature_code: uint8): bool {.cdecl,
                              importc: "spdk_nvme_ctrlr_is_feature_supported",
                              dynlib: libspdk.}
## *
##  Signature for callback function invoked when a command is completed.
##
##  The spdk_nvme_cpl parameter contains the completion status.
##

type
  spdk_nvme_cmd_cb* = proc (a2: pointer; a3: ptr spdk_nvme_cpl) {.cdecl.}

## *
##  Signature for callback function invoked when an asynchronous error
##   request command is completed.
##
##  The aer_cb_arg parameter is set to the context specified by
##   spdk_nvme_register_aer_callback().
##  The spdk_nvme_cpl parameter contains the completion status of the
##   asynchronous event request that was completed.
##

type
  spdk_nvme_aer_cb* = proc (aer_cb_arg: pointer; a3: ptr spdk_nvme_cpl) {.cdecl.}

proc spdk_nvme_ctrlr_register_aer_callback*(ctrlr: ptr spdk_nvme_ctrlr;
    aer_cb_fn: spdk_nvme_aer_cb; aer_cb_arg: pointer) {.cdecl,
    importc: "spdk_nvme_ctrlr_register_aer_callback", dynlib: libspdk.}
## *
##  \brief Opaque handle to a queue pair.
##
##  I/O queue pairs may be allocated using spdk_nvme_ctrlr_alloc_io_qpair().
##

type
  spdk_nvme_qpair* = object


## *
##  \brief Allocate an I/O queue pair (submission and completion queue).
##
##  Each queue pair should only be used from a single thread at a time (mutual exclusion must be
##  enforced by the user).
##
##  \param ctrlr NVMe controller for which to allocate the I/O queue pair.
##  \param qprio Queue priority for weighted round robin arbitration.  If a different arbitration
##  method is in use, pass 0.
##

proc spdk_nvme_ctrlr_alloc_io_qpair*(ctrlr: ptr spdk_nvme_ctrlr;
                                    qprio: spdk_nvme_qprio): ptr spdk_nvme_qpair {.
    cdecl, importc: "spdk_nvme_ctrlr_alloc_io_qpair", dynlib: libspdk.}
## *
##  \brief Free an I/O queue pair that was allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##

proc spdk_nvme_ctrlr_free_io_qpair*(qpair: ptr spdk_nvme_qpair): cint {.cdecl,
    importc: "spdk_nvme_ctrlr_free_io_qpair", dynlib: libspdk.}
## *
##  \brief Send the given NVM I/O command to the NVMe controller.
##
##  This is a low level interface for submitting I/O commands directly. Prefer
##  the spdk_nvme_ns_cmd_* functions instead. The validity of the command will
##  not be checked!
##
##  When constructing the nvme_command it is not necessary to fill out the PRP
##  list/SGL or the CID. The driver will handle both of those for you.
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ctrlr_cmd_io_raw*(ctrlr: ptr spdk_nvme_ctrlr;
                                qpair: ptr spdk_nvme_qpair; cmd: ptr spdk_nvme_cmd;
                                buf: pointer; len: uint32; cb_fn: spdk_nvme_cmd_cb;
                                cb_arg: pointer): cint {.cdecl,
    importc: "spdk_nvme_ctrlr_cmd_io_raw", dynlib: libspdk.}
## *
##  \brief Process any outstanding completions for I/O submitted on a queue pair.
##
##  This call is non-blocking, i.e. it only
##  processes completions that are ready at the time of this function call. It does not
##  wait for outstanding commands to finish.
##
##  For each completed command, the request's callback function will
##   be called if specified as non-NULL when the request was submitted.
##
##  \param qpair Queue pair to check for completions.
##  \param max_completions Limit the number of completions to be processed in one call, or 0
##  for unlimited.
##
##  \return Number of completions processed (may be 0) or negative on error.
##
##  \sa spdk_nvme_cmd_cb
##
##  This function may be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##  The caller must ensure that each queue pair is only used from one thread at a time.
##

proc spdk_nvme_qpair_process_completions*(qpair: ptr spdk_nvme_qpair;
    max_completions: uint32): int32 {.cdecl, importc: "spdk_nvme_qpair_process_completions",
                                   dynlib: libspdk.}
## *
##  \brief Send the given admin command to the NVMe controller.
##
##  This is a low level interface for submitting admin commands directly. Prefer
##  the spdk_nvme_ctrlr_cmd_* functions instead. The validity of the command will
##  not be checked!
##
##  When constructing the nvme_command it is not necessary to fill out the PRP
##  list/SGL or the CID. The driver will handle both of those for you.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##  Call \ref spdk_nvme_ctrlr_process_admin_completions() to poll for completion
##  of commands submitted through this function.
##

proc spdk_nvme_ctrlr_cmd_admin_raw*(ctrlr: ptr spdk_nvme_ctrlr;
                                   cmd: ptr spdk_nvme_cmd; buf: pointer; len: uint32;
                                   cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer): cint {.
    cdecl, importc: "spdk_nvme_ctrlr_cmd_admin_raw", dynlib: libspdk.}
## *
##  \brief Process any outstanding completions for admin commands.
##
##  This will process completions for admin commands submitted on any thread.
##
##  This call is non-blocking, i.e. it only processes completions that are ready
##  at the time of this function call. It does not wait for outstanding commands to
##  finish.
##
##  \return Number of completions processed (may be 0) or negative on error.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ctrlr_process_admin_completions*(ctrlr: ptr spdk_nvme_ctrlr): int32 {.
    cdecl, importc: "spdk_nvme_ctrlr_process_admin_completions", dynlib: libspdk.}
## * \brief Opaque handle to a namespace. Obtained by calling spdk_nvme_ctrlr_get_ns().

type
  spdk_nvme_ns* = object


## *
##  \brief Get a handle to a namespace for the given controller.
##
##  Namespaces are numbered from 1 to the total number of namespaces. There will never
##  be any gaps in the numbering. The number of namespaces is obtained by calling
##  spdk_nvme_ctrlr_get_num_ns().
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ctrlr_get_ns*(ctrlr: ptr spdk_nvme_ctrlr; ns_id: uint32): ptr spdk_nvme_ns {.
    cdecl, importc: "spdk_nvme_ctrlr_get_ns", dynlib: libspdk.}
## *
##  \brief Get a specific log page from the NVMe controller.
##
##  \param ctrlr NVMe controller to query.
##  \param log_page The log page identifier.
##  \param nsid Depending on the log page, this may be 0, a namespace identifier, or SPDK_NVME_GLOBAL_NS_TAG.
##  \param payload The pointer to the payload buffer.
##  \param payload_size The size of payload buffer.
##  \param cb_fn Callback function to invoke when the log page has been retrieved.
##  \param cb_arg Argument to pass to the callback function.
##
##  \return 0 if successfully submitted, ENOMEM if resources could not be allocated for this request
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##  Call \ref spdk_nvme_ctrlr_process_admin_completions() to poll for completion
##  of commands submitted through this function.
##
##  \sa spdk_nvme_ctrlr_is_log_page_supported()
##

proc spdk_nvme_ctrlr_cmd_get_log_page*(ctrlr: ptr spdk_nvme_ctrlr; log_page: uint8;
                                      nsid: uint32; payload: pointer;
                                      payload_size: uint32;
                                      cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer): cint {.
    cdecl, importc: "spdk_nvme_ctrlr_cmd_get_log_page", dynlib: libspdk.}
## *
##  \brief Set specific feature for the given NVMe controller.
##
##  \param ctrlr NVMe controller to manipulate.
##  \param feature The feature identifier.
##  \param cdw11 as defined by the specification for this command.
##  \param cdw12 as defined by the specification for this command.
##  \param payload The pointer to the payload buffer.
##  \param payload_size The size of payload buffer.
##  \param cb_fn Callback function to invoke when the feature has been set.
##  \param cb_arg Argument to pass to the callback function.
##
##  \return 0 if successfully submitted, ENOMEM if resources could not be allocated for this request
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##  Call \ref spdk_nvme_ctrlr_process_admin_completions() to poll for completion
##  of commands submitted through this function.
##
##  \sa spdk_nvme_ctrlr_cmd_get_feature()
##

proc spdk_nvme_ctrlr_cmd_set_feature*(ctrlr: ptr spdk_nvme_ctrlr; feature: uint8;
                                     cdw11: uint32; cdw12: uint32; payload: pointer;
                                     payload_size: uint32;
                                     cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer): cint {.
    cdecl, importc: "spdk_nvme_ctrlr_cmd_set_feature", dynlib: libspdk.}
## *
##  \brief Get specific feature from given NVMe controller.
##
##  \param ctrlr NVMe controller to query.
##  \param feature The feature identifier.
##  \param cdw11 as defined by the specification for this command.
##  \param payload The pointer to the payload buffer.
##  \param payload_size The size of payload buffer.
##  \param cb_fn Callback function to invoke when the feature has been retrieved.
##  \param cb_arg Argument to pass to the callback function.
##
##  \return 0 if successfully submitted, ENOMEM if resources could not be allocated for this request
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##
##  Call \ref spdk_nvme_ctrlr_process_admin_completions() to poll for completion
##  of commands submitted through this function.
##
##  \sa spdk_nvme_ctrlr_cmd_set_feature()
##

proc spdk_nvme_ctrlr_cmd_get_feature*(ctrlr: ptr spdk_nvme_ctrlr; feature: uint8;
                                     cdw11: uint32; payload: pointer;
                                     payload_size: uint32;
                                     cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer): cint {.
    cdecl, importc: "spdk_nvme_ctrlr_cmd_get_feature", dynlib: libspdk.}
## *
##  \brief Attach the specified namespace to controllers.
##
##  \param ctrlr NVMe controller to use for command submission.
##  \param nsid Namespace identifier for namespace to attach.
##  \param payload The pointer to the controller list.
##
##  \return 0 if successfully submitted, ENOMEM if resources could not be allocated for this request
##
##  This function is thread safe and can be called at any point after spdk_nvme_attach().
##
##  Call \ref spdk_nvme_ctrlr_process_admin_completions() to poll for completion
##  of commands submitted through this function.
##

proc spdk_nvme_ctrlr_attach_ns*(ctrlr: ptr spdk_nvme_ctrlr; nsid: uint32;
                               payload: ptr spdk_nvme_ctrlr_list): cint {.cdecl,
    importc: "spdk_nvme_ctrlr_attach_ns", dynlib: libspdk.}
## *
##  \brief Detach the specified namespace from controllers.
##
##  \param ctrlr NVMe controller to use for command submission.
##  \param nsid Namespace ID to detach.
##  \param payload The pointer to the controller list.
##
##  \return 0 if successfully submitted, ENOMEM if resources could not be allocated for this request
##
##  This function is thread safe and can be called at any point after spdk_nvme_attach().
##
##  Call \ref spdk_nvme_ctrlr_process_admin_completions() to poll for completion
##  of commands submitted through this function.
##

proc spdk_nvme_ctrlr_detach_ns*(ctrlr: ptr spdk_nvme_ctrlr; nsid: uint32;
                               payload: ptr spdk_nvme_ctrlr_list): cint {.cdecl,
    importc: "spdk_nvme_ctrlr_detach_ns", dynlib: libspdk.}
## *
##  \brief Create a namespace.
##
##  \param ctrlr NVMe controller to create namespace on.
##  \param payload The pointer to the NVMe namespace data.
##
##  \return Namespace ID (>= 1) if successfully created, or 0 if the request failed.
##
##  This function is thread safe and can be called at any point after spdk_nvme_attach().
##

proc spdk_nvme_ctrlr_create_ns*(ctrlr: ptr spdk_nvme_ctrlr;
                               payload: ptr spdk_nvme_ns_data): uint32 {.cdecl,
    importc: "spdk_nvme_ctrlr_create_ns", dynlib: libspdk.}
## *
##  \brief Delete a namespace.
##
##  \param ctrlr NVMe controller to delete namespace from.
##  \param nsid The namespace identifier.
##
##  \return 0 if successfully submitted, ENOMEM if resources could not be allocated for this request
##
##  This function is thread safe and can be called at any point after spdk_nvme_attach().
##
##  Call \ref spdk_nvme_ctrlr_process_admin_completions() to poll for completion
##  of commands submitted through this function.
##

proc spdk_nvme_ctrlr_delete_ns*(ctrlr: ptr spdk_nvme_ctrlr; nsid: uint32): cint {.
    cdecl, importc: "spdk_nvme_ctrlr_delete_ns", dynlib: libspdk.}
## *
##  \brief Format NVM.
##
##  This function requests a low-level format of the media.
##
##  \param ctrlr NVMe controller to format.
##  \param nsid The namespace identifier.  May be SPDK_NVME_GLOBAL_NS_TAG to format all namespaces.
##  \param format The format information for the command.
##
##  \return 0 if successfully submitted, ENOMEM if resources could not be allocated for this request
##
##  This function is thread safe and can be called at any point after spdk_nvme_attach().
##

proc spdk_nvme_ctrlr_format*(ctrlr: ptr spdk_nvme_ctrlr; nsid: uint32;
                            format: ptr spdk_nvme_format): cint {.cdecl,
    importc: "spdk_nvme_ctrlr_format", dynlib: libspdk.}
## *
##  \brief Download a new firmware image.
##
##  \param payload The data buffer for the firmware image.
##  \param size The data size will be downloaded.
##  \param slot The slot that the firmware image will be committed to.
##
##  \return 0 if successfully submitted, ENOMEM if resources could not be allocated for this request,
##  -1 if the size is not multiple of 4.
##
##  This function is thread safe and can be called at any point after spdk_nvme_attach().
##

proc spdk_nvme_ctrlr_update_firmware*(ctrlr: ptr spdk_nvme_ctrlr; payload: pointer;
                                     size: uint32; slot: cint): cint {.cdecl,
    importc: "spdk_nvme_ctrlr_update_firmware", dynlib: libspdk.}
## *
##  \brief Get the identify namespace data as defined by the NVMe specification.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_data*(ns: ptr spdk_nvme_ns): ptr spdk_nvme_ns_data {.cdecl,
    importc: "spdk_nvme_ns_get_data", dynlib: libspdk.}
## *
##  \brief Get the namespace id (index number) from the given namespace handle.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_id*(ns: ptr spdk_nvme_ns): uint32 {.cdecl,
    importc: "spdk_nvme_ns_get_id", dynlib: libspdk.}
## *
##  \brief Determine whether a namespace is active.
##
##  Inactive namespaces cannot be the target of I/O commands.
##

proc spdk_nvme_ns_is_active*(ns: ptr spdk_nvme_ns): bool {.cdecl,
    importc: "spdk_nvme_ns_is_active", dynlib: libspdk.}
## *
##  \brief Get the maximum transfer size, in bytes, for an I/O sent to the given namespace.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_max_io_xfer_size*(ns: ptr spdk_nvme_ns): uint32 {.cdecl,
    importc: "spdk_nvme_ns_get_max_io_xfer_size", dynlib: libspdk.}
## *
##  \brief Get the sector size, in bytes, of the given namespace.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_sector_size*(ns: ptr spdk_nvme_ns): uint32 {.cdecl,
    importc: "spdk_nvme_ns_get_sector_size", dynlib: libspdk.}
## *
##  \brief Get the number of sectors for the given namespace.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_num_sectors*(ns: ptr spdk_nvme_ns): uint64 {.cdecl,
    importc: "spdk_nvme_ns_get_num_sectors", dynlib: libspdk.}
## *
##  \brief Get the size, in bytes, of the given namespace.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_size*(ns: ptr spdk_nvme_ns): uint64 {.cdecl,
    importc: "spdk_nvme_ns_get_size", dynlib: libspdk.}
## *
##  \brief Get the end-to-end data protection information type of the given namespace.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_pi_type*(ns: ptr spdk_nvme_ns): spdk_nvme_pi_type {.cdecl,
    importc: "spdk_nvme_ns_get_pi_type", dynlib: libspdk.}
## *
##  \brief Get the metadata size, in bytes, of the given namespace.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_md_size*(ns: ptr spdk_nvme_ns): uint32 {.cdecl,
    importc: "spdk_nvme_ns_get_md_size", dynlib: libspdk.}
## *
##  \brief True if the namespace can support extended LBA when end-to-end data protection enabled.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_supports_extended_lba*(ns: ptr spdk_nvme_ns): bool {.cdecl,
    importc: "spdk_nvme_ns_supports_extended_lba", dynlib: libspdk.}
## *
##  \brief Namespace command support flags.
##

type
  spdk_nvme_ns_flags* {.size: sizeof(cint).} = enum
    SPDK_NVME_NS_DEALLOCATE_SUPPORTED = 0x00000001, ## *< The deallocate command is supported
    SPDK_NVME_NS_FLUSH_SUPPORTED = 0x00000002, ## *< The flush command is supported
    SPDK_NVME_NS_RESERVATION_SUPPORTED = 0x00000004, ## *< The reservation command is supported
    SPDK_NVME_NS_WRITE_ZEROES_SUPPORTED = 0x00000008, ## *< The write zeroes command is supported
    SPDK_NVME_NS_DPS_PI_SUPPORTED = 0x00000010, ## *< The end-to-end data protection is supported
    SPDK_NVME_NS_EXTENDED_LBA_SUPPORTED = 0x00000020 ## *< The extended lba format is supported,
                                                  ## 							      metadata is transferred as a contiguous
                                                  ## 							      part of the logical block that it is associated with


## *
##  \brief Get the flags for the given namespace.
##
##  See spdk_nvme_ns_flags for the possible flags returned.
##
##  This function is thread safe and can be called at any point while the controller is attached to
##   the SPDK NVMe driver.
##

proc spdk_nvme_ns_get_flags*(ns: ptr spdk_nvme_ns): uint32 {.cdecl,
    importc: "spdk_nvme_ns_get_flags", dynlib: libspdk.}
## *
##  Restart the SGL walk to the specified offset when the command has scattered payloads.
##
##  The cb_arg parameter is the value passed to readv/writev.
##

type
  spdk_nvme_req_reset_sgl_cb* = proc (cb_arg: pointer; offset: uint32) {.cdecl.}

## *
##  Fill out *address and *length with the current SGL entry and advance to the next
##  entry for the next time the callback is invoked.
##
##  The cb_arg parameter is the value passed to readv/writev.
##  The address parameter contains the physical address of this segment.
##  The length parameter contains the length of this physical segment.
##

type
  spdk_nvme_req_next_sge_cb* = proc (cb_arg: pointer; address: ptr uint64;
                                  length: ptr uint32): cint {.cdecl.}

## *
##  \brief Submits a write I/O to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the write I/O
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer to the data payload
##  \param lba starting LBA to write the data
##  \param lba_count length (in sectors) for the write operation
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##  \param io_flags set flags, defined by the SPDK_NVME_IO_FLAGS_* entries
##  			in spdk/nvme_spec.h, for this I/O.
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_write*(ns: ptr spdk_nvme_ns; qpair: ptr spdk_nvme_qpair;
                            payload: pointer; lba: uint64; lba_count: uint32;
                            cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer;
                            io_flags: uint32): cint {.cdecl,
    importc: "spdk_nvme_ns_cmd_write", dynlib: libspdk.}
## *
##  \brief Submits a write I/O to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the write I/O
##  \param qpair I/O queue pair to submit the request
##  \param lba starting LBA to write the data
##  \param lba_count length (in sectors) for the write operation
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##  \param io_flags set flags, defined in nvme_spec.h, for this I/O
##  \param reset_sgl_fn callback function to reset scattered payload
##  \param next_sge_fn callback function to iterate each scattered
##  payload memory segment
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_writev*(ns: ptr spdk_nvme_ns; qpair: ptr spdk_nvme_qpair;
                             lba: uint64; lba_count: uint32;
                             cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer;
                             io_flags: uint32;
                             reset_sgl_fn: spdk_nvme_req_reset_sgl_cb;
                             next_sge_fn: spdk_nvme_req_next_sge_cb): cint {.cdecl,
    importc: "spdk_nvme_ns_cmd_writev", dynlib: libspdk.}
## *
##  \brief Submits a write I/O to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the write I/O
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer to the data payload
##  \param metadata virtual address pointer to the metadata payload, the length
## 	           of metadata is specified by spdk_nvme_ns_get_md_size()
##  \param lba starting LBA to write the data
##  \param lba_count length (in sectors) for the write operation
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##  \param io_flags set flags, defined by the SPDK_NVME_IO_FLAGS_* entries
##  			in spdk/nvme_spec.h, for this I/O.
##  \param apptag_mask application tag mask.
##  \param apptag application tag to use end-to-end protection information.
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_write_with_md*(ns: ptr spdk_nvme_ns;
                                    qpair: ptr spdk_nvme_qpair; payload: pointer;
                                    metadata: pointer; lba: uint64;
                                    lba_count: uint32; cb_fn: spdk_nvme_cmd_cb;
                                    cb_arg: pointer; io_flags: uint32;
                                    apptag_mask: uint16; apptag: uint16): cint {.
    cdecl, importc: "spdk_nvme_ns_cmd_write_with_md", dynlib: libspdk.}
## *
##  \brief Submits a write zeroes I/O to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the write zeroes I/O
##  \param qpair I/O queue pair to submit the request
##  \param lba starting LBA for this command
##  \param lba_count length (in sectors) for the write zero operation
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##  \param io_flags set flags, defined by the SPDK_NVME_IO_FLAGS_* entries
##  			in spdk/nvme_spec.h, for this I/O.
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_write_zeroes*(ns: ptr spdk_nvme_ns;
                                   qpair: ptr spdk_nvme_qpair; lba: uint64;
                                   lba_count: uint32; cb_fn: spdk_nvme_cmd_cb;
                                   cb_arg: pointer; io_flags: uint32): cint {.cdecl,
    importc: "spdk_nvme_ns_cmd_write_zeroes", dynlib: libspdk.}
## *
##  \brief Submits a read I/O to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the read I/O
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer to the data payload
##  \param lba starting LBA to read the data
##  \param lba_count length (in sectors) for the read operation
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##  \param io_flags set flags, defined in nvme_spec.h, for this I/O
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_read*(ns: ptr spdk_nvme_ns; qpair: ptr spdk_nvme_qpair;
                           payload: pointer; lba: uint64; lba_count: uint32;
                           cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer;
                           io_flags: uint32): cint {.cdecl,
    importc: "spdk_nvme_ns_cmd_read", dynlib: libspdk.}
## *
##  \brief Submits a read I/O to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the read I/O
##  \param qpair I/O queue pair to submit the request
##  \param lba starting LBA to read the data
##  \param lba_count length (in sectors) for the read operation
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##  \param io_flags set flags, defined in nvme_spec.h, for this I/O
##  \param reset_sgl_fn callback function to reset scattered payload
##  \param next_sge_fn callback function to iterate each scattered
##  payload memory segment
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_readv*(ns: ptr spdk_nvme_ns; qpair: ptr spdk_nvme_qpair;
                            lba: uint64; lba_count: uint32; cb_fn: spdk_nvme_cmd_cb;
                            cb_arg: pointer; io_flags: uint32;
                            reset_sgl_fn: spdk_nvme_req_reset_sgl_cb;
                            next_sge_fn: spdk_nvme_req_next_sge_cb): cint {.cdecl,
    importc: "spdk_nvme_ns_cmd_readv", dynlib: libspdk.}
## *
##  \brief Submits a read I/O to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the read I/O
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer to the data payload
##  \param metadata virtual address pointer to the metadata payload, the length
## 	           of metadata is specified by spdk_nvme_ns_get_md_size()
##  \param lba starting LBA to read the data
##  \param lba_count length (in sectors) for the read operation
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##  \param io_flags set flags, defined in nvme_spec.h, for this I/O
##  \param apptag_mask application tag mask.
##  \param apptag application tag to use end-to-end protection information.
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_read_with_md*(ns: ptr spdk_nvme_ns;
                                   qpair: ptr spdk_nvme_qpair; payload: pointer;
                                   metadata: pointer; lba: uint64;
                                   lba_count: uint32; cb_fn: spdk_nvme_cmd_cb;
                                   cb_arg: pointer; io_flags: uint32;
                                   apptag_mask: uint16; apptag: uint16): cint {.
    cdecl, importc: "spdk_nvme_ns_cmd_read_with_md", dynlib: libspdk.}
## *
##  \brief Submits a deallocation request to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the deallocation request
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer to the list of LBA ranges to
##                 deallocate
##  \param num_ranges number of ranges in the list pointed to by payload; must be
##                 between 1 and \ref SPDK_NVME_DATASET_MANAGEMENT_MAX_RANGES, inclusive.
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_deallocate*(ns: ptr spdk_nvme_ns; qpair: ptr spdk_nvme_qpair;
                                 payload: pointer; num_ranges: uint16;
                                 cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer): cint {.
    cdecl, importc: "spdk_nvme_ns_cmd_deallocate", dynlib: libspdk.}
## *
##  \brief Submits a flush request to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the flush request
##  \param qpair I/O queue pair to submit the request
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_flush*(ns: ptr spdk_nvme_ns; qpair: ptr spdk_nvme_qpair;
                            cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer): cint {.cdecl,
    importc: "spdk_nvme_ns_cmd_flush", dynlib: libspdk.}
## *
##  \brief Submits a reservation register to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the reservation register request
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer to the reservation register data
##  \param ignore_key '1' the current reservation key check is disabled
##  \param action specifies the registration action
##  \param cptpl change the Persist Through Power Loss state
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_reservation_register*(ns: ptr spdk_nvme_ns;
    qpair: ptr spdk_nvme_qpair; payload: ptr spdk_nvme_reservation_register_data;
    ignore_key: bool; action: spdk_nvme_reservation_register_action;
    cptpl: spdk_nvme_reservation_register_cptpl; cb_fn: spdk_nvme_cmd_cb;
    cb_arg: pointer): cint {.cdecl,
                          importc: "spdk_nvme_ns_cmd_reservation_register",
                          dynlib: libspdk.}
## *
##  \brief Submits a reservation release to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the reservation release request
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer to current reservation key
##  \param ignore_key '1' the current reservation key check is disabled
##  \param action specifies the reservation release action
##  \param type reservation type for the namespace
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_reservation_release*(ns: ptr spdk_nvme_ns;
    qpair: ptr spdk_nvme_qpair; payload: ptr spdk_nvme_reservation_key_data;
    ignore_key: bool; action: spdk_nvme_reservation_release_action;
    `type`: spdk_nvme_reservation_type; cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer): cint {.
    cdecl, importc: "spdk_nvme_ns_cmd_reservation_release", dynlib: libspdk.}
## *
##  \brief Submits a reservation acquire to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the reservation acquire request
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer to reservation acquire data
##  \param ignore_key '1' the current reservation key check is disabled
##  \param action specifies the reservation acquire action
##  \param type reservation type for the namespace
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_reservation_acquire*(ns: ptr spdk_nvme_ns;
    qpair: ptr spdk_nvme_qpair; payload: ptr spdk_nvme_reservation_acquire_data;
    ignore_key: bool; action: spdk_nvme_reservation_acquire_action;
    `type`: spdk_nvme_reservation_type; cb_fn: spdk_nvme_cmd_cb; cb_arg: pointer): cint {.
    cdecl, importc: "spdk_nvme_ns_cmd_reservation_acquire", dynlib: libspdk.}
## *
##  \brief Submits a reservation report to the specified NVMe namespace.
##
##  \param ns NVMe namespace to submit the reservation report request
##  \param qpair I/O queue pair to submit the request
##  \param payload virtual address pointer for reservation status data
##  \param len length bytes for reservation status data structure
##  \param cb_fn callback function to invoke when the I/O is completed
##  \param cb_arg argument to pass to the callback function
##
##  \return 0 if successfully submitted, ENOMEM if an nvme_request
## 	     structure cannot be allocated for the I/O request
##
##  The command is submitted to a qpair allocated by spdk_nvme_ctrlr_alloc_io_qpair().
##  The user must ensure that only one thread submits I/O on a given qpair at any given time.
##

proc spdk_nvme_ns_cmd_reservation_report*(ns: ptr spdk_nvme_ns;
    qpair: ptr spdk_nvme_qpair; payload: pointer; len: uint32; cb_fn: spdk_nvme_cmd_cb;
    cb_arg: pointer): cint {.cdecl, importc: "spdk_nvme_ns_cmd_reservation_report",
                          dynlib: libspdk.}
## *
##  \brief Get the size, in bytes, of an nvme_request.
##
##  This is the size of the request objects that need to be allocated by the
##  nvme_alloc_request macro in nvme_impl.h
##
##  This function is thread safe and can be called at any time.
##

proc spdk_nvme_request_size*(): csize {.cdecl, importc: "spdk_nvme_request_size",
                                     dynlib: libspdk.}
