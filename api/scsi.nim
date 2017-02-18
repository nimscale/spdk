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
##  SCSI to blockdev translation layer
##

import
  event, trace, bdev


type
  iovec {.importc: "struct iovec", final.} = object ##  Defines for SPDK tracing framework

const
  OWNER_SCSI_DEV* = 0x00000010
  OBJECT_SCSI_TASK* = 0x00000010
  TRACE_GROUP_SCSI* = 0x00000002
  TRACE_SCSI_TASK_DONE* = SPDK_TPOINT_ID(TRACE_GROUP_SCSI, 0x00000000)
  TRACE_SCSI_TASK_START* = SPDK_TPOINT_ID(TRACE_GROUP_SCSI, 0x00000001)
  SPDK_SCSI_MAX_DEVS* = 1024
  SPDK_SCSI_DEV_MAX_LUN* = 64
  SPDK_SCSI_DEV_MAX_PORTS* = 4
  SPDK_SCSI_DEV_MAX_NAME* = 255
  SPDK_SCSI_PORT_MAX_NAME_LENGTH* = 255
  SPDK_SCSI_LUN_MAX_NAME_LENGTH* = 16

type
  spdk_scsi_data_dir* {.size: sizeof(cint).} = enum
    SPDK_SCSI_DIR_NONE = 0, SPDK_SCSI_DIR_TO_DEV = 1, SPDK_SCSI_DIR_FROM_DEV = 2


type
  spdk_scsi_task_func* {.size: sizeof(cint).} = enum
    SPDK_SCSI_TASK_FUNC_ABORT_TASK = 0, SPDK_SCSI_TASK_FUNC_ABORT_TASK_SET,
    SPDK_SCSI_TASK_FUNC_CLEAR_TASK_SET, SPDK_SCSI_TASK_FUNC_LUN_RESET

  spdk_scsi_task_type* {.size: sizeof(cint).} = enum
    SPDK_SCSI_TASK_TYPE_CMD = 0, SPDK_SCSI_TASK_TYPE_MANAGE


  spdk_scsi_task_mgmt_resp* {.size: sizeof(cint).} = enum   ##
                                                            ##  SAM does not define the value for these service responses.  Each transport
                                                            ##   (i.e. SAS, FC, iSCSI) will map these value to transport-specific codes,
                                                            ##   and may add their own.
                                                            ##
    SPDK_SCSI_TASK_MGMT_RESP_COMPLETE, SPDK_SCSI_TASK_MGMT_RESP_SUCCESS,
    SPDK_SCSI_TASK_MGMT_RESP_REJECT, SPDK_SCSI_TASK_MGMT_RESP_INVALID_LUN,
    SPDK_SCSI_TASK_MGMT_RESP_TARGET_FAILURE,
    SPDK_SCSI_TASK_MGMT_RESP_REJECT_FUNC_NOT_SUPPORTED

  INNER_C_STRUCT_2333803407* = object
    tqe_next*: ptr spdk_scsi_task ##  next element
    tqe_prev*: ptr ptr spdk_scsi_task ##  address of previous next element

  subtask_list_1778056107* = object
    tqh_first*: ptr spdk_scsi_task ##  first element
    tqh_last*: ptr ptr spdk_scsi_task ##  addr of last next element

  spdk_scsi_task* = object
    `type`*: uint8
    status*: uint8
    function*: uint8           ##  task mgmt function
    response*: uint8           ##  task mgmt response
    lun*: ptr spdk_scsi_lun
    target_port*: ptr spdk_scsi_port
    initiator_port*: ptr spdk_scsi_port
    cb_event*: spdk_event_t
    `ref`*: uint32
    id*: uint32
    transfer_len*: uint32
    data_out_cnt*: uint32
    dxfer_dir*: uint32
    desired_data_transfer_length*: uint32 ##  Only valid for Read/Write
    bytes_completed*: uint32
    length*: uint32 ## *
                  ##  Amount of data actually transferred.  Can be less than requested
                  ##   transfer_len - i.e. SCSI INQUIRY.
                  ##
    data_transferred*: uint32
    alloc_len*: uint32
    offset*: uint64
    iov*: iovec
    parent*: ptr spdk_scsi_task
    free_fn*: proc (a2: ptr spdk_scsi_task) {.cdecl.}
    cdb*: ptr uint8
    iobuf*: ptr uint8
    sense_data*: array[32, uint8]
    sense_data_len*: csize
    rbuf*: ptr uint8            ##  read buffer
    blockdev_io*: pointer      ## 	TAILQ_ENTRY(spdk_scsi_task) scsi_link;
    scsi_link*: INNER_C_STRUCT_2333803407 ##
                                        ##  Pointer to scsi task owner's outstanding
                                        ##  task counter. Inc/Dec by get/put task functions.
                                        ##  Note: in the future, we could consider replacing this
                                        ##  with an owner-provided task management fuction that
                                        ##  could perform protocol specific task mangement
                                        ##  operations (such as tracking outstanding tasks).
                                        ##
    owner_task_ctr*: ptr uint32
    abort_id*: uint32          ## 	TAILQ_HEAD(subtask_list, spdk_scsi_task) subtask_list;
    subtask_list*: subtask_list_1778056107

  spdk_scsi_port* = object
    dev*: ptr spdk_scsi_dev
    id*: uint64
    index*: uint16
    name*: array[SPDK_SCSI_PORT_MAX_NAME_LENGTH, char]

  spdk_scsi_dev* = object
    id*: cint
    is_allocated*: cint
    name*: array[SPDK_SCSI_DEV_MAX_NAME, char]
    maxlun*: cint
    lun*: array[SPDK_SCSI_DEV_MAX_LUN, ptr spdk_scsi_lun]
    num_ports*: cint
    port*: array[SPDK_SCSI_DEV_MAX_PORTS, spdk_scsi_port]


  tasks_2308317991* = object    ## *
                                ##
                                ## \brief Represents a SCSI LUN.
                                ##
                                ## LUN modules will implement the function pointers specifically for the LUN
                                ## type.  For example, NVMe LUNs will implement scsi_execute to translate
                                ## the SCSI task to an NVMe command and post it to the NVMe controller.
                                ## malloc LUNs will implement scsi_execute to translate the SCSI task and
                                ## copy the task's data into or out of the allocated memory buffer.
                                ##
                                ##
    tqh_first*: ptr spdk_scsi_task ##  first element
    tqh_last*: ptr ptr spdk_scsi_task ##  addr of last next element

  pending_tasks_3839979178* = object
    tqh_first*: ptr spdk_scsi_task ##  first element
    tqh_last*: ptr ptr spdk_scsi_task ##  addr of last next element

  spdk_scsi_lun* = object
    id*: cint                  ## * LUN id for this logical unit.
    ## * Pointer to the SCSI device containing this LUN.
    dev*: ptr spdk_scsi_dev     ## * The blockdev associated with this LUN.
    bdev*: ptr spdk_bdev        ## * Name for this LUN.
    name*: array[SPDK_SCSI_LUN_MAX_NAME_LENGTH, char] ##   TAILQ_HEAD(tasks, spdk_scsi_task) tasks;			/* submitted tasks */
    tasks*: tasks_2308317991   ## 	TAILQ_HEAD(pending_tasks, spdk_scsi_task) pending_tasks;	/* pending tasks */
    pending_tasks*: pending_tasks_3839979178


proc spdk_scsi_dev_destruct*(dev: ptr spdk_scsi_dev) {.cdecl,
    importc: "spdk_scsi_dev_destruct", dynlib: libspdk.}
proc spdk_scsi_dev_queue_mgmt_task*(dev: ptr spdk_scsi_dev; task: ptr spdk_scsi_task) {.
    cdecl, importc: "spdk_scsi_dev_queue_mgmt_task", dynlib: libspdk.}
proc spdk_scsi_dev_queue_task*(dev: ptr spdk_scsi_dev; task: ptr spdk_scsi_task) {.
    cdecl, importc: "spdk_scsi_dev_queue_task", dynlib: libspdk.}
proc spdk_scsi_dev_add_port*(dev: ptr spdk_scsi_dev; id: uint64; name: cstring): cint {.
    cdecl, importc: "spdk_scsi_dev_add_port", dynlib: libspdk.}
proc spdk_scsi_dev_find_port_by_id*(dev: ptr spdk_scsi_dev; id: uint64): ptr spdk_scsi_port {.
    cdecl, importc: "spdk_scsi_dev_find_port_by_id", dynlib: libspdk.}
proc spdk_scsi_dev_print*(dev: ptr spdk_scsi_dev) {.cdecl,
    importc: "spdk_scsi_dev_print", dynlib: libspdk.}

proc spdk_scsi_dev_construct*(name: cstring; lun_name_list: ptr cstring;
                             lun_id_list: ptr cint; num_luns: cint): ptr spdk_scsi_dev {.
    cdecl, importc: "spdk_scsi_dev_construct", dynlib: libspdk.}
  ## *
  ##
  ## \brief Constructs a SCSI device object using the given parameters.
  ##
  ## \param name Name for the SCSI device.
  ## \param queue_depth Queue depth for the SCSI device.  This queue depth is
  ## 		   a combined queue depth for all LUNs in the device.
  ## \param lun_list List of LUN objects for the SCSI device.  Caller is
  ## 		responsible for managing the memory containing this list.
  ## \param lun_id_list List of LUN IDs for the LUN in this SCSI device.  Caller is
  ## 		   responsible for managing the memory containing this list.
  ## 		   lun_id_list[x] is the LUN ID for lun_list[x].
  ## \param num_luns Number of entries in lun_list and lun_id_list.
  ## \return The constructed spdk_scsi_dev object.
  ##
  ##

proc spdk_scsi_dev_delete_lun*(dev: ptr spdk_scsi_dev; lun: ptr spdk_scsi_lun) {.cdecl,
    importc: "spdk_scsi_dev_delete_lun", dynlib: libspdk.}
proc spdk_scsi_port_construct*(port: ptr spdk_scsi_port; id: uint64; index: uint16;
                              name: cstring): cint {.cdecl,
    importc: "spdk_scsi_port_construct", dynlib: libspdk.}
proc spdk_scsi_task_construct*(task: ptr spdk_scsi_task; owner_task_ctr: ptr uint32;
                              parent: ptr spdk_scsi_task) {.cdecl,
    importc: "spdk_scsi_task_construct", dynlib: libspdk.}
proc spdk_put_task*(task: ptr spdk_scsi_task) {.cdecl, importc: "spdk_put_task",
    dynlib: libspdk.}
proc spdk_scsi_task_alloc_data*(task: ptr spdk_scsi_task; alloc_len: uint32;
                               data: ptr ptr uint8) {.cdecl,
    importc: "spdk_scsi_task_alloc_data", dynlib: libspdk.}
proc spdk_scsi_task_build_sense_data*(task: ptr spdk_scsi_task; sk: cint; asc: cint;
                                     ascq: cint): cint {.cdecl,
    importc: "spdk_scsi_task_build_sense_data", dynlib: libspdk.}
proc spdk_scsi_task_set_check_condition*(task: ptr spdk_scsi_task; sk: cint;
                                        asc: cint; ascq: cint) {.cdecl,
    importc: "spdk_scsi_task_set_check_condition", dynlib: libspdk.}
proc spdk_scsi_task_get_primary*(task: ptr spdk_scsi_task): ptr spdk_scsi_task {.
    inline, cdecl.} =
  if task.parent != nil:
    return task.parent
  else:
    return task
