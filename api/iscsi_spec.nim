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
## *
##  \file
##  iSCSI specification definitions
##

const
  ISCSI_BHS_LEN* = 48
  ISCSI_DIGEST_LEN* = 4
  ISCSI_ALIGNMENT* = 4

const
  ISCSI_VERSION* = 0x00000000 ## * support version - RFC3720(10.12.4)

template ISCSI_ALIGN*(SIZE: untyped): untyped =
  (((SIZE) + (ISCSI_ALIGNMENT - 1)) and not (ISCSI_ALIGNMENT - 1))

const
  ISCSI_TEXT_MAX_VAL_LEN* = 8192  ## * for authentication key (non encoded 1024bytes) RFC3720(5.1/11.1.4)

## *
##  RFC 3720 5.1
##  If not otherwise specified, the maximum length of a simple-value
##  (not its encoded representation) is 255 bytes, not including the delimiter
##  (comma or zero byte).
##

const
  ISCSI_TEXT_MAX_SIMPLE_VAL_LEN* = 255
  ISCSI_TEXT_MAX_KEY_LEN* = 63

type
  iscsi_op* {.size: sizeof(cint).} = enum ##  Initiator opcodes
    ISCSI_OP_NOPOUT = 0x00000000, ISCSI_OP_SCSI = 0x00000001,
    ISCSI_OP_TASK = 0x00000002, ISCSI_OP_LOGIN = 0x00000003,
    ISCSI_OP_TEXT = 0x00000004, ISCSI_OP_SCSI_DATAOUT = 0x00000005,
    ISCSI_OP_LOGOUT = 0x00000006, ISCSI_OP_SNACK = 0x00000010,
    ISCSI_OP_VENDOR_1C = 0x0000001C, ISCSI_OP_VENDOR_1D = 0x0000001D, ISCSI_OP_VENDOR_1E = 0x0000001E, ##  Target opcodes
    ISCSI_OP_NOPIN = 0x00000020, ISCSI_OP_SCSI_RSP = 0x00000021,
    ISCSI_OP_TASK_RSP = 0x00000022, ISCSI_OP_LOGIN_RSP = 0x00000023,
    ISCSI_OP_TEXT_RSP = 0x00000024, ISCSI_OP_SCSI_DATAIN = 0x00000025,
    ISCSI_OP_LOGOUT_RSP = 0x00000026, ISCSI_OP_R2T = 0x00000031,
    ISCSI_OP_ASYNC = 0x00000032, ISCSI_OP_VENDOR_3C = 0x0000003C,
    ISCSI_OP_VENDOR_3D = 0x0000003D, ISCSI_OP_VENDOR_3E = 0x0000003E,
    ISCSI_OP_REJECT = 0x0000003F


type
  iscsi_task_func* {.size: sizeof(cint).} = enum
    ISCSI_TASK_FUNC_ABORT_TASK = 1, ISCSI_TASK_FUNC_ABORT_TASK_SET = 2,
    ISCSI_TASK_FUNC_CLEAR_ACA = 3, ISCSI_TASK_FUNC_CLEAR_TASK_SET = 4,
    ISCSI_TASK_FUNC_LOGICAL_UNIT_RESET = 5, ISCSI_TASK_FUNC_TARGET_WARM_RESET = 6,
    ISCSI_TASK_FUNC_TARGET_COLD_RESET = 7, ISCSI_TASK_FUNC_TASK_REASSIGN = 8


type
  iscsi_task_func_resp* {.size: sizeof(cint).} = enum
    ISCSI_TASK_FUNC_RESP_COMPLETE = 0, ISCSI_TASK_FUNC_RESP_TASK_NOT_EXIST = 1,
    ISCSI_TASK_FUNC_RESP_LUN_NOT_EXIST = 2,
    ISCSI_TASK_FUNC_RESP_TASK_STILL_ALLEGIANT = 3,
    ISCSI_TASK_FUNC_RESP_REASSIGNMENT_NOT_SUPPORTED = 4,
    ISCSI_TASK_FUNC_RESP_FUNC_NOT_SUPPORTED = 5,
    ISCSI_TASK_FUNC_RESP_AUTHORIZATION_FAILED = 6, ISCSI_TASK_FUNC_REJECTED = 255


type
  iscsi_bhs* = object
    opcode* {.bitsize: 6.}: uint8
    immediate* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 1.}: uint8
    flags*: uint8
    rsv*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    stat_sn*: uint32
    exp_stat_sn*: uint32
    max_stat_sn*: uint32
    res3*: array[12, uint8]


assert(sizeof(iscsi_bhs) == ISCSI_BHS_LEN, "ISCSI_BHS_LEN mismatch")
type
  iscsi_bhs_async* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x32
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    ffffffff*: uint32
    res3*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    async_event*: uint8
    async_vcode*: uint8
    param1*: uint16
    param2*: uint16
    param3*: uint16
    res4*: array[4, uint8]

  iscsi_bhs_login_req* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x03
    immediate* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 1.}: uint8
    flags*: uint8
    version_max*: uint8
    version_min*: uint8
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    isid*: array[6, uint8]
    tsih*: uint16
    itt*: uint32
    cid*: uint16
    res2*: uint16
    cmd_sn*: uint32
    exp_stat_sn*: uint32
    res3*: array[16, uint8]

  iscsi_bhs_login_rsp* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x23
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    version_max*: uint8
    version_act*: uint8
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    isid*: array[6, uint8]
    tsih*: uint16
    itt*: uint32
    res2*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    status_class*: uint8
    status_detail*: uint8
    res3*: array[10, uint8]

  iscsi_bhs_logout_req* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x06
    immediate* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 1.}: uint8
    reason*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    res2*: array[8, uint8]
    itt*: uint32
    cid*: uint16
    res3*: uint16
    cmd_sn*: uint32
    exp_stat_sn*: uint32
    res4*: array[16, uint8]

  iscsi_bhs_logout_resp* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x26
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    response*: uint8
    res*: uint8
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    res2*: array[8, uint8]
    itt*: uint32
    res3*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    res4*: uint32
    time_2_wait*: uint16
    time_2_retain*: uint16
    res5*: uint32

  iscsi_bhs_nop_in* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x20
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    res3*: array[12, uint8]

  iscsi_bhs_nop_out* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x00
    immediate* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 1.}: uint8
    flags*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    cmd_sn*: uint32
    exp_stat_sn*: uint32
    res4*: array[16, uint8]

  iscsi_bhs_r2t* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x31
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    rsv*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    r2t_sn*: uint32
    buffer_offset*: uint32
    desired_xfer_len*: uint32

  iscsi_bhs_reject* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x3f
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    reason*: uint8
    res*: uint8
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    res2*: array[8, uint8]
    ffffffff*: uint32
    res3*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    data_sn*: uint32
    res4*: array[8, uint8]

  iscsi_bhs_scsi_req* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x01
    immediate* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 1.}: uint8
    attribute* {.bitsize: 3.}: uint8
    reserved2* {.bitsize: 2.}: uint8
    write* {.bitsize: 1.}: uint8
    read* {.bitsize: 1.}: uint8
    final* {.bitsize: 1.}: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    expected_data_xfer_len*: uint32
    cmd_sn*: uint32
    exp_stat_sn*: uint32
    cdb*: array[16, uint8]

  iscsi_bhs_scsi_resp* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x21
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    response*: uint8
    status*: uint8
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    res4*: array[8, uint8]
    itt*: uint32
    snacktag*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    exp_data_sn*: uint32
    bi_read_res_cnt*: uint32
    res_cnt*: uint32

  iscsi_bhs_data_in* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x05
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    res*: uint8
    status*: uint8
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    data_sn*: uint32
    buffer_offset*: uint32
    res_cnt*: uint32

  iscsi_bhs_data_out* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x25
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    res3*: uint32
    exp_stat_sn*: uint32
    res4*: uint32
    data_sn*: uint32
    buffer_offset*: uint32
    res5*: uint32

  iscsi_bhs_snack_req* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x10
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    res5*: uint32
    exp_stat_sn*: uint32
    res6*: array[8, uint8]
    beg_run*: uint32
    run_len*: uint32

  iscsi_bhs_task_req* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x02
    immediate* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 1.}: uint8
    flags*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ref_task_tag*: uint32
    cmd_sn*: uint32
    exp_stat_sn*: uint32
    ref_cmd_sn*: uint32
    exp_data_sn*: uint32
    res5*: array[8, uint8]

  iscsi_bhs_task_resp* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x22
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    response*: uint8
    res*: uint8
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    res2*: array[8, uint8]
    itt*: uint32
    res3*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    res4*: array[12, uint8]

  iscsi_bhs_text_req* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x04
    immediate* {.bitsize: 1.}: uint8
    reserved* {.bitsize: 1.}: uint8
    flags*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    cmd_sn*: uint32
    exp_stat_sn*: uint32
    res3*: array[16, uint8]

  iscsi_bhs_text_resp* = object
    opcode* {.bitsize: 6.}: uint8 ##  opcode = 0x24
    reserved* {.bitsize: 2.}: uint8
    flags*: uint8
    res*: array[2, uint8]
    total_ahs_len*: uint8
    data_segment_len*: array[3, uint8]
    lun*: uint64
    itt*: uint32
    ttt*: uint32
    stat_sn*: uint32
    exp_cmd_sn*: uint32
    max_cmd_sn*: uint32
    res4*: array[12, uint8]


const
  ISCSI_FLAG_FINAL* = 0x00000080 ##  generic flags


##  login flags

const
  ISCSI_LOGIN_TRANSIT* = 0x00000080
  ISCSI_LOGIN_CONTINUE* = 0x00000040
  ISCSI_LOGIN_CURRENT_STAGE_MASK* = 0x0000000C
  ISCSI_LOGIN_CURRENT_STAGE_0* = 0x00000004
  ISCSI_LOGIN_CURRENT_STAGE_1* = 0x00000008
  ISCSI_LOGIN_CURRENT_STAGE_3* = 0x0000000C
  ISCSI_LOGIN_NEXT_STAGE_MASK* = 0x00000003
  ISCSI_LOGIN_NEXT_STAGE_0* = 0x00000001
  ISCSI_LOGIN_NEXT_STAGE_1* = 0x00000002
  ISCSI_LOGIN_NEXT_STAGE_3* = 0x00000003

##  text flags

const
  ISCSI_TEXT_CONTINUE* = 0x00000040

##  logout flags

const
  ISCSI_LOGOUT_REASON_MASK* = 0x0000007F

##  datain flags

const
  ISCSI_DATAIN_ACKNOLWEDGE* = 0x00000040
  ISCSI_DATAIN_OVERFLOW* = 0x00000004
  ISCSI_DATAIN_UNDERFLOW* = 0x00000002
  ISCSI_DATAIN_STATUS* = 0x00000001

##  SCSI resp flags

const
  ISCSI_SCSI_BIDI_OVERFLOW* = 0x00000010
  ISCSI_SCSI_BIDI_UNDERFLOW* = 0x00000008
  ISCSI_SCSI_OVERFLOW* = 0x00000004
  ISCSI_SCSI_UNDERFLOW* = 0x00000002

##  SCSI task flags

const
  ISCSI_TASK_FUNCTION_MASK* = 0x0000007F

##  Reason for Reject

const
  ISCSI_REASON_RESERVED* = 0x00000001
  ISCSI_REASON_DATA_DIGEST_ERROR* = 0x00000002
  ISCSI_REASON_DATA_SNACK_REJECT* = 0x00000003
  ISCSI_REASON_PROTOCOL_ERROR* = 0x00000004
  ISCSI_REASON_CMD_NOT_SUPPORTED* = 0x00000005
  ISCSI_REASON_IMM_CMD_REJECT* = 0x00000006
  ISCSI_REASON_TASK_IN_PROGRESS* = 0x00000007
  ISCSI_REASON_INVALID_SNACK* = 0x00000008
  ISCSI_REASON_INVALID_PDU_FIELD* = 0x00000009
  ISCSI_REASON_LONG_OPERATION_REJECT* = 0x0000000A
  ISCSI_REASON_NEGOTIATION_RESET* = 0x0000000B
  ISCSI_REASON_WAIT_FOR_RESET* = 0x0000000C
  ISCSI_FLAG_SNACK_TYPE_DATA* = 0
  ISCSI_FLAG_SNACK_TYPE_R2T* = 0
  ISCSI_FLAG_SNACK_TYPE_STATUS* = 1
  ISCSI_FLAG_SNACK_TYPE_DATA_ACK* = 2
  ISCSI_FLAG_SNACK_TYPE_RDATA* = 3
  ISCSI_FLAG_SNACK_TYPE_MASK* = 0x0000000F

type
  iscsi_ahs* = object
    ahs_len*: array[2, uint8]   ##  0-3
    ahs_type*: uint8
    ahs_specific1*: uint8      ##  4-x
    ahs_specific2*: ptr uint8


template ISCSI_BHS_LOGIN_GET_TBIT*(X: untyped): untyped =
  (not not (X and ISCSI_LOGIN_TRANSIT))

template ISCSI_BHS_LOGIN_GET_CBIT*(X: untyped): untyped =
  (not not (X and ISCSI_LOGIN_CONTINUE))

template ISCSI_BHS_LOGIN_GET_CSG*(X: untyped): untyped =
  ((X and ISCSI_LOGIN_CURRENT_STAGE_MASK) shr 2)

template ISCSI_BHS_LOGIN_GET_NSG*(X: untyped): untyped =
  (X and ISCSI_LOGIN_NEXT_STAGE_MASK)

const
  ISCSI_CLASS_SUCCESS* = 0x00000000
  ISCSI_CLASS_REDIRECT* = 0x00000001
  ISCSI_CLASS_INITIATOR_ERROR* = 0x00000002
  ISCSI_CLASS_TARGET_ERROR* = 0x00000003

##  Class (Success) detailed info: 0

const
  ISCSI_LOGIN_ACCEPT* = 0x00000000

##  Class (Redirection) detailed info: 1

const
  ISCSI_LOGIN_TARGET_TEMPORARILY_MOVED* = 0x00000001
  ISCSI_LOGIN_TARGET_PERMANENTLY_MOVED* = 0x00000002

##  Class (Initiator Error) detailed info: 2

const
  ISCSI_LOGIN_INITIATOR_ERROR* = 0x00000000
  ISCSI_LOGIN_AUTHENT_FAIL* = 0x00000001
  ISCSI_LOGIN_AUTHORIZATION_FAIL* = 0x00000002
  ISCSI_LOGIN_TARGET_NOT_FOUND* = 0x00000003
  ISCSI_LOGIN_TARGET_REMOVED* = 0x00000004
  ISCSI_LOGIN_UNSUPPORTED_VERSION* = 0x00000005
  ISCSI_LOGIN_TOO_MANY_CONNECTIONS* = 0x00000006
  ISCSI_LOGIN_MISSING_PARMS* = 0x00000007
  ISCSI_LOGIN_CONN_ADD_FAIL* = 0x00000008
  ISCSI_LOGIN_NOT_SUPPORTED_SESSION_TYPE* = 0x00000009
  ISCSI_LOGIN_NO_SESSION* = 0x0000000A
  ISCSI_LOGIN_INVALID_LOGIN_REQUEST* = 0x0000000B

##  Class (Target Error) detailed info: 3

const
  ISCSI_LOGIN_STATUS_TARGET_ERROR* = 0x00000000
  ISCSI_LOGIN_STATUS_SERVICE_UNAVAILABLE* = 0x00000001
  ISCSI_LOGIN_STATUS_NO_RESOURCES* = 0x00000002
