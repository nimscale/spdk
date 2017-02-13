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

import
  system, typeinfo,
  ../../api/nvme, ../../api/pci, ../../api/nvme_spec

#import
#  ../../api/mmio

# rivasiv addad declaration NIM was not able to resolve
type
  rte_mempool {.importc: "struct rte_mempool", final.} = object
  rte_mempool_ctor_t   = proc (x: ptr rte_mempool; y: pointer) {.closure.}
  rte_mempool_obj_cb_t = proc (mp: ptr rte_mempool; opaque: pointer, obj: pointer, obj_idx: uint) {.closure.}

#  spdk_nvme_ctrlr_data {.importc: "struct spdk_nvme_ctrlr_data", final.} = object
#  request_mempool* = ptr rte_mempool


## rivasiv c2nim corrections/helps
proc printf(formatstr: cstring)
  {.header: "<stdio.h>", varargs.}
proc exit(exitCode: int32)
  {.header: "<stdlib.h>", varargs.}
proc snprintf(buf:cstring; size: csize; frmt: cstring) : cint {.header: "<stdio.h>", importc: "snprintf", varargs.}

##DPDK dependencies
proc rte_free(cptr : pointer) {.importc: "rte_free", dynlib: libspdk.}
proc rte_zmalloc (typePrt: cstring; size: uint64; align : uint) : pointer {.importc: "rte_zmalloc", dynlib: libspdk.}
proc rte_eal_init(argc : cint; argv : cstringArray) : cint {.importc: "rte_eal_init", dynlib: libspdk.}
proc rte_mempool_create(name: cstring; n: uint; elt_size: csize; cache_size: uint; private_data_size: uint;
                        mp_init : ptr rte_mempool_ctor_t; mp_init_arg: pointer; obj_init: ptr rte_mempool_obj_cb_t; obj_init_arg: pointer;
                        socket_id: int, lags: uint): ptr rte_mempool {.importc: "rte_mempool_create", dynlib: libspdk.}

type
  ctrlr_entry* = object
    ctrlr*: ptr spdk_nvme_ctrlr
    next*: ptr ctrlr_entry
    name*: array[1024, char]

  ns_entry* = object
    ctrlr*: ptr spdk_nvme_ctrlr
    ns*: ptr spdk_nvme_ns
    next*: ptr ns_entry
    qpair*: ptr spdk_nvme_qpair


var request_mempool* {.exportc: "request_mempool"} : ptr rte_mempool

var g_controllers* {.exportc: "g_controllers"}: ptr ctrlr_entry

var g_namespaces* {.exportc: "g_namespaces"}: ptr ns_entry

proc register_ns*(ctrlr: ptr spdk_nvme_ctrlr; ns: ptr spdk_nvme_ns) =
  var entry: ptr ns_entry
  var cdata: ptr spdk_nvme_ctrlr_data
  ##
  ##  spdk_nvme_ctrlr is the logical abstraction in SPDK for an NVMe
  ##   controller.  During initialization, the IDENTIFY data for the
  ##   controller is read using an NVMe admin command, and that data
  ##   can be retrieved using spdk_nvme_ctrlr_get_data() to get
  ##   detailed information on the controller.  Refer to the NVMe
  ##   specification for more details on IDENTIFY for NVMe controllers.
  ##
  cdata = spdk_nvme_ctrlr_get_data(ctrlr)
  if not spdk_nvme_ns_is_active(ns):
    printf("Controller %-20.20s (%-20.20s): Skipping inactive NS %u\x0A",
           cdata.mn, cdata.sn, spdk_nvme_ns_get_id(ns))
    return
  entry = cast[ptr ns_entry](allocShared(sizeof(ns_entry)))
  if entry == nil:
    printf("ns_entry allocShared")
    exit(1)
  entry.ctrlr = ctrlr
  entry.ns = ns
  entry.next = g_namespaces
  g_namespaces = entry
  printf("  Namespace ID: %d size: %juGB\x0A", spdk_nvme_ns_get_id(ns),
         spdk_nvme_ns_get_size(ns) div 1000000000)

type
  hello_world_sequence* = object
    ns_entry*: ptr ns_entry
    buf*: cstring
    is_completed*: cint


proc read_complete*(arg: pointer; completion: ptr spdk_nvme_cpl) {.cdecl.} =
  var sequence: ptr hello_world_sequence

  sequence = cast[ptr hello_world_sequence](arg)

  ##
  ##  The read I/O has completed.  Print the contents of the
  ##   buffer, free the buffer, then mark the sequence as
  ##   completed.  This will trigger the hello_world() function
  ##   to exit its polling loop.
  ##
  printf("\n\n  %s  \n\n", sequence.buf)
  rte_free(sequence.buf)
  sequence.is_completed = 1

proc write_complete*(arg: pointer; completion: ptr spdk_nvme_cpl) {.cdecl.} =
  var sequence: ptr hello_world_sequence
  var ns_entryLoc: ptr ns_entry
  var rc: cint

  sequence = cast[ptr hello_world_sequence](arg)
  ns_entryLoc = sequence.ns_entry

  ##
  ##  The write I/O has completed.  Free the buffer associated with
  ##   the write I/O and allocate a new zeroed buffer for reading
  ##   the data back from the NVMe namespace.
  ##
  rte_free(sequence.buf)
  sequence.buf = cast[cstring](rte_zmalloc(nil, 0x00001000, 0x00001000))
  rc = spdk_nvme_ns_cmd_read(ns_entryLoc.ns,
                             ns_entryLoc.qpair,
                             sequence.buf,
                             0, ##  LBA start
                             1, ##  number of LBAs
                             read_complete,
                             cast[pointer](sequence),
                             0)
  if rc != 0:
    printf("starting read I/O failed\x0A")
    exit(1)

proc hello_world*() =
  var ns_entry: ptr ns_entry
  var sequence: hello_world_sequence
  var rc: cint
  var numb: int32   # this is mostly used to discard NIM compilation issues

  ns_entry = g_namespaces

  while ns_entry != nil:
    ##
    ##  Allocate an I/O qpair that we can use to submit read/write requests
    ##   to namespaces on the controller.  NVMe controllers typically support
    ##   many qpairs per controller.  Any I/O qpair allocated for a controller
    ##   can submit I/O to any namespace on that controller.
    ##
    ##  The SPDK NVMe driver provides no synchronization for qpair accesses -
    ##   the application must ensure only a single thread submits I/O to a
    ##   qpair, and that same thread must also check for completions on that
    ##   qpair.  This enables extremely efficient I/O processing by making all
    ##   I/O operations completely lockless.
    ##
    ns_entry.qpair = spdk_nvme_ctrlr_alloc_io_qpair(ns_entry.ctrlr, SPDK_NVME_QPRIO_URGENT)
    if ns_entry.qpair == nil:
      printf("ERROR: spdk_nvme_ctrlr_alloc_io_qpair() failed\x0A")
      return

    sequence.buf = cast[cstring](rte_zmalloc(nil, 0x00001000, 0x00001000))
    sequence.is_completed = 0
    sequence.ns_entry = ns_entry

    ##
    ##  Print "Hello world!" to sequence.buf.  We will write this data to LBA
    ##   0 on the namespace, and then later read it back into a separate buffer
    ##   to demonstrate the full I/O path.
    ##
    let offs = snprintf(sequence.buf, 0x00001000, "\n\n Hello world!\x0A\n\n")

    ##
    ##  Write the data buffer to LBA 0 of this namespace.  "write_complete" and
    ##   "&sequence" are specified as the completion callback function and
    ##   argument respectively.  write_complete() will be called with the
    ##   value of &sequence as a parameter when the write I/O is completed.
    ##   This allows users to potentially specify different completion
    ##   callback routines for each I/O, as well as pass a unique handle
    ##   as an argument so the application knows which I/O has completed.
    ##
    ##  Note that the SPDK NVMe driver will only check for completions
    ##   when the application calls spdk_nvme_qpair_process_completions().
    ##   It is the responsibility of the application to trigger the polling
    ##   process.
    ##
    rc = spdk_nvme_ns_cmd_write(ns_entry.ns, ns_entry.qpair, sequence.buf, 0, ##  LBA start
                              1, ##  number of LBAs
                              write_complete, addr(sequence), 0)
    if rc != 0:
      printf("starting write I/O failed\x0A")
      exit(1)

    ##
    ## Poll for completions.  0 here means process all available completions
    ##  In certain usage models, the caller may specify a positive integer
    ##  instead of 0 to signify the maximum number of completions it should
    ##  process.  This function will never block - if there are no
    ##  completions pending on the specified qpair, it will return immediately.
    ##
    ## When the write I/O completes, write_complete() will submit a new I/O
    ##  to read LBA 0 into a separate buffer, specifying read_complete() as its
    ##  completion routine.  When the read I/O completes, read_complete() will
    ##  print the buffer contents and set sequence.is_completed = 1.  That will
    ##  break this loop and then exit the program.
    while 0 == sequence.is_completed:
      numb = spdk_nvme_qpair_process_completions(ns_entry.qpair, 0)


    ##
    ##  Free the I/O qpair.  This typically is done when an application exits.
    ##   But SPDK does support freeing and then reallocating qpairs during
    ##   operation.  It is the responsibility of the caller to ensure all
    ##   pending I/O are completed before trying to free the qpair.
    ##
    numb = spdk_nvme_ctrlr_free_io_qpair(ns_entry.qpair)
    ns_entry = ns_entry.next


proc probe_cb*(cb_ctx: pointer; dev: ptr spdk_pci_device;
              opts: ptr spdk_nvme_ctrlr_opts): bool {.cdecl.} =
  if spdk_pci_device_has_non_uio_driver(dev) > 0:
    ##
    ##  If an NVMe controller is found, but it is attached to a non-uio
    ##   driver (i.e. the kernel NVMe driver), we will not try to attach
    ##   to it.
    ##
    printf("non-uio kernel driver attached to NVMe\x0A")
    printf(" controller at PCI address %04x:%02x:%02x.%02x\x0A",
            spdk_pci_device_get_domain(dev), spdk_pci_device_get_bus(dev),
            spdk_pci_device_get_dev(dev), spdk_pci_device_get_func(dev))
    printf(" skipping...\x0A")
    return false
  printf("Attaching to %04x:%02x:%02x.%02x\x0A", spdk_pci_device_get_domain(dev),
         spdk_pci_device_get_bus(dev), spdk_pci_device_get_dev(dev),
         spdk_pci_device_get_func(dev))
  return true

proc attach_cb*(cb_ctx: pointer; dev: ptr spdk_pci_device; ctrlr: ptr spdk_nvme_ctrlr;
               opts: ptr spdk_nvme_ctrlr_opts) {.cdecl.} =
  var
    nsid: uint32
    num_ns: uint32
  var entry: ptr ctrlr_entry
  var cdata: ptr spdk_nvme_ctrlr_data

  cdata = spdk_nvme_ctrlr_get_data(ctrlr)

  entry = cast[ptr ctrlr_entry](allocShared(sizeof(ctrlr_entry)))
  if entry == nil:
    printf("ctrlr_entry allocShared")
    exit(1)
  printf("Attached to %04x:%02x:%02x.%02x\x0A", spdk_pci_device_get_domain(dev),
         spdk_pci_device_get_bus(dev), spdk_pci_device_get_dev(dev),
         spdk_pci_device_get_func(dev))
  var offs : cint = snprintf(entry.name, sizeof((entry.name)), "%-20.20s (%-20.20s)", cdata.mn, cdata.sn)
  entry.ctrlr = ctrlr
  entry.next = g_controllers
  g_controllers = entry
  ##
  ##  Each controller has one of more namespaces.  An NVMe namespace is basically
  ##   equivalent to a SCSI LUN.  The controller's IDENTIFY data tells us how
  ##   many namespaces exist on the controller.  For Intel(R) P3X00 controllers,
  ##   it will just be one namespace.
  ##
  ##  Note that in NVMe, namespace IDs start at 1, not 0.
  ##
  num_ns = spdk_nvme_ctrlr_get_num_ns(ctrlr)
  printf("Using controller %s with %d namespaces.\x0A", entry.name, num_ns)
  nsid = 1
  while nsid <= num_ns:
    register_ns(ctrlr, spdk_nvme_ctrlr_get_ns(ctrlr, nsid))
    inc(nsid)

proc cleanup*() =
  var ret : cint
  var ns_entry: ptr ns_entry
  var ctrlr_entry: ptr ctrlr_entry

  ns_entry = g_namespaces
  ctrlr_entry = g_controllers

  while cast[bool](ns_entry):
    var next: ptr ns_entry
    deallocShared(ns_entry)
    ns_entry = next
  while cast[bool](ctrlr_entry):
    var next: ptr ctrlr_entry
    ret = spdk_nvme_detach(ctrlr_entry.ctrlr)
    deallocShared(ctrlr_entry)
    ctrlr_entry = next

var ealargs : array[0..3, cstring] = [cstring("hello_world"),
                                      cstring("-c 0x1"),
                                      cstring("-n 4"),
                                      cstring("--proc-type=auto"), ]

proc main*() =
  var rc: cint
  ##
  ##  By default, the SPDK NVMe driver uses DPDK for huge page-based
  ##   memory management and NVMe request buffer pools.  Huge pages can
  ##   be either 2MB or 1GB in size (instead of 4KB) and are pinned in
  ##   memory.  Pinned memory is important to ensure DMA operations
  ##   never target swapped out memory.
  ##
  ##  So first we must initialize DPDK.  "-c 0x1" indicates to only use
  ##   core 0.
  ##
  rc = rte_eal_init(3, cast[cstringArray](ealargs.addr))
  if rc < 0:
    printf("could not initialize dpdk\x0A")
    exit 1
  request_mempool = rte_mempool_create("nvme_request", 8192,
                                     spdk_nvme_request_size(), 128, 0, nil, nil, nil,
                                     nil, -1, 0)  # SOCKET_ID_ANY == -1
  if request_mempool == nil:
    printf("could not initialize request mempool\x0A")
    exit 1
  printf("Initializing NVMe Controllers\x0A")
  ##
  ##  Start the SPDK NVMe enumeration process.  probe_cb will be called
  ##   for each NVMe controller found, giving our application a choice on
  ##   whether to attach to each controller.  attach_cb will then be
  ##   called for each controller after the SPDK NVMe driver has completed
  ##   initializing the controller we chose to attach.
  ##
  rc = spdk_nvme_probe(nil, probe_cb, attach_cb, nil)
  if rc != 0:
    printf("spdk_nvme_probe() failed\x0A")
    cleanup()
    exit 1
  echo "Initialization complete.\x0A"
  hello_world()
  cleanup()
  exit 0

##
##   Entry point
##
main()
