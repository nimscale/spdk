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
##  I/OAT specification definitions
##

const
  SPDK_IOAT_INTRCTRL_MASTER_INT_EN* = 0x00000001
  SPDK_IOAT_VER_3_0* = 0x00000030
  SPDK_IOAT_VER_3_3* = 0x00000033

##  DMA Channel Registers

const
  SPDK_IOAT_CHANCTRL_CHANNEL_PRIORITY_MASK* = 0x0000F000
  SPDK_IOAT_CHANCTRL_COMPL_DCA_EN* = 0x00000200
  SPDK_IOAT_CHANCTRL_CHANNEL_IN_USE* = 0x00000100
  SPDK_IOAT_CHANCTRL_DESCRIPTOR_ADDR_SNOOP_CONTROL* = 0x00000020
  SPDK_IOAT_CHANCTRL_ERR_INT_EN* = 0x00000010
  SPDK_IOAT_CHANCTRL_ANY_ERR_ABORT_EN* = 0x00000008
  SPDK_IOAT_CHANCTRL_ERR_COMPLETION_EN* = 0x00000004
  SPDK_IOAT_CHANCTRL_INT_REARM* = 0x00000001

##  DMA Channel Capabilities

const
  SPDK_IOAT_DMACAP_PB* = (1 shl 0)
  SPDK_IOAT_DMACAP_DCA* = (1 shl 4)
  SPDK_IOAT_DMACAP_BFILL* = (1 shl 6)
  SPDK_IOAT_DMACAP_XOR* = (1 shl 8)
  SPDK_IOAT_DMACAP_PQ* = (1 shl 9)
  SPDK_IOAT_DMACAP_DMA_DIF* = (1 shl 10)

type
  spdk_ioat_registers* {.packed.} = object
    chancnt*: uint8            ## __attribute__((packed))
    xfercap*: uint8
    genctrl*: uint8
    intrctrl*: uint8
    attnstatus*: uint32
    cbver*: uint8              ##  0x08
    reserved4*: array[0x00000003, uint8] ##  0x09
    intrdelay*: uint16         ##  0x0C
    cs_status*: uint16         ##  0x0E
    dmacapability*: uint32     ##  0x10
    reserved5*: array[0x0000006C, uint8] ##  0x14
    chanctrl*: uint16          ##  0x80
    reserved6*: array[0x00000002, uint8] ##  0x82
    chancmd*: uint8            ##  0x84
    reserved3*: array[1, uint8] ##  0x85
    dmacount*: uint16          ##  0x86
    chansts*: uint64           ##  0x88
    chainaddr*: uint64         ##  0x90
    chancmp*: uint64           ##  0x98
    reserved2*: array[0x00000008, uint8] ##  0xA0
    chanerr*: uint32           ##  0xA8
    chanerrmask*: uint32       ##  0xAC


const
  SPDK_IOAT_CHANCMD_RESET* = 0x00000020
  SPDK_IOAT_CHANCMD_SUSPEND* = 0x00000004
  SPDK_IOAT_CHANSTS_STATUS* = 0x00000007
  SPDK_IOAT_CHANSTS_ACTIVE* = 0x00000000
  SPDK_IOAT_CHANSTS_IDLE* = 0x00000001
  SPDK_IOAT_CHANSTS_SUSPENDED* = 0x00000002
  SPDK_IOAT_CHANSTS_HALTED* = 0x00000003
  SPDK_IOAT_CHANSTS_ARMED* = 0x00000004
  SPDK_IOAT_CHANSTS_UNAFFILIATED_ERROR* = 0x00000008
  SPDK_IOAT_CHANSTS_SOFT_ERROR* = 0x00000010
  SPDK_IOAT_CHANSTS_COMPLETED_DESCRIPTOR_MASK* = (not 0x0000003F)
  SPDK_IOAT_CHANCMP_ALIGN* = 8

type
  INNER_C_STRUCT_1734912267* = object
    int_enable* {.bitsize: 1.}: uint32
    src_snoop_disable* {.bitsize: 1.}: uint32
    dest_snoop_disable* {.bitsize: 1.}: uint32
    completion_update* {.bitsize: 1.}: uint32
    fence* {.bitsize: 1.}: uint32
    reserved2* {.bitsize: 1.}: uint32
    src_page_break* {.bitsize: 1.}: uint32
    dest_page_break* {.bitsize: 1.}: uint32
    bundle* {.bitsize: 1.}: uint32
    dest_dca* {.bitsize: 1.}: uint32
    hint* {.bitsize: 1.}: uint32
    reserved* {.bitsize: 13.}: uint32
    op* {.bitsize: 8.}: uint32

  INNER_C_UNION_173737868* = object {.union.}
    control_raw*: uint32
    control*: INNER_C_STRUCT_1734912267

  spdk_ioat_generic_hw_desc* = object
    size*: uint32
    u*: INNER_C_UNION_173737868
    src_addr*: uint64
    dest_addr*: uint64
    next*: uint64
    op_specific*: array[4, uint64]

  INNER_C_STRUCT_2031256338* = object
    int_enable* {.bitsize: 1.}: uint32
    src_snoop_disable* {.bitsize: 1.}: uint32
    dest_snoop_disable* {.bitsize: 1.}: uint32
    completion_update* {.bitsize: 1.}: uint32
    fence* {.bitsize: 1.}: uint32
    null* {.bitsize: 1.}: uint32
    src_page_break* {.bitsize: 1.}: uint32
    dest_page_break* {.bitsize: 1.}: uint32
    bundle* {.bitsize: 1.}: uint32
    dest_dca* {.bitsize: 1.}: uint32
    hint* {.bitsize: 1.}: uint32
    reserved* {.bitsize: 13.}: uint32
    op* {.bitsize: 8.}: uint32

  INNER_C_UNION_2841422344* = object {.union.}
    control_raw*: uint32
    control*: INNER_C_STRUCT_2031256338

  spdk_ioat_dma_hw_desc* = object
    size*: uint32
    u*: INNER_C_UNION_2841422344
    src_addr*: uint64
    dest_addr*: uint64
    next*: uint64
    reserved*: uint64
    reserved2*: uint64
    user1*: uint64
    user2*: uint64


const
  SPDK_IOAT_OP_COPY* = 0x00000000

type
  INNER_C_STRUCT_3796835337* = object
    int_enable* {.bitsize: 1.}: uint32
    reserved* {.bitsize: 1.}: uint32
    dest_snoop_disable* {.bitsize: 1.}: uint32
    completion_update* {.bitsize: 1.}: uint32
    fence* {.bitsize: 1.}: uint32
    reserved2* {.bitsize: 2.}: uint32
    dest_page_break* {.bitsize: 1.}: uint32
    bundle* {.bitsize: 1.}: uint32
    reserved3* {.bitsize: 15.}: uint32
    op* {.bitsize: 8.}: uint32

  INNER_C_UNION_2235660938* = object {.union.}
    control_raw*: uint32
    control*: INNER_C_STRUCT_3796835337

  spdk_ioat_fill_hw_desc* = object
    size*: uint32
    u*: INNER_C_UNION_2235660938
    src_data*: uint64
    dest_addr*: uint64
    next*: uint64
    reserved*: uint64
    next_dest_addr*: uint64
    user1*: uint64
    user2*: uint64


const
  SPDK_IOAT_OP_FILL* = 0x00000001

type
  INNER_C_STRUCT_1359386510* = object
    int_enable* {.bitsize: 1.}: uint32
    src_snoop_disable* {.bitsize: 1.}: uint32
    dest_snoop_disable* {.bitsize: 1.}: uint32
    completion_update* {.bitsize: 1.}: uint32
    fence* {.bitsize: 1.}: uint32
    src_count* {.bitsize: 3.}: uint32
    bundle* {.bitsize: 1.}: uint32
    dest_dca* {.bitsize: 1.}: uint32
    hint* {.bitsize: 1.}: uint32
    reserved* {.bitsize: 13.}: uint32
    op* {.bitsize: 8.}: uint32

  INNER_C_UNION_2169552516* = object {.union.}
    control_raw*: uint32
    control*: INNER_C_STRUCT_1359386510

  spdk_ioat_xor_hw_desc* = object
    size*: uint32
    u*: INNER_C_UNION_2169552516
    src_addr*: uint64
    dest_addr*: uint64
    next*: uint64
    src_addr2*: uint64
    src_addr3*: uint64
    src_addr4*: uint64
    src_addr5*: uint64


## spdk_ioat_xor_hw_desc.u.control.op

const
  SPDK_IOAT_OP_XOR* = 0x00000087
  SPDK_IOAT_OP_XOR_VAL* = 0x00000088

type
  spdk_ioat_xor_ext_hw_desc* = object
    src_addr6*: uint64
    src_addr7*: uint64
    src_addr8*: uint64
    next*: uint64
    reserved*: array[4, uint64]

  INNER_C_STRUCT_2432842377* = object
    int_enable* {.bitsize: 1.}: uint32
    src_snoop_disable* {.bitsize: 1.}: uint32
    dest_snoop_disable* {.bitsize: 1.}: uint32
    completion_update* {.bitsize: 1.}: uint32
    fence* {.bitsize: 1.}: uint32
    src_count* {.bitsize: 3.}: uint32
    bundle* {.bitsize: 1.}: uint32
    dest_dca* {.bitsize: 1.}: uint32
    hint* {.bitsize: 1.}: uint32
    p_disable* {.bitsize: 1.}: uint32
    q_disable* {.bitsize: 1.}: uint32
    reserved* {.bitsize: 11.}: uint32
    op* {.bitsize: 8.}: uint32

  INNER_C_UNION_871667978* = object {.union.}
    control_raw*: uint32
    control*: INNER_C_STRUCT_2432842377

  spdk_ioat_pq_hw_desc* = object
    size*: uint32
    u*: INNER_C_UNION_871667978
    src_addr*: uint64
    p_addr*: uint64
    next*: uint64
    src_addr2*: uint64
    src_addr3*: uint64
    coef*: array[8, uint8]
    q_addr*: uint64


## spdk_ioat_pq_hw_desc.u.control.op

const
  SPDK_IOAT_OP_PQ* = 0x00000089
  SPDK_IOAT_OP_PQ_VAL* = 0x0000008A

type
  spdk_ioat_pq_ext_hw_desc* = object
    src_addr4*: uint64
    src_addr5*: uint64
    src_addr6*: uint64
    next*: uint64
    src_addr7*: uint64
    src_addr8*: uint64
    reserved*: array[2, uint64]

  INNER_C_STRUCT_232852362* = object
    int_enable* {.bitsize: 1.}: uint32
    src_snoop_disable* {.bitsize: 1.}: uint32
    dest_snoop_disable* {.bitsize: 1.}: uint32
    completion_update* {.bitsize: 1.}: uint32
    fence* {.bitsize: 1.}: uint32
    src_cnt* {.bitsize: 3.}: uint32
    bundle* {.bitsize: 1.}: uint32
    dest_dca* {.bitsize: 1.}: uint32
    hint* {.bitsize: 1.}: uint32
    p_disable* {.bitsize: 1.}: uint32
    q_disable* {.bitsize: 1.}: uint32
    reserved* {.bitsize: 3.}: uint32
    coef* {.bitsize: 8.}: uint32
    op* {.bitsize: 8.}: uint32

  INNER_C_UNION_1043018368* = object {.union.}
    control_raw*: uint32
    control*: INNER_C_STRUCT_232852362

  spdk_ioat_pq_update_hw_desc* = object
    size*: uint32
    u*: INNER_C_UNION_1043018368
    src_addr*: uint64
    p_addr*: uint64
    next*: uint64
    src_addr2*: uint64
    p_src*: uint64
    q_src*: uint64
    q_addr*: uint64


## spdk_ioat_pq_update_hw_desc.u.control.op

const
  SPDK_IOAT_OP_PQ_UP* = 0x0000008B

type
  spdk_ioat_raw_hw_desc* = object
    field*: array[8, uint64]

  spdk_ioat_hw_desc* = object {.union.}
    raw*: spdk_ioat_raw_hw_desc
    `generic`*: spdk_ioat_generic_hw_desc
    dma*: spdk_ioat_dma_hw_desc
    fill*: spdk_ioat_fill_hw_desc
    `xor`*: spdk_ioat_xor_hw_desc
    xor_ext*: spdk_ioat_xor_ext_hw_desc
    pq*: spdk_ioat_pq_hw_desc
    pq_ext*: spdk_ioat_pq_ext_hw_desc
    pq_update*: spdk_ioat_pq_update_hw_desc


assert(sizeof(spdk_ioat_hw_desc) == 64, "incorrect spdk_ioat_hw_desc layout")
