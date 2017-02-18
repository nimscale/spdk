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
##  Block device abstraction layer
##


## * \page block_backend_modules Block Device Backend Modules
##
## To implement a backend block device driver, a number of functions
## dictated by struct spdk_bdev_fn_table must be provided.
##
## The module should register itself using SPDK_BDEV_MODULE_REGISTER or
## SPDK_VBDEV_MODULE_REGISTER to define the parameters for the module.
##
## Use SPDK_BDEV_MODULE_REGISTER for all block backends that are real disks.
## Any virtual backends such as RAID, partitioning, etc. should use
## SPDK_VBDEV_MODULE_REGISTER.
##
## <hr>
##
## In the module initialization code, the config file sections can be parsed to
## acquire custom configuration parameters. For example, if the config file has
## a section such as below:
## <blockquote><pre>
## [MyBE]
##   MyParam 1234
## </pre></blockquote>
##
## The value can be extracted as the example below:
## <blockquote><pre>
## struct spdk_conf_section \*sp = spdk_conf_find_section(NULL, "MyBe");
## int my_param = spdk_conf_section_get_intval(sp, "MyParam");
## </pre></blockquote>
##
## The backend initialization routine also need to create "disks". A virtual
## representation of each LUN must be constructed. Mainly a struct spdk_bdev
## must be passed to the bdev database via spdk_bdev_register().
##
##
## *
##  \brief SPDK block device.
##
##  This is a virtual representation of a block device that is exported by the backend.
##


import
  event, scsi_spec

const
  SPDK_BDEV_SMALL_RBUF_MAX_SIZE* = 8192
  SPDK_BDEV_LARGE_RBUF_MAX_SIZE* = (64 * 1024)
  SPDK_BDEV_MAX_NAME_LENGTH* = 16
  SPDK_BDEV_MAX_PRODUCT_NAME_LENGTH* = 50

#type
#  spdk_bdev_io* = object

## some magig to get it work
type
  iovec {.importc: "struct iovec", final.} = object

template offsetof(typ, field): expr = (var dummy: typ; cast[uint64](addr(dummy.field)) - cast[uint64](addr(dummy)))

type
  INNER_C_STRUCT_3482877819* = object
    buf_unaligned*: pointer    ## * The unaligned rbuf originally allocated.
    ## * For single buffer cases, pointer to the aligned data buffer.
    buf*: pointer              ## * For single buffer cases, size of the data buffer.
    nbytes*: uint64            ## * Starting offset (in bytes) of the blockdev for this I/O.
    offset*: uint64            ## * Indicate whether the blockdev layer to put rbuf or not.
    put_rbuf*: bool

  INNER_C_STRUCT_18066754* = object
    ## * For basic write case, use our own iovec element
    iov*: iovec
    ## * For SG buffer cases, array of iovecs to transfer.
    iovs*: ptr iovec            ## * For SG buffer cases, number of iovecs in iovec array.
    iovcnt*: cint              ## * For SG buffer cases, total size of data to be transferred.
    len*: csize                ## * Starting offset (in bytes) of the blockdev for this I/O.
    offset*: uint64

  INNER_C_STRUCT_1546195132* = object
    unmap_bdesc*: ptr spdk_scsi_unmap_bdesc ## * Represents the unmap block descriptors.
    ## * Count of unmap block descriptors.
    bdesc_count*: uint16

  INNER_C_STRUCT_3860313206* = object
    offset*: uint64            ## * Represents starting offset in bytes of the range to be flushed.
    ## * Represents the number of bytes to be flushed, starting at offset.
    length*: uint64

  INNER_C_STRUCT_4248869103* = object
    `type`*: int32

  INNER_C_UNION_3458093305* = object {.union.}
    read*: INNER_C_STRUCT_3482877819
    write*: INNER_C_STRUCT_18066754
    unmap*: INNER_C_STRUCT_1546195132
    flush*: INNER_C_STRUCT_3860313206
    reset*: INNER_C_STRUCT_4248869103

  child_io_2984038783* = object
    tqh_first*: ptr spdk_bdev_io ##  first element
    tqh_last*: ptr ptr spdk_bdev_io ##  addr of last next element

  INNER_C_STRUCT_3036483196* = object
    tqe_next*: ptr spdk_bdev_io ##  next element
    tqe_prev*: ptr ptr spdk_bdev_io ##  address of previous next element

  INNER_C_STRUCT_3817070395* = object
    tqe_next*: ptr spdk_bdev_io ##  next element
    tqe_prev*: ptr ptr spdk_bdev_io ##  address of previous next element

  spdk_bdev_io* = object
    ## *
    ##  Block device I/O
    ##
    ##  This is an I/O that is passed to an spdk_bdev.
    ##
    ctx*: pointer              ## * Pointer to scratch area reserved for use by the driver consuming this spdk_bdev_io.
    ## * Generation value for each I/O.
    gencnt*: uint32            ## * The block device that this I/O belongs to.
    bdev*: ptr spdk_bdev        ## * Enumerated value representing the I/O type.
    `type`*: spdk_bdev_io_type
    u*: INNER_C_UNION_3458093305 ## * User function that will be called when this completes
    cb*: spdk_bdev_io_completion_cb ## * Context that will be passed to the completion callback
    caller_ctx*: pointer
    cb_event*: ptr spdk_event   ## * Callback for when rbuf is allocated
    get_rbuf_cb*: spdk_bdev_io_get_rbuf_cb ## * Status for the IO
    status*: spdk_bdev_io_status ## * Used in virtual device (e.g., RAID), indicates its parent spdk_bdev_io *
    parent*: pointer ## * Used in virtual device (e.g., RAID) for storing multiple child device I/Os *
                   ## 	TAILQ_HEAD(child_io, spdk_bdev_io) child_io;
                   ## C@NIM   changed macro to it value
    child_io*: child_io_2984038783 ## * Member used for linking child I/Os together.
                                 ## 	TAILQ_ENTRY(spdk_bdev_io) link;
    link*: INNER_C_STRUCT_3036483196 ## * Number of children for this I/O
    children*: cint            ## * Entry to the list need_buf of struct spdk_bdev.
                  ## 	TAILQ_ENTRY(spdk_bdev_io) rbuf_link;
    rbuf_link*: INNER_C_STRUCT_3817070395 ## * Per I/O context for use by the blockdev module
    driver_ctx*: array[0, uint8] ##  No members may be added after driver_ctx!

  ##
  ##  END of Block device I/O
  ##


  INNER_C_STRUCT_3156946749* = object
    tqe_next*: ptr spdk_bdev    ##  next element
    tqe_prev*: ptr ptr spdk_bdev ##  address of previous next element

  spdk_bdev* = object
    ctxt*: pointer             ## * User context passed in by the backend
    ## * Unique name for this block device.
    name*: array[SPDK_BDEV_MAX_NAME_LENGTH, char] ## * Unique product name for this kind of block device.
    product_name*: array[SPDK_BDEV_MAX_PRODUCT_NAME_LENGTH, char] ## * Size in bytes of a logical block for the backend
    blocklen*: uint32          ## * Number of blocks
    blockcnt*: uint64          ## * write cache enabled, not used at the moment
    write_cache*: cint ## *
                     ##  This is used to make sure buffers are sector aligned.
                     ##  This causes double buffering on writes.
                     ##
    need_aligned_buffer*: cint ## * thin provisioning, not used at the moment
    thin_provisioning*: cint   ## * function table for all LUN ops
    fn_table*: ptr spdk_bdev_fn_table ## * Represents maximum unmap block descriptor count
    max_unmap_bdesc_count*: uint32 ## * array of child block dev that is underneath of the current dev
    child_bdevs*: ptr ptr spdk_bdev ## * number of child blockdevs allocated
    num_child_bdevs*: cint     ## * generation value used by block device reset
    gencnt*: uint32            ## * Whether the poller is registered with the reactor
    is_running*: bool          ## * Poller to submit IO and check completion
    poller*: spdk_poller       ## * True if another blockdev or a LUN is using this device
    claimed*: bool             ## C2NIM Make the macro directly accessible
                 ## 	TAILQ_ENTRY(spdk_bdev) link;
    link*: INNER_C_STRUCT_3156946749

  spdk_bdev_fn_table* = object
    ## *
    ##  Function table for a block device backend.
    ##
    ##  The backend block device function table provides a set of APIs to allow
    ##  communication with a backend. The main commands are read/write API
    ##  calls for I/O via submit_request.
    ##
    destruct*: proc (bdev: ptr spdk_bdev): cint {.cdecl.} ## * Destroy the backend block device object
    ## * Poll the backend for I/O waiting to be completed.
    check_io*: proc (bdev: ptr spdk_bdev): cint {.cdecl.} ## * Process the IO.
    submit_request*: proc (a2: ptr spdk_bdev_io) {.cdecl.} ## * Release buf for read command.
    free_request*: proc (a2: ptr spdk_bdev_io) {.cdecl.}

  ## * Blockdev I/O type
  spdk_bdev_io_type* {.size: sizeof(cint).} = enum
    SPDK_BDEV_IO_TYPE_INVALID, SPDK_BDEV_IO_TYPE_READ, SPDK_BDEV_IO_TYPE_WRITE,
    SPDK_BDEV_IO_TYPE_UNMAP, SPDK_BDEV_IO_TYPE_FLUSH, SPDK_BDEV_IO_TYPE_RESET

  ## * Blockdev I/O completion status
  spdk_bdev_io_status* {.size: sizeof(cint).} = enum
    SPDK_BDEV_IO_STATUS_FAILED = - 1, SPDK_BDEV_IO_STATUS_PENDING = 0,
    SPDK_BDEV_IO_STATUS_SUCCESS = 1

  ## * Blockdev reset operation type
  spdk_bdev_reset_type* {.size: sizeof(cint).} = enum ## *
                                                 ##  A hard reset indicates that the blockdev layer should not
                                                 ##   invoke the completion callback for I/Os issued before the
                                                 ##   reset is issued but completed after the reset is complete.
                                                 ##
    SPDK_BDEV_RESET_HARD, ## *
                         ##  A soft reset indicates that the blockdev layer should still
                         ##   invoke the completion callback for I/Os issued before the
                         ##   reset is issued but completed after the reset is complete.
                         ##
    SPDK_BDEV_RESET_SOFT

  spdk_bdev_io_completion_cb* = spdk_event_fn
  spdk_bdev_io_get_rbuf_cb* = proc (bdev_io: ptr spdk_bdev_io) {.cdecl.}



  ## * Block device module
  INNER_C_STRUCT_2694020925* = object
    tqe_next*: ptr spdk_bdev_module_if ##  next element
    tqe_prev*: ptr ptr spdk_bdev_module_if ##  address of previous next element

  spdk_bdev_module_if* = object
    module_init*: proc (): cint {.cdecl.} ## *
                                     ##  Initialization function for the module.  Called by the spdk
                                     ##  application during startup.
                                     ##
                                     ##  Modules are required to define this function.
                                     ##
    ## *
    ##  Finish function for the module.  Called by the spdk application
    ##  before the spdk application exits to perform any necessary cleanup.
    ##
    ##  Modules are not required to define this function.
    ##
    module_fini*: proc () {.cdecl.} ## *
                                ##  Function called to return a text string representing the
                                ##  module's configuration options for inclusion in a configuration file.
                                ##
    config_text*: proc (fp: ptr FILE) {.cdecl.} ## * Name for the modules being defined.
    module_name*: cstring ## *
                        ##  Returns the allocation size required for the backend for uses such as local
                        ##  command structs, local SGL, iovecs, or other user context.
                        ##
    get_ctx_size*: proc (): cint {.cdecl.} ## 	TAILQ_ENTRY(spdk_bdev_module_if) tailq;
                                      ## C2NIM macro uncompressing
    tailq*: INNER_C_STRUCT_2694020925


##  The blockdev API has two distinct parts. The first portion of the API
##  is to be used by the layer above the blockdev in order to communicate
##  with it. The second portion of the API is to be used by the blockdev
##  modules themselves to perform operations like completing I/O.
##
##  The following functions are intended to be called from the upper layer
##  that is using the blockdev layer.
##

proc spdk_bdev_get_by_name*(bdev_name: cstring): ptr spdk_bdev {.cdecl,
    importc: "spdk_bdev_get_by_name", dynlib: libspdk.}
proc spdk_bdev_first*(): ptr spdk_bdev {.cdecl, importc: "spdk_bdev_first",
                                     dynlib: libspdk.}
proc spdk_bdev_next*(prev: ptr spdk_bdev): ptr spdk_bdev {.cdecl,
    importc: "spdk_bdev_next", dynlib: libspdk.}
proc spdk_bdev_read*(bdev: ptr spdk_bdev; buf: pointer; nbytes: uint64; offset: uint64;
                    cb: spdk_bdev_io_completion_cb; cb_arg: pointer): ptr spdk_bdev_io {.
    cdecl, importc: "spdk_bdev_read", dynlib: libspdk.}
proc spdk_bdev_write*(bdev: ptr spdk_bdev; buf: pointer; nbytes: uint64; offset: uint64;
                     cb: spdk_bdev_io_completion_cb; cb_arg: pointer): ptr spdk_bdev_io {.
    cdecl, importc: "spdk_bdev_write", dynlib: libspdk.}
proc spdk_bdev_writev*(bdev: ptr spdk_bdev; iov: ptr iovec; iovcnt: cint; len: uint64;
                      offset: uint64; cb: spdk_bdev_io_completion_cb;
                      cb_arg: pointer): ptr spdk_bdev_io {.cdecl,
    importc: "spdk_bdev_writev", dynlib: libspdk.}
proc spdk_bdev_unmap*(bdev: ptr spdk_bdev; unmap_d: ptr spdk_scsi_unmap_bdesc;
                     bdesc_count: uint16; cb: spdk_bdev_io_completion_cb;
                     cb_arg: pointer): ptr spdk_bdev_io {.cdecl,
    importc: "spdk_bdev_unmap", dynlib: libspdk.}
proc spdk_bdev_flush*(bdev: ptr spdk_bdev; offset: uint64; length: uint64;
                     cb: spdk_bdev_io_completion_cb; cb_arg: pointer): ptr spdk_bdev_io {.
    cdecl, importc: "spdk_bdev_flush", dynlib: libspdk.}
proc spdk_bdev_io_submit*(bdev_io: ptr spdk_bdev_io): cint {.cdecl,
    importc: "spdk_bdev_io_submit", dynlib: libspdk.}
proc spdk_bdev_do_work*(ctx: pointer) {.cdecl, importc: "spdk_bdev_do_work",
                                     dynlib: libspdk.}
proc spdk_bdev_reset*(bdev: ptr spdk_bdev; reset_type: cint;
                     cb: spdk_bdev_io_completion_cb; cb_arg: pointer): cint {.cdecl,
    importc: "spdk_bdev_reset", dynlib: libspdk.}
##  The remaining functions are intended to be called from within
##  blockdev modules.
##

proc spdk_bdev_register*(bdev: ptr spdk_bdev) {.cdecl, importc: "spdk_bdev_register",
    dynlib: libspdk.}
proc spdk_bdev_unregister*(bdev: ptr spdk_bdev) {.cdecl,
    importc: "spdk_bdev_unregister", dynlib: libspdk.}
proc spdk_bdev_free_io*(bdev_io: ptr spdk_bdev_io): cint {.cdecl,
    importc: "spdk_bdev_free_io", dynlib: libspdk.}
proc spdk_bdev_io_get_rbuf*(bdev_io: ptr spdk_bdev_io; cb: spdk_bdev_io_get_rbuf_cb) {.
    cdecl, importc: "spdk_bdev_io_get_rbuf", dynlib: libspdk.}
proc spdk_bdev_get_io*(): ptr spdk_bdev_io {.cdecl, importc: "spdk_bdev_get_io",
    dynlib: libspdk.}
proc spdk_bdev_get_child_io*(parent: ptr spdk_bdev_io; bdev: ptr spdk_bdev;
                            cb: spdk_bdev_io_completion_cb; cb_arg: pointer): ptr spdk_bdev_io {.
    cdecl, importc: "spdk_bdev_get_child_io", dynlib: libspdk.}
proc spdk_bdev_io_complete*(bdev_io: ptr spdk_bdev_io; status: spdk_bdev_io_status) {.
    cdecl, importc: "spdk_bdev_io_complete", dynlib: libspdk.}
proc spdk_bdev_module_list_add*(bdev_module: ptr spdk_bdev_module_if) {.cdecl,
    importc: "spdk_bdev_module_list_add", dynlib: libspdk.}
proc spdk_vbdev_module_list_add*(vbdev_module: ptr spdk_bdev_module_if) {.cdecl,
    importc: "spdk_vbdev_module_list_add", dynlib: libspdk.}
proc spdk_bdev_io_from_ctx*(ctx: pointer): ptr spdk_bdev_io {.inline, cdecl.} =
  return cast[ptr spdk_bdev_io]((cast[uint64](ctx) - offsetof(spdk_bdev_io, driver_ctx)))
