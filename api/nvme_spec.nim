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
##  NVMe specification definitions
##


## *
##  Use to mark a command to apply to all namespaces, or to retrieve global
##   log pages.
##

const
  SPDK_NVME_GLOBAL_NS_TAG* = 0xFFFFFFFF'u32
  SPDK_NVME_MAX_IO_QUEUES* = (65535)
  SPDK_NVME_ADMIN_QUEUE_MIN_ENTRIES* = 2
  SPDK_NVME_ADMIN_QUEUE_MAX_ENTRIES* = 4096
  SPDK_NVME_IO_QUEUE_MIN_ENTRIES* = 2
  SPDK_NVME_IO_QUEUE_MAX_ENTRIES* = 65536

## *
##  Indicates the maximum number of range sets that may be specified
##   in the dataset mangement command.
##

const
  SPDK_NVME_DATASET_MANAGEMENT_MAX_RANGES* = 256

type
  INNER_C_STRUCT_3402172274* = object
    mqes* {.bitsize: 16.}: uint32 ## * maximum queue entries supported
    ## * contiguous queues required
    cqr* {.bitsize: 1.}: uint32  ## * arbitration mechanism supported
    ams* {.bitsize: 2.}: uint32
    reserved1* {.bitsize: 5.}: uint32 ## * timeout
    to* {.bitsize: 8.}: uint32   ## * doorbell stride
    dstrd* {.bitsize: 4.}: uint32 ## * NVM subsystem reset supported
    nssrs* {.bitsize: 1.}: uint32 ## * command sets supported
    css_nvm* {.bitsize: 1.}: uint32
    css_reserved* {.bitsize: 3.}: uint32
    reserved2* {.bitsize: 7.}: uint32 ## * memory page size minimum
    mpsmin* {.bitsize: 4.}: uint32 ## * memory page size maximum
    mpsmax* {.bitsize: 4.}: uint32
    reserved3* {.bitsize: 8.}: uint32

  spdk_nvme_cap_register* = object {.union.}
    raw*: uint64
    bits*: INNER_C_STRUCT_3402172274


assert(sizeof(spdk_nvme_cap_register) == 8, "Incorrect size")
type
  INNER_C_STRUCT_3665462134* = object
    en* {.bitsize: 1.}: uint32   ## * enable
    reserved1* {.bitsize: 3.}: uint32 ## * i/o command set selected
    css* {.bitsize: 3.}: uint32  ## * memory page size
    mps* {.bitsize: 4.}: uint32  ## * arbitration mechanism selected
    ams* {.bitsize: 3.}: uint32  ## * shutdown notification
    shn* {.bitsize: 2.}: uint32  ## * i/o submission queue entry size
    iosqes* {.bitsize: 4.}: uint32 ## * i/o completion queue entry size
    iocqes* {.bitsize: 4.}: uint32
    reserved2* {.bitsize: 8.}: uint32

  spdk_nvme_cc_register* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_3665462134


assert(sizeof(spdk_nvme_cc_register) == 4, "Incorrect size")
type
  spdk_nvme_shn_value* {.size: sizeof(cint).} = enum
    SPDK_NVME_SHN_NORMAL = 0x00000001, SPDK_NVME_SHN_ABRUPT = 0x00000002


type
  INNER_C_STRUCT_3177743603* = object
    rdy* {.bitsize: 1.}: uint32  ## * ready
    ## * controller fatal status
    cfs* {.bitsize: 1.}: uint32  ## * shutdown status
    shst* {.bitsize: 2.}: uint32
    reserved1* {.bitsize: 28.}: uint32

  spdk_nvme_csts_register* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_3177743603


assert(sizeof(spdk_nvme_csts_register) == 4, "Incorrect size")
type
  spdk_nvme_shst_value* {.size: sizeof(cint).} = enum
    SPDK_NVME_SHST_NORMAL = 0x00000000, SPDK_NVME_SHST_OCCURRING = 0x00000001,
    SPDK_NVME_SHST_COMPLETE = 0x00000002


type
  INNER_C_STRUCT_3503666482* = object
    asqs* {.bitsize: 12.}: uint32 ## * admin submission queue size
    reserved1* {.bitsize: 4.}: uint32 ## * admin completion queue size
    acqs* {.bitsize: 12.}: uint32
    reserved2* {.bitsize: 4.}: uint32

  spdk_nvme_aqa_register* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_3503666482


assert(sizeof(spdk_nvme_aqa_register) == 4, "Incorrect size")
type
  INNER_C_STRUCT_226745197* = object
    ter* {.bitsize: 8.}: uint32  ## * indicates the tertiary version
    ## * indicates the minor version
    mnr* {.bitsize: 8.}: uint32  ## * indicates the major version
    mjr* {.bitsize: 16.}: uint32

  spdk_nvme_vs_register* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_226745197


assert(sizeof(spdk_nvme_vs_register) == 4, "Incorrect size")
## * Generate raw version in the same format as \ref spdk_nvme_vs_register for comparison.

template SPDK_NVME_VERSION*(mjr, mnr, ter: untyped): untyped =
  (((uint32)(mjr) shl 16) or ((uint32)(mnr) shl 8) or (uint32)(ter))

##  Test that the shifts are correct

assert(SPDK_NVME_VERSION(1, 0, 0) == 0x00010000, "version macro error")
assert(SPDK_NVME_VERSION(1, 2, 1) == 0x00010201, "version macro error")
type
  INNER_C_STRUCT_552668076* = object
    bir* {.bitsize: 3.}: uint32  ## * indicator of BAR which contains controller memory buffer(CMB)
    reserved1* {.bitsize: 9.}: uint32 ## * offset of CMB in multiples of the size unit
    ofst* {.bitsize: 20.}: uint32

  spdk_nvme_cmbloc_register* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_552668076


assert(sizeof(spdk_nvme_cmbloc_register) == 4, "Incorrect size")
type
  INNER_C_STRUCT_882066358* = object
    sqs* {.bitsize: 1.}: uint32  ## * support submission queues in CMB
    ## * support completion queues in CMB
    cqs* {.bitsize: 1.}: uint32  ## * support PRP and SGLs lists in CMB
    lists* {.bitsize: 1.}: uint32 ## * support read data and metadata in CMB
    rds* {.bitsize: 1.}: uint32  ## * support write data and metadata in CMB
    wds* {.bitsize: 1.}: uint32
    reserved1* {.bitsize: 3.}: uint32 ## * indicates the granularity of the size unit
    szu* {.bitsize: 4.}: uint32  ## * size of CMB in multiples of the size unit
    sz* {.bitsize: 20.}: uint32

  spdk_nvme_cmbsz_register* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_882066358


assert(sizeof(spdk_nvme_cmbsz_register) == 4, "Incorrect size")
type
  INNER_C_STRUCT_1533912116* = object
    sq_tdbl*: uint32           ##  submission queue tail doorbell
    cq_hdbl*: uint32           ##  completion queue head doorbell

  spdk_nvme_registers* = object
    cap*: spdk_nvme_cap_register ## * controller capabilities
    ## * version of NVMe specification
    vs*: spdk_nvme_vs_register
    intms*: uint32             ##  interrupt mask set
    intmc*: uint32             ##  interrupt mask clear
                 ## * controller configuration
    cc*: spdk_nvme_cc_register
    reserved1*: uint32
    csts*: spdk_nvme_csts_register ##  controller status
    nssr*: uint32              ##  NVM subsystem reset
                ## * admin queue attributes
    aqa*: spdk_nvme_aqa_register
    asq*: uint64               ##  admin submission queue base addr
    acq*: uint64               ##  admin completion queue base addr
               ## * controller memory buffer location
    cmbloc*: spdk_nvme_cmbloc_register ## * controller memory buffer size
    cmbsz*: spdk_nvme_cmbsz_register
    reserved3*: array[0x000003F0, uint32]
    doorbell*: array[1, INNER_C_STRUCT_1533912116]


##  NVMe controller register space offsets
## rivasiv: It looks we do not need it in nim code, hence commented
#assert(0x00000000 == offsetof(struct, spdk_nvme_registers, cap),
#       "Incorrect register offset")
#assert(0x00000008 == offsetof(struct, spdk_nvme_registers, vs),
#       "Incorrect register offset")
#assert(0x0000000C == offsetof(struct, spdk_nvme_registers, intms),
#       "Incorrect register offset")
#assert(0x00000010 == offsetof(struct, spdk_nvme_registers, intmc),
#       "Incorrect register offset")
#assert(0x00000014 == offsetof(struct, spdk_nvme_registers, cc),
#       "Incorrect register offset")
#assert(0x0000001C == offsetof(struct, spdk_nvme_registers, csts),
#       "Incorrect register offset")
#assert(0x00000020 == offsetof(struct, spdk_nvme_registers, nssr),
#       "Incorrect register offset")
#assert(0x00000024 == offsetof(struct, spdk_nvme_registers, aqa),
#       "Incorrect register offset")
#assert(0x00000028 == offsetof(struct, spdk_nvme_registers, asq),
#       "Incorrect register offset")
#assert(0x00000030 == offsetof(struct, spdk_nvme_registers, acq),
#       "Incorrect register offset")
#assert(0x00000038 == offsetof(struct, spdk_nvme_registers, cmbloc),
#       "Incorrect register offset")
#assert(0x0000003C == offsetof(struct, spdk_nvme_registers, cmbsz),
#       "Incorrect register offset")

type
  spdk_nvme_sgl_descriptor_type* {.size: sizeof(cint).} = enum
    SPDK_NVME_SGL_TYPE_DATA_BLOCK = 0x00000000,
    SPDK_NVME_SGL_TYPE_BIT_BUCKET = 0x00000001,
    SPDK_NVME_SGL_TYPE_SEGMENT = 0x00000002,
    SPDK_NVME_SGL_TYPE_LAST_SEGMENT = 0x00000003, SPDK_NVME_SGL_TYPE_KEYED_DATA_BLOCK = 0x00000004, ##  0x5 - 0xE reserved
    SPDK_NVME_SGL_TYPE_VENDOR_SPECIFIC = 0x0000000F


type
  spdk_nvme_sgl_descriptor_subtype* {.size: sizeof(cint).} = enum
    SPDK_NVME_SGL_SUBTYPE_ADDRESS = 0x00000000,
    SPDK_NVME_SGL_SUBTYPE_OFFSET = 0x00000001

type
  INNER_C_STRUCT_1705262506* = object
    reserved*: array[7, uint8]
    subtype* {.bitsize: 4.}: uint8
    `type`* {.bitsize: 4.}: uint8

  INNER_C_STRUCT_4017445296* = object
    length*: uint32
    reserved*: array[3, uint8]
    subtype* {.bitsize: 4.}: uint8
    `type`* {.bitsize: 4.}: uint8

  INNER_C_STRUCT_2815247988* = object
    length* {.bitsize: 24.}: uint64
    key* {.bitsize: 32.}: uint64
    subtype* {.bitsize: 4.}: uint64
    `type`* {.bitsize: 4.}: uint64

  INNER_C_UNION_580170892* = object {.union.}
    `generic`*: INNER_C_STRUCT_1705262506
    unkeyed*: INNER_C_STRUCT_4017445296
    keyed*: INNER_C_STRUCT_2815247988

  spdk_nvme_sgl_descriptor* {.packed.} = object
    address*: uint64
    ano_2133083780*: INNER_C_UNION_580170892

assert(sizeof(spdk_nvme_sgl_descriptor) == 16, "Incorrect size")


type
  spdk_nvme_psdt_value* {.size: sizeof(cint).} = enum
    SPDK_NVME_PSDT_PRP = 0x00000000, SPDK_NVME_PSDT_SGL_MPTR_CONTIG = 0x00000001,
    SPDK_NVME_PSDT_SGL_MPTR_SGL = 0x00000002, SPDK_NVME_PSDT_RESERVED = 0x00000003


## *
##  Submission queue priority values for Create I/O Submission Queue Command.
##
##  Only valid for weighted round robin arbitration method.
##

type
  spdk_nvme_qprio* {.size: sizeof(cint).} = enum
    SPDK_NVME_QPRIO_URGENT = 0x00000000, SPDK_NVME_QPRIO_HIGH = 0x00000001,
    SPDK_NVME_QPRIO_MEDIUM = 0x00000002, SPDK_NVME_QPRIO_LOW = 0x00000003


## *
##  Optional Arbitration Mechanism Supported by the controller.
##
##  Two bits for CAP.AMS (18:17) field are set to '1' when the controller supports.
##  There is no bit for AMS_RR where all controllers support and set to 0x0 by default.
##

type
  spdk_nvme_cap_ams* {.size: sizeof(cint).} = enum
    SPDK_NVME_CAP_AMS_WRR = 0x00000001, ## *< weighted round robin
    SPDK_NVME_CAP_AMS_VS = 0x00000002 ## *< vendor specific


## *
##  Arbitration Mechanism Selected to the controller.
##
##  Value 0x2 to 0x6 is reserved.
##

type
  spdk_nvme_cc_ams* {.size: sizeof(cint).} = enum
    SPDK_NVME_CC_AMS_RR = 0x00000000, ## *< default round robin
    SPDK_NVME_CC_AMS_WRR = 0x00000001, ## *< weighted round robin
    SPDK_NVME_CC_AMS_VS = 0x00000007 ## *< vendor specific


type
  INNER_C_STRUCT_549149551* = object
    prp1*: uint64              ##  prp entry 1
    prp2*: uint64              ##  prp entry 2

  INNER_C_UNION_889578952* = object {.union.}
    prp*: INNER_C_STRUCT_549149551
    sgl1*: spdk_nvme_sgl_descriptor

  spdk_nvme_cmd* = object
    opc* {.bitsize: 8.}: uint16  ##  dword 0
    ##  opcode
    fuse* {.bitsize: 2.}: uint16 ##  fused operation
    rsvd1* {.bitsize: 4.}: uint16
    psdt* {.bitsize: 2.}: uint16
    cid*: uint16               ##  command identifier
               ##  dword 1
    nsid*: uint32              ##  namespace identifier
                ##  dword 2-3
    rsvd2*: uint32
    rsvd3*: uint32             ##  dword 4-5
    mptr*: uint64              ##  metadata pointer
                ##  dword 6-9: data pointer
    dptr*: INNER_C_UNION_889578952 ##  dword 10-15
    cdw10*: uint32             ##  command-specific
    cdw11*: uint32             ##  command-specific
    cdw12*: uint32             ##  command-specific
    cdw13*: uint32             ##  command-specific
    cdw14*: uint32             ##  command-specific
    cdw15*: uint32             ##  command-specific


assert(sizeof(spdk_nvme_cmd) == 64, "Incorrect size")
type
  spdk_nvme_status* = object
    p* {.bitsize: 1.}: uint16    ##  phase tag
    sc* {.bitsize: 8.}: uint16   ##  status code
    sct* {.bitsize: 3.}: uint16  ##  status code type
    rsvd2* {.bitsize: 2.}: uint16
    m* {.bitsize: 1.}: uint16    ##  more
    dnr* {.bitsize: 1.}: uint16  ##  do not retry


assert(sizeof(spdk_nvme_status) == 2, "Incorrect size")
## *
##  Completion queue entry
##

type
  spdk_nvme_cpl* = object
    cdw0*: uint32              ##  dword 0
    ##  command-specific
    ##  dword 1
    rsvd1*: uint32             ##  dword 2
    sqhd*: uint16              ##  submission queue head pointer
    sqid*: uint16              ##  submission queue identifier
                ##  dword 3
    cid*: uint16               ##  command identifier
    status*: spdk_nvme_status


assert(sizeof(spdk_nvme_cpl) == 16, "Incorrect size")
## *
##  Dataset Management range
##

type
  spdk_nvme_dsm_range* = object
    attributes*: uint32
    length*: uint32
    starting_lba*: uint64


assert(sizeof(spdk_nvme_dsm_range) == 16, "Incorrect size")
## *
##  Status code types
##

type
  spdk_nvme_status_code_type* {.size: sizeof(cint).} = enum
    SPDK_NVME_SCT_GENERIC = 0x00000000,
    SPDK_NVME_SCT_COMMAND_SPECIFIC = 0x00000001, SPDK_NVME_SCT_MEDIA_ERROR = 0x00000002, ##  0x3-0x6 - reserved
    SPDK_NVME_SCT_VENDOR_SPECIFIC = 0x00000007


## *
##  Generic command status codes
##

type
  spdk_nvme_generic_command_status_code* {.size: sizeof(cint).} = enum
    SPDK_NVME_SC_SUCCESS = 0x00000000, SPDK_NVME_SC_INVALID_OPCODE = 0x00000001,
    SPDK_NVME_SC_INVALID_FIELD = 0x00000002,
    SPDK_NVME_SC_COMMAND_ID_CONFLICT = 0x00000003,
    SPDK_NVME_SC_DATA_TRANSFER_ERROR = 0x00000004,
    SPDK_NVME_SC_ABORTED_POWER_LOSS = 0x00000005,
    SPDK_NVME_SC_INTERNAL_DEVICE_ERROR = 0x00000006,
    SPDK_NVME_SC_ABORTED_BY_REQUEST = 0x00000007,
    SPDK_NVME_SC_ABORTED_SQ_DELETION = 0x00000008,
    SPDK_NVME_SC_ABORTED_FAILED_FUSED = 0x00000009,
    SPDK_NVME_SC_ABORTED_MISSING_FUSED = 0x0000000A,
    SPDK_NVME_SC_INVALID_NAMESPACE_OR_FORMAT = 0x0000000B,
    SPDK_NVME_SC_COMMAND_SEQUENCE_ERROR = 0x0000000C,
    SPDK_NVME_SC_INVALID_SGL_SEG_DESCRIPTOR = 0x0000000D,
    SPDK_NVME_SC_INVALID_NUM_SGL_DESCIRPTORS = 0x0000000E,
    SPDK_NVME_SC_DATA_SGL_LENGTH_INVALID = 0x0000000F,
    SPDK_NVME_SC_METADATA_SGL_LENGTH_INVALID = 0x00000010,
    SPDK_NVME_SC_SGL_DESCRIPTOR_TYPE_INVALID = 0x00000011,
    SPDK_NVME_SC_INVALID_CONTROLLER_MEM_BUF = 0x00000012,
    SPDK_NVME_SC_INVALID_PRP_OFFSET = 0x00000013,
    SPDK_NVME_SC_ATOMIC_WRITE_UNIT_EXCEEDED = 0x00000014,
    SPDK_NVME_SC_INVALID_SGL_OFFSET = 0x00000016,
    SPDK_NVME_SC_INVALID_SGL_SUBTYPE = 0x00000017,
    SPDK_NVME_SC_HOSTID_INCONSISTENT_FORMAT = 0x00000018,
    SPDK_NVME_SC_KEEP_ALIVE_EXPIRED = 0x00000019,
    SPDK_NVME_SC_KEEP_ALIVE_INVALID = 0x0000001A,
    SPDK_NVME_SC_LBA_OUT_OF_RANGE = 0x00000080,
    SPDK_NVME_SC_CAPACITY_EXCEEDED = 0x00000081,
    SPDK_NVME_SC_NAMESPACE_NOT_READY = 0x00000082


## *
##  Command specific status codes
##

type
  spdk_nvme_command_specific_status_code* {.size: sizeof(cint).} = enum
    SPDK_NVME_SC_COMPLETION_QUEUE_INVALID = 0x00000000,
    SPDK_NVME_SC_INVALID_QUEUE_IDENTIFIER = 0x00000001,
    SPDK_NVME_SC_MAXIMUM_QUEUE_SIZE_EXCEEDED = 0x00000002, SPDK_NVME_SC_ABORT_COMMAND_LIMIT_EXCEEDED = 0x00000003, ##  0x04 - reserved
    SPDK_NVME_SC_ASYNC_EVENT_REQUEST_LIMIT_EXCEEDED = 0x00000005,
    SPDK_NVME_SC_INVALID_FIRMWARE_SLOT = 0x00000006,
    SPDK_NVME_SC_INVALID_FIRMWARE_IMAGE = 0x00000007,
    SPDK_NVME_SC_INVALID_INTERRUPT_VECTOR = 0x00000008,
    SPDK_NVME_SC_INVALID_LOG_PAGE = 0x00000009,
    SPDK_NVME_SC_INVALID_FORMAT = 0x0000000A,
    SPDK_NVME_SC_FIRMWARE_REQUIRES_RESET = 0x0000000B,
    SPDK_NVME_SC_CONFLICTING_ATTRIBUTES = 0x00000080,
    SPDK_NVME_SC_INVALID_PROTECTION_INFO = 0x00000081,
    SPDK_NVME_SC_ATTEMPTED_WRITE_TO_RO_PAGE = 0x00000082


## *
##  Media error status codes
##

type
  spdk_nvme_media_error_status_code* {.size: sizeof(cint).} = enum
    SPDK_NVME_SC_WRITE_FAULTS = 0x00000080,
    SPDK_NVME_SC_UNRECOVERED_READ_ERROR = 0x00000081,
    SPDK_NVME_SC_GUARD_CHECK_ERROR = 0x00000082,
    SPDK_NVME_SC_APPLICATION_TAG_CHECK_ERROR = 0x00000083,
    SPDK_NVME_SC_REFERENCE_TAG_CHECK_ERROR = 0x00000084,
    SPDK_NVME_SC_COMPARE_FAILURE = 0x00000085,
    SPDK_NVME_SC_ACCESS_DENIED = 0x00000086


## *
##  Admin opcodes
##

type
  spdk_nvme_admin_opcode* {.size: sizeof(cint).} = enum
    SPDK_NVME_OPC_DELETE_IO_SQ = 0x00000000,
    SPDK_NVME_OPC_CREATE_IO_SQ = 0x00000001, SPDK_NVME_OPC_GET_LOG_PAGE = 0x00000002, ##  0x03 - reserved
    SPDK_NVME_OPC_DELETE_IO_CQ = 0x00000004,
    SPDK_NVME_OPC_CREATE_IO_CQ = 0x00000005, SPDK_NVME_OPC_IDENTIFY = 0x00000006, ##  0x07 - reserved
    SPDK_NVME_OPC_ABORT = 0x00000008, SPDK_NVME_OPC_SET_FEATURES = 0x00000009, SPDK_NVME_OPC_GET_FEATURES = 0x0000000A, ##  0x0b - reserved
    SPDK_NVME_OPC_ASYNC_EVENT_REQUEST = 0x0000000C, SPDK_NVME_OPC_NS_MANAGEMENT = 0x0000000D, ##  0x0e-0x0f - reserved
    SPDK_NVME_OPC_FIRMWARE_COMMIT = 0x00000010,
    SPDK_NVME_OPC_FIRMWARE_IMAGE_DOWNLOAD = 0x00000011,
    SPDK_NVME_OPC_NS_ATTACHMENT = 0x00000015,
    SPDK_NVME_OPC_KEEP_ALIVE = 0x00000018, SPDK_NVME_OPC_FORMAT_NVM = 0x00000080,
    SPDK_NVME_OPC_SECURITY_SEND = 0x00000081,
    SPDK_NVME_OPC_SECURITY_RECEIVE = 0x00000082


## *
##  NVM command set opcodes
##

type
  spdk_nvme_nvm_opcode* {.size: sizeof(cint).} = enum
    SPDK_NVME_OPC_FLUSH = 0x00000000, SPDK_NVME_OPC_WRITE = 0x00000001, SPDK_NVME_OPC_READ = 0x00000002, ##  0x03 - reserved
    SPDK_NVME_OPC_WRITE_UNCORRECTABLE = 0x00000004, SPDK_NVME_OPC_COMPARE = 0x00000005, ##  0x06-0x07 - reserved
    SPDK_NVME_OPC_WRITE_ZEROES = 0x00000008,
    SPDK_NVME_OPC_DATASET_MANAGEMENT = 0x00000009,
    SPDK_NVME_OPC_RESERVATION_REGISTER = 0x0000000D,
    SPDK_NVME_OPC_RESERVATION_REPORT = 0x0000000E,
    SPDK_NVME_OPC_RESERVATION_ACQUIRE = 0x00000011,
    SPDK_NVME_OPC_RESERVATION_RELEASE = 0x00000015


## *
##  Data transfer (bits 1:0) of an NVMe opcode.
##
##  \sa spdk_nvme_opc_get_data_transfer
##

type
  spdk_nvme_data_transfer* {.size: sizeof(cint).} = enum ## * Opcode does not transfer data
    SPDK_NVME_DATA_NONE = 0,    ## * Opcode transfers data from host to controller (e.g. Write)
    SPDK_NVME_DATA_HOST_TO_CONTROLLER = 1, ## * Opcode transfers data from controller to host (e.g. Read)
    SPDK_NVME_DATA_CONTROLLER_TO_HOST = 2, ## * Opcode transfers data both directions
    SPDK_NVME_DATA_BIDIRECTIONAL = 3


## *
##  Extract the Data Transfer bits from an NVMe opcode.
##
##  This determines whether a command requires a data buffer and
##  which direction (host to controller or controller to host) it is
##  transferred.
##

proc spdk_nvme_opc_get_data_transfer*(opc: uint8): uint8 {.inline.} =
  return opc and 3

type
  spdk_nvme_feat* {.size: sizeof(cint).} = enum ##  0x00 - reserved
    SPDK_NVME_FEAT_ARBITRATION = 0x00000001,
    SPDK_NVME_FEAT_POWER_MANAGEMENT = 0x00000002,
    SPDK_NVME_FEAT_LBA_RANGE_TYPE = 0x00000003,
    SPDK_NVME_FEAT_TEMPERATURE_THRESHOLD = 0x00000004,
    SPDK_NVME_FEAT_ERROR_RECOVERY = 0x00000005,
    SPDK_NVME_FEAT_VOLATILE_WRITE_CACHE = 0x00000006,
    SPDK_NVME_FEAT_NUMBER_OF_QUEUES = 0x00000007,
    SPDK_NVME_FEAT_INTERRUPT_COALESCING = 0x00000008,
    SPDK_NVME_FEAT_INTERRUPT_VECTOR_CONFIGURATION = 0x00000009,
    SPDK_NVME_FEAT_WRITE_ATOMICITY = 0x0000000A,
    SPDK_NVME_FEAT_ASYNC_EVENT_CONFIGURATION = 0x0000000B,
    SPDK_NVME_FEAT_AUTONOMOUS_POWER_STATE_TRANSITION = 0x0000000C,
    SPDK_NVME_FEAT_HOST_MEM_BUFFER = 0x0000000D, SPDK_NVME_FEAT_KEEP_ALIVE_TIMER = 0x0000000F, ##  0x0C-0x7F - reserved
    SPDK_NVME_FEAT_SOFTWARE_PROGRESS_MARKER = 0x00000080, ##  0x81-0xBF - command set specific
    SPDK_NVME_FEAT_HOST_IDENTIFIER = 0x00000081,
    SPDK_NVME_FEAT_HOST_RESERVE_MASK = 0x00000082, SPDK_NVME_FEAT_HOST_RESERVE_PERSIST = 0x00000083 ##  0xC0-0xFF - vendor specific


type
  spdk_nvme_dsm_attribute* {.size: sizeof(cint).} = enum
    SPDK_NVME_DSM_ATTR_INTEGRAL_READ = 0x00000001,
    SPDK_NVME_DSM_ATTR_INTEGRAL_WRITE = 0x00000002,
    SPDK_NVME_DSM_ATTR_DEALLOCATE = 0x00000004


type
  spdk_nvme_power_state* = object
    mp*: uint16                ##  bits 15:00: maximum power
    reserved1*: uint8
    mps* {.bitsize: 1.}: uint8   ##  bit 24: max power scale
    nops* {.bitsize: 1.}: uint8  ##  bit 25: non-operational state
    reserved2* {.bitsize: 6.}: uint8
    enlat*: uint32             ##  bits 63:32: entry latency in microseconds
    exlat*: uint32             ##  bits 95:64: exit latency in microseconds
    rrt* {.bitsize: 5.}: uint8   ##  bits 100:96: relative read throughput
    reserved3* {.bitsize: 3.}: uint8
    rrl* {.bitsize: 5.}: uint8   ##  bits 108:104: relative read latency
    reserved4* {.bitsize: 3.}: uint8
    rwt* {.bitsize: 5.}: uint8   ##  bits 116:112: relative write throughput
    reserved5* {.bitsize: 3.}: uint8
    rwl* {.bitsize: 5.}: uint8   ##  bits 124:120: relative write latency
    reserved6* {.bitsize: 3.}: uint8
    reserved7*: array[16, uint8]


assert(sizeof(spdk_nvme_power_state) == 32, "Incorrect size")
## * Identify command CNS value

type
  spdk_nvme_identify_cns* {.size: sizeof(cint).} = enum ## * Identify namespace indicated in CDW1.NSID
    SPDK_NVME_IDENTIFY_NS = 0x00000000, ## * Identify controller
    SPDK_NVME_IDENTIFY_CTRLR = 0x00000001, ## * List active NSIDs greater than CDW1.NSID
    SPDK_NVME_IDENTIFY_ACTIVE_NS_LIST = 0x00000002, ## * List allocated NSIDs greater than CDW1.NSID
    SPDK_NVME_IDENTIFY_ALLOCATED_NS_LIST = 0x00000010, ## * Identify namespace if CDW1.NSID is allocated
    SPDK_NVME_IDENTIFY_NS_ALLOCATED = 0x00000011, ## * Get list of controllers starting at CDW10.CNTID that are attached to CDW1.NSID
    SPDK_NVME_IDENTIFY_NS_ATTACHED_CTRLR_LIST = 0x00000012, ## * Get list of controllers starting at CDW10.CNTID
    SPDK_NVME_IDENTIFY_CTRLR_LIST = 0x00000013


## * NVMe over Fabrics controller model

type
  spdk_nvmf_ctrlr_model* {.size: sizeof(cint).} = enum ## * NVM subsystem uses dynamic controller model
    SPDK_NVMF_CTRLR_MODEL_DYNAMIC = 0, ## * NVM subsystem uses static controller model
    SPDK_NVMF_CTRLR_MODEL_STATIC = 1

type
  INNER_C_STRUCT_3119130310* = object
    multi_port* {.bitsize: 1.}: uint8
    multi_host* {.bitsize: 1.}: uint8
    sr_iov* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 5.}: uint8

  INNER_C_STRUCT_2254383982* = object
    host_id_exhid_supported* {.bitsize: 1.}: uint32
    reserved* {.bitsize: 31.}: uint32

  INNER_C_STRUCT_4174535470* = object
    security* {.bitsize: 1.}: uint16 ##  supports security send/receive commands
    ##  supports format nvm command
    format* {.bitsize: 1.}: uint16 ##  supports firmware activate/download commands
    firmware* {.bitsize: 1.}: uint16 ##  supports ns manage/ns attach commands
    ns_manage* {.bitsize: 1.}: uint16
    oacs_rsvd* {.bitsize: 12.}: uint16

  INNER_C_STRUCT_1136345803* = object
    slot1_ro* {.bitsize: 1.}: uint8 ##  first slot is read-only
    ##  number of firmware slots
    num_slots* {.bitsize: 3.}: uint8 ##  support activation without reset
    activation_without_reset* {.bitsize: 1.}: uint8
    frmw_rsvd* {.bitsize: 3.}: uint8

  INNER_C_STRUCT_1949979022* = object
    ns_smart* {.bitsize: 1.}: uint8 ##  per namespace smart/health log page
    ##  command effects log page
    celp* {.bitsize: 1.}: uint8  ##  extended data for get log page
    edlp* {.bitsize: 1.}: uint8
    lpa_rsvd* {.bitsize: 5.}: uint8

  INNER_C_STRUCT_3486368905* = object
    spec_format* {.bitsize: 1.}: uint8 ##  admin vendor specific commands use disk format
    avscc_rsvd* {.bitsize: 7.}: uint8

  INNER_C_STRUCT_3552460945* = object
    supported* {.bitsize: 1.}: uint8 ## * controller supports autonomous power state transitions
    apsta_rsvd* {.bitsize: 7.}: uint8

  INNER_C_STRUCT_1582732236* = object
    num_rpmb_units* {.bitsize: 3.}: uint8
    auth_method* {.bitsize: 3.}: uint8
    reserved1* {.bitsize: 2.}: uint8
    reserved2*: uint8
    total_size*: uint8
    access_size*: uint8

  INNER_C_STRUCT_772566229* = object
    min* {.bitsize: 4.}: uint8
    max* {.bitsize: 4.}: uint8

  INNER_C_STRUCT_1520107408* = object
    min* {.bitsize: 4.}: uint8
    max* {.bitsize: 4.}: uint8

  INNER_C_STRUCT_3189772904* = object
    compare* {.bitsize: 1.}: uint16
    write_unc* {.bitsize: 1.}: uint16
    dsm* {.bitsize: 1.}: uint16
    write_zeroes* {.bitsize: 1.}: uint16
    set_features_save* {.bitsize: 1.}: uint16
    reservations* {.bitsize: 1.}: uint16
    reserved* {.bitsize: 10.}: uint16

  INNER_C_STRUCT_3122589331* = object
    format_all_ns* {.bitsize: 1.}: uint8
    erase_all_ns* {.bitsize: 1.}: uint8
    crypto_erase_supported* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 5.}: uint8

  INNER_C_STRUCT_3886653520* = object
    present* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 7.}: uint8

  INNER_C_STRUCT_2280444264* = object
    supported* {.bitsize: 1.}: uint32
    reserved0* {.bitsize: 1.}: uint32
    keyed_sgl* {.bitsize: 1.}: uint32
    reserved1* {.bitsize: 13.}: uint32
    bit_bucket_descriptor* {.bitsize: 1.}: uint32
    metadata_pointer* {.bitsize: 1.}: uint32
    oversized_sgl* {.bitsize: 1.}: uint32
    metadata_address* {.bitsize: 1.}: uint32
    sgl_offset* {.bitsize: 1.}: uint32
    reserved2* {.bitsize: 11.}: uint32

  INNER_C_STRUCT_2060602266* = object
    ctrlr_model* {.bitsize: 1.}: uint8 ## * Controller model: \ref spdk_nvmf_ctrlr_model
    reserved* {.bitsize: 7.}: uint8

  INNER_C_STRUCT_1045192745* = object
    ioccsz*: uint32            ## * I/O queue command capsule supported size (16-byte units)
    ## * I/O queue response capsule supported size (16-byte units)
    iorcsz*: uint32            ## * In-capsule data offset (16-byte units)
    icdoff*: uint16            ## * Controller attributes
    ctrattr*: INNER_C_STRUCT_2060602266 ## * Maximum SGL block descriptors (0 = no limit)
    msdbd*: uint8
    reserved*: array[244, uint8]

  spdk_nvme_ctrlr_data* {.packed.} = object
    vid*: uint16               ##  bytes 0-255: controller capabilities and features
               ## * pci vendor id
    ## * pci subsystem vendor id
    ssvid*: uint16             ## * serial number
    sn*: array[20, int8]        ## * model number
    mn*: array[40, int8]        ## * firmware revision
    fr*: array[8, uint8]        ## * recommended arbitration burst
    rab*: uint8                ## * ieee oui identifier
    ieee*: array[3, uint8]      ## * controller multi-path I/O and namespace sharing capabilities
    cmic*: INNER_C_STRUCT_3119130310 ## * maximum data transfer size
    mdts*: uint8               ## * controller id
    cntlid*: uint16            ## * version
    ver*: spdk_nvme_vs_register ## * RTD3 resume latency
    rtd3r*: uint32             ## * RTD3 entry latency
    rtd3e*: uint32             ## * optional asynchronous events supported
    oaes*: uint32              ## * controller attributes
    ctratt*: INNER_C_STRUCT_2254383982
    reserved1*: array[156, uint8] ##  bytes 256-511: admin command set attributes
                               ## * optional admin command support
    oacs*: INNER_C_STRUCT_4174535470 ## * abort command limit
    acl*: uint8                ## * asynchronous event request limit
    aerl*: uint8               ## * firmware updates
    frmw*: INNER_C_STRUCT_1136345803 ## * log page attributes
    lpa*: INNER_C_STRUCT_1949979022 ## * error log page entries
    elpe*: uint8               ## * number of power states supported
    npss*: uint8               ## * admin vendor specific command configuration
    avscc*: INNER_C_STRUCT_3486368905 ## * autonomous power state transition attributes
    apsta*: INNER_C_STRUCT_3552460945 ## * warning composite temperature threshold
    wctemp*: uint16            ## * critical composite temperature threshold
    cctemp*: uint16            ## * maximum time for firmware activation
    mtfa*: uint16              ## * host memory buffer preferred size
    hmpre*: uint32             ## * host memory buffer minimum size
    hmmin*: uint32             ## * total NVM capacity
    tnvmcap*: array[2, uint64]  ## * unallocated NVM capacity
    unvmcap*: array[2, uint64]  ## * replay protected memory block support
    rpmbs*: INNER_C_STRUCT_1582732236
    reserved2*: array[4, uint8]
    kas*: uint16
    reserved3*: array[190, uint8] ##  bytes 512-703: nvm command set attributes
                               ## * submission queue entry size
    sqes*: INNER_C_STRUCT_772566229 ## * completion queue entry size
    cqes*: INNER_C_STRUCT_1520107408
    maxcmd*: uint16            ## * number of namespaces
    nn*: uint32                ## * optional nvm command support
    oncs*: INNER_C_STRUCT_3189772904 ## * fused operation support
    fuses*: uint16             ## * format nvm attributes
    fna*: INNER_C_STRUCT_3122589331 ## * volatile write cache
    vwc*: INNER_C_STRUCT_3886653520 ## * atomic write unit normal
    awun*: uint16              ## * atomic write unit power fail
    awupf*: uint16             ## * NVM vendor specific command configuration
    nvscc*: uint8
    reserved531*: uint8        ## * atomic compare & write unit
    acwu*: uint16
    reserved534*: uint16       ## * SGL support
    sgls*: INNER_C_STRUCT_2280444264
    reserved4*: array[228, uint8]
    subnqn*: array[256, uint8]
    reserved5*: array[768, uint8] ## * NVMe over Fabrics-specific fields
    nvmf_specific*: INNER_C_STRUCT_1045192745 ##  bytes 2048-3071: power state descriptors
    psd*: array[32, spdk_nvme_power_state] ##  bytes 3072-4095: vendor specific
    vs*: array[1024, uint8]

#[TBD]#
### rivasiv: This is alternative variant. spdk_nvme_sgl_descriptor is alligned with /*__attribute__((packed))*/ in nim community It was recomended to use
### importc and header pragmas instead of wrapping all structure, access to fields suppose to be organized also
#type
#  spdk_nvme_ctrlr_data* {.importc: "struct spdk_nvme_ctrlr_data", packed, final.} = object
assert(sizeof(spdk_nvme_ctrlr_data) == 4096, "Incorrect size")

type
  INNER_C_STRUCT_1071954908* = object
    thin_prov* {.bitsize: 1.}: uint8 ## * thin provisioning
    reserved1* {.bitsize: 7.}: uint8

  INNER_C_STRUCT_1844280602* = object
    format* {.bitsize: 4.}: uint8
    extended* {.bitsize: 1.}: uint8
    reserved2* {.bitsize: 3.}: uint8

  INNER_C_STRUCT_1910372642* = object
    extended* {.bitsize: 1.}: uint8 ## * metadata can be transferred as part of data prp list
    ## * metadata can be transferred with separate metadata pointer
    pointer* {.bitsize: 1.}: uint8 ## * reserved
    reserved3* {.bitsize: 6.}: uint8

  INNER_C_STRUCT_3405455000* = object
    pit1* {.bitsize: 1.}: uint8  ## * protection information type 1
    ## * protection information type 2
    pit2* {.bitsize: 1.}: uint8  ## * protection information type 3
    pit3* {.bitsize: 1.}: uint8  ## * first eight bytes of metadata
    md_start* {.bitsize: 1.}: uint8 ## * last eight bytes of metadata
    md_end* {.bitsize: 1.}: uint8

  INNER_C_STRUCT_4252134239* = object
    pit* {.bitsize: 3.}: uint8   ## * protection information type
    ## * 1 == protection info transferred at start of metadata
    ## * 0 == protection info transferred at end of metadata
    md_start* {.bitsize: 1.}: uint8
    reserved4* {.bitsize: 4.}: uint8

  INNER_C_STRUCT_746015647* = object
    can_share* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 7.}: uint8

  INNER_C_STRUCT_600922076* = object
    persist* {.bitsize: 1.}: uint8 ## * supports persist through power loss
    ## * supports write exclusive
    write_exclusive* {.bitsize: 1.}: uint8 ## * supports exclusive access
    exclusive_access* {.bitsize: 1.}: uint8 ## * supports write exclusive - registrants only
    write_exclusive_reg_only* {.bitsize: 1.}: uint8 ## * supports exclusive access - registrants only
    exclusive_access_reg_only* {.bitsize: 1.}: uint8 ## * supports write exclusive - all registrants
    write_exclusive_all_reg* {.bitsize: 1.}: uint8 ## * supports exclusive access - all registrants
    exclusive_access_all_reg* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 1.}: uint8

  INNER_C_UNION_1493556825* = object {.union.}
    rescap*: INNER_C_STRUCT_600922076
    raw*: uint8

  INNER_C_STRUCT_1447455008* = object
    percentage_remaining* {.bitsize: 7.}: uint8
    fpi_supported* {.bitsize: 1.}: uint8

  INNER_C_STRUCT_3021822236* = object
    ms* {.bitsize: 16.}: uint32  ## * metadata size
    ## * lba data size
    lbads* {.bitsize: 8.}: uint32 ## * relative performance
    rp* {.bitsize: 2.}: uint32
    reserved6* {.bitsize: 6.}: uint32

  spdk_nvme_ns_data* = object
    nsze*: uint64              ## * namespace size
    ## * namespace capacity
    ncap*: uint64              ## * namespace utilization
    nuse*: uint64              ## * namespace features
    nsfeat*: INNER_C_STRUCT_1071954908 ## * number of lba formats
    nlbaf*: uint8              ## * formatted lba size
    flbas*: INNER_C_STRUCT_1844280602 ## * metadata capabilities
    mc*: INNER_C_STRUCT_1910372642 ## * end-to-end data protection capabilities
    dpc*: INNER_C_STRUCT_3405455000 ## * end-to-end data protection type settings
    dps*: INNER_C_STRUCT_4252134239 ## * namespace multi-path I/O and namespace sharing capabilities
    nmic*: INNER_C_STRUCT_746015647 ## * reservation capabilities
    nsrescap*: INNER_C_UNION_1493556825 ## * format progress indicator
    fpi*: INNER_C_STRUCT_1447455008
    reserved33*: uint8         ## * namespace atomic write unit normal
    nawun*: uint16             ## * namespace atomic write unit power fail
    nawupf*: uint16            ## * namespace atomic compare & write unit
    nacwu*: uint16             ## * namespace atomic boundary size normal
    nabsn*: uint16             ## * namespace atomic boundary offset
    nabo*: uint16              ## * namespace atomic boundary size power fail
    nabspf*: uint16
    reserved46*: uint16        ## * NVM capacity
    nvmcap*: array[2, uint64]
    reserved64*: array[40, uint8] ## * namespace globally unique identifier
    nguid*: array[16, uint8]    ## * IEEE extended unique identifier
    eui64*: uint64             ## * lba format support
    lbaf*: array[16, INNER_C_STRUCT_3021822236]
    reserved6*: array[192, uint8]
    vendor_specific*: array[3712, uint8]


assert(sizeof(spdk_nvme_ns_data) == 4096, "Incorrect size")
## *
##  Reservation Type Encoding
##

type
  spdk_nvme_reservation_type* {.size: sizeof(cint).} = enum ##  0x00 - reserved
                                                       ##  Write Exclusive Reservation
    SPDK_NVME_RESERVE_WRITE_EXCLUSIVE = 0x00000001, ##  Exclusive Access Reservation
    SPDK_NVME_RESERVE_EXCLUSIVE_ACCESS = 0x00000002, ##  Write Exclusive - Registrants Only Reservation
    SPDK_NVME_RESERVE_WRITE_EXCLUSIVE_REG_ONLY = 0x00000003, ##  Exclusive Access - Registrants Only Reservation
    SPDK_NVME_RESERVE_EXCLUSIVE_ACCESS_REG_ONLY = 0x00000004, ##  Write Exclusive - All Registrants Reservation
    SPDK_NVME_RESERVE_WRITE_EXCLUSIVE_ALL_REGS = 0x00000005, ##  Exclusive Access - All Registrants Reservation
    SPDK_NVME_RESERVE_EXCLUSIVE_ACCESS_ALL_REGS = 0x00000006 ##  0x7-0xFF - Reserved


type
  spdk_nvme_reservation_acquire_data* = object
    crkey*: uint64             ## * current reservation key
    ## * preempt reservation key
    prkey*: uint64


assert(sizeof(spdk_nvme_reservation_acquire_data) == 16, "Incorrect size")
## *
##  Reservation Acquire action
##

type
  spdk_nvme_reservation_acquire_action* {.size: sizeof(cint).} = enum
    SPDK_NVME_RESERVE_ACQUIRE = 0x00000000, SPDK_NVME_RESERVE_PREEMPT = 0x00000001,
    SPDK_NVME_RESERVE_PREEMPT_ABORT = 0x00000002


#rivasiv c2nim wrappings are incorrect added  {.packed.}
type
  spdk_nvme_reservation_status_data*  {.packed.}  = object
    generation*: uint32        ## * reservation action generation counter
    ## * reservation type
    `type`*: uint8             ## * number of registered controllers
    nr_regctl*: uint16
    reserved1*: uint16         ## * persist through power loss state
    ptpl_state*: uint8
    reserved*: array[14, uint8]

assert(sizeof(spdk_nvme_reservation_status_data) == 24, "Incorrect size")


type
  INNER_C_STRUCT_4139932190* {.packed.} = object
    status* {.bitsize: 1.}: uint8
    reserved1* {.bitsize: 7.}: uint8

  spdk_nvme_reservation_ctrlr_data* {.packed.} = object
    ctrlr_id*: uint16          ## * reservation status
    rcsts*: INNER_C_STRUCT_4139932190
    reserved2*: array[5, uint8] ## * host identifier
    host_id*: uint64           ## * reservation key
    key*: uint64

assert(sizeof(spdk_nvme_reservation_ctrlr_data) == 24, "Incorrect size")

## *
##  Change persist through power loss state for
##   Reservation Register command
##

type
  spdk_nvme_reservation_register_cptpl* {.size: sizeof(cint).} = enum
    SPDK_NVME_RESERVE_PTPL_NO_CHANGES = 0x00000000,
    SPDK_NVME_RESERVE_PTPL_CLEAR_POWER_ON = 0x00000002,
    SPDK_NVME_RESERVE_PTPL_PERSIST_POWER_LOSS = 0x00000003


## *
##  Registration action for Reservation Register command
##

type
  spdk_nvme_reservation_register_action* {.size: sizeof(cint).} = enum
    SPDK_NVME_RESERVE_REGISTER_KEY = 0x00000000,
    SPDK_NVME_RESERVE_UNREGISTER_KEY = 0x00000001,
    SPDK_NVME_RESERVE_REPLACE_KEY = 0x00000002


type
  spdk_nvme_reservation_register_data* = object
    crkey*: uint64             ## * current reservation key
    ## * new reservation key
    nrkey*: uint64


assert(sizeof(spdk_nvme_reservation_register_data) == 16, "Incorrect size")
type
  spdk_nvme_reservation_key_data* = object
    crkey*: uint64             ## * current reservation key


assert(sizeof(spdk_nvme_reservation_key_data) == 8, "Incorrect size")
## *
##  Reservation Release action
##

type
  spdk_nvme_reservation_release_action* {.size: sizeof(cint).} = enum
    SPDK_NVME_RESERVE_RELEASE = 0x00000000, SPDK_NVME_RESERVE_CLEAR = 0x00000001


## *
##  Log page identifiers for SPDK_NVME_OPC_GET_LOG_PAGE
##

type
  spdk_nvme_log_page* {.size: sizeof(cint).} = enum ##  0x00 - reserved
                                               ## * Error information (mandatory) - \ref spdk_nvme_error_information_entry
    SPDK_NVME_LOG_ERROR = 0x00000001, ## * SMART / health information (mandatory) - \ref spdk_nvme_health_information_page
    SPDK_NVME_LOG_HEALTH_INFORMATION = 0x00000002, ## * Firmware slot information (mandatory) - \ref spdk_nvme_firmware_page
    SPDK_NVME_LOG_FIRMWARE_SLOT = 0x00000003, ## * Changed namespace list (optional)
    SPDK_NVME_LOG_CHANGED_NS_LIST = 0x00000004, ## * Command effects log (optional)
    SPDK_NVME_LOG_COMMAND_EFFECTS_LOG = 0x00000005, ##  0x06-0x6F - reserved
                                                 ## * Discovery(refer to the NVMe over Fabrics specification)
    SPDK_NVME_LOG_DISCOVERY = 0x00000070, ##  0x71-0x7f - reserved for NVMe over Fabrics
                                       ## * Reservation notification (optional)
    SPDK_NVME_LOG_RESERVATION_NOTIFICATION = 0x00000080 ##  0x81-0xBF - I/O command set specific
                                                     ##  0xC0-0xFF - vendor specific


## *
##  Error information log page (\ref SPDK_NVME_LOG_ERROR)
##

type
  spdk_nvme_error_information_entry* = object
    error_count*: uint64
    sqid*: uint16
    cid*: uint16
    status*: spdk_nvme_status
    error_location*: uint16
    lba*: uint64
    nsid*: uint32
    vendor_specific*: uint8
    reserved*: array[35, uint8]


assert(sizeof(spdk_nvme_error_information_entry) == 64, "Incorrect size")
type
  INNER_C_STRUCT_1748593372* = object
    available_spare* {.bitsize: 1.}: uint8
    temperature* {.bitsize: 1.}: uint8
    device_reliability* {.bitsize: 1.}: uint8
    read_only* {.bitsize: 1.}: uint8
    volatile_memory_backup* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 3.}: uint8

  spdk_nvme_critical_warning_state* = object {.union.}
    raw*: uint8
    bits*: INNER_C_STRUCT_1748593372


assert(sizeof(spdk_nvme_critical_warning_state) == 1, "Incorrect size")
## *
##  SMART / health information page (\ref SPDK_NVME_LOG_HEALTH_INFORMATION)
##


type
  spdk_nvme_health_information_page* {.packed.} = object
    critical_warning*: spdk_nvme_critical_warning_state
    temperature*: uint16
    available_spare*: uint8
    available_spare_threshold*: uint8
    percentage_used*: uint8
    reserved*: array[26, uint8] ##
                             ##  Note that the following are 128-bit values, but are
                             ##   defined as an array of 2 64-bit values.
                             ##
                             ##  Data Units Read is always in 512-byte units.
    data_units_read*: array[2, uint64] ##  Data Units Written is always in 512-byte units.
    data_units_written*: array[2, uint64] ##  For NVM command set, this includes Compare commands.
    host_read_commands*: array[2, uint64]
    host_write_commands*: array[2, uint64] ##  Controller Busy Time is reported in minutes.
    controller_busy_time*: array[2, uint64]
    power_cycles*: array[2, uint64]
    power_on_hours*: array[2, uint64]
    unsafe_shutdowns*: array[2, uint64]
    media_errors*: array[2, uint64]
    num_error_info_log_entries*: array[2, uint64]
    reserved2*: array[320, uint8]

assert(sizeof(spdk_nvme_health_information_page) == 512, "Incorrect size")

## *
##  Firmware slot information page (\ref SPDK_NVME_LOG_FIRMWARE_SLOT)
##

type
  INNER_C_STRUCT_3288450467* = object
    slot* {.bitsize: 3.}: uint8  ##  slot for current FW
    reserved* {.bitsize: 5.}: uint8

  spdk_nvme_firmware_page* = object
    afi*: INNER_C_STRUCT_3288450467
    reserved*: array[7, uint8]
    revision*: array[7, uint64] ##  revisions for 7 slots
    reserved2*: array[448, uint8]


assert(sizeof(spdk_nvme_firmware_page) == 512, "Incorrect size")
## *
##  Namespace attachment Type Encoding
##

type
  spdk_nvme_ns_attach_type* {.size: sizeof(cint).} = enum ##  Controller attach
    SPDK_NVME_NS_CTRLR_ATTACH = 0x00000000, ##  Controller detach
    SPDK_NVME_NS_CTRLR_DETACH = 0x00000001 ##  0x2-0xF - Reserved


## *
##  Namespace management Type Encoding
##

type
  spdk_nvme_ns_management_type* {.size: sizeof(cint).} = enum ##  Create
    SPDK_NVME_NS_MANAGEMENT_CREATE = 0x00000000, ##  Delete
    SPDK_NVME_NS_MANAGEMENT_DELETE = 0x00000001 ##  0x2-0xF - Reserved


type
  spdk_nvme_ns_list* = object
    ns_list*: array[1024, uint32]


assert(sizeof(spdk_nvme_ns_list) == 4096, "Incorrect size")
type
  spdk_nvme_ctrlr_list* = object
    ctrlr_count*: uint16
    ctrlr_list*: array[2047, uint16]


assert(sizeof(spdk_nvme_ctrlr_list) == 4096, "Incorrect size")
type
  spdk_nvme_secure_erase_setting* {.size: sizeof(cint).} = enum
    SPDK_NVME_FMT_NVM_SES_NO_SECURE_ERASE = 0x00000000,
    SPDK_NVME_FMT_NVM_SES_USER_DATA_ERASE = 0x00000001,
    SPDK_NVME_FMT_NVM_SES_CRYPTO_ERASE = 0x00000002


type
  spdk_nvme_pi_location* {.size: sizeof(cint).} = enum
    SPDK_NVME_FMT_NVM_PROTECTION_AT_TAIL = 0x00000000,
    SPDK_NVME_FMT_NVM_PROTECTION_AT_HEAD = 0x00000001


type
  spdk_nvme_pi_type* {.size: sizeof(cint).} = enum
    SPDK_NVME_FMT_NVM_PROTECTION_DISABLE = 0x00000000,
    SPDK_NVME_FMT_NVM_PROTECTION_TYPE1 = 0x00000001,
    SPDK_NVME_FMT_NVM_PROTECTION_TYPE2 = 0x00000002,
    SPDK_NVME_FMT_NVM_PROTECTION_TYPE3 = 0x00000003


type
  spdk_nvme_metadata_setting* {.size: sizeof(cint).} = enum
    SPDK_NVME_FMT_NVM_METADATA_TRANSFER_AS_BUFFER = 0x00000000,
    SPDK_NVME_FMT_NVM_METADATA_TRANSFER_AS_LBA = 0x00000001


type
  spdk_nvme_format* = object
    lbaf* {.bitsize: 4.}: uint32
    ms* {.bitsize: 1.}: uint32
    pi* {.bitsize: 3.}: uint32
    pil* {.bitsize: 1.}: uint32
    ses* {.bitsize: 3.}: uint32
    reserved* {.bitsize: 20.}: uint32


assert(sizeof(spdk_nvme_format) == 4, "Incorrect size")
type
  spdk_nvme_protection_info* = object
    guard*: uint16
    app_tag*: uint16
    ref_tag*: uint32


assert(sizeof(spdk_nvme_protection_info) == 8, "Incorrect size")
## * Parameters for SPDK_NVME_OPC_FIRMWARE_COMMIT cdw10: commit action

type
  spdk_nvme_fw_commit_action* {.size: sizeof(cint).} = enum ## *
                                                       ##  Downloaded image replaces the image specified by
                                                       ##  the Firmware Slot field. This image is not activated.
                                                       ##
    SPDK_NVME_FW_COMMIT_REPLACE_IMG = 0x00000000, ## *
                                               ##  Downloaded image replaces the image specified by
                                               ##  the Firmware Slot field. This image is activated at the next reset.
                                               ##
    SPDK_NVME_FW_COMMIT_REPLACE_AND_ENABLE_IMG = 0x00000001, ## *
                                                          ##  The image specified by the Firmware Slot field is
                                                          ##  activated at the next reset.
                                                          ##
    SPDK_NVME_FW_COMMIT_ENABLE_IMG = 0x00000002, ## *
                                              ##  The image specified by the Firmware Slot field is
                                              ##  requested to be activated immediately without reset.
                                              ##
    SPDK_NVME_FW_COMMIT_RUN_IMG = 0x00000003


## * Parameters for SPDK_NVME_OPC_FIRMWARE_COMMIT cdw10

type
  spdk_nvme_fw_commit* = object
    fs* {.bitsize: 3.}: uint32 ## *
                           ##  Firmware Slot. Specifies the firmware slot that shall be used for the
                           ##  Commit Action. The controller shall choose the firmware slot (slot 1 - 7)
                           ##  to use for the operation if the value specified is 0h.
                           ##
    ## *
    ##  Commit Action. Specifies the action that is taken on the image downloaded
    ##  with the Firmware Image Download command or on a previously downloaded and
    ##  placed image.
    ##
    ca* {.bitsize: 3.}: uint32
    reserved* {.bitsize: 26.}: uint32


assert(sizeof(spdk_nvme_fw_commit) == 4, "Incorrect size")
template spdk_nvme_cpl_is_error*(cpl: untyped): untyped =
  ((cpl).status.sc != 0 or (cpl).status.sct != 0)

## * Enable protection information checking of the Logical Block Reference Tag field

const
  SPDK_NVME_IO_FLAGS_PRCHK_REFTAG* = (1 shl 26)

## * Enable protection information checking of the Application Tag field

const
  SPDK_NVME_IO_FLAGS_PRCHK_APPTAG* = (1 shl 27)

## * Enable protection information checking of the Guard field

const
  SPDK_NVME_IO_FLAGS_PRCHK_GUARD* = (1 shl 28)

## * The protection information is stripped or inserted when set this bit

const
  SPDK_NVME_IO_FLAGS_PRACT* = (1 shl 29)
  SPDK_NVME_IO_FLAGS_FORCE_UNIT_ACCESS* = (1 shl 30)
  SPDK_NVME_IO_FLAGS_LIMITED_RETRY* = (1 shl 31)
