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
  nvme_spec

## *
##  \file
##
##

type
  spdk_nvmf_capsule_cmd* = object
    opcode*: uint8
    reserved1*: uint8
    cid*: uint16
    fctype*: uint8
    reserved2*: array[35, uint8]
    fabric_specific*: array[24, uint8]


assert(sizeof(spdk_nvmf_capsule_cmd) == 64, "Incorrect size")
##  Fabric Command Set

const
  SPDK_NVME_OPC_FABRIC* = 0x0000007F

type
  spdk_nvmf_fabric_cmd_types* {.size: sizeof(cint).} = enum
    SPDK_NVMF_FABRIC_COMMAND_PROPERTY_SET = 0x00000000,
    SPDK_NVMF_FABRIC_COMMAND_CONNECT = 0x00000001,
    SPDK_NVMF_FABRIC_COMMAND_PROPERTY_GET = 0x00000004,
    SPDK_NVMF_FABRIC_COMMAND_AUTHENTICATION_SEND = 0x00000005,
    SPDK_NVMF_FABRIC_COMMAND_AUTHENTICATION_RECV = 0x00000006,
    SPDK_NVMF_FABRIC_COMMAND_START_VENDOR_SPECIFIC = 0x000000C0


type
  spdk_nvmf_fabric_cmd_status_code* {.size: sizeof(cint).} = enum
    SPDK_NVMF_FABRIC_SC_INCOMPATIBLE_FORMAT = 0x00000080,
    SPDK_NVMF_FABRIC_SC_CONTROLLER_BUSY = 0x00000081,
    SPDK_NVMF_FABRIC_SC_INVALID_PARAM = 0x00000082,
    SPDK_NVMF_FABRIC_SC_RESTART_DISCOVERY = 0x00000083,
    SPDK_NVMF_FABRIC_SC_INVALID_HOST = 0x00000084,
    SPDK_NVMF_FABRIC_SC_LOG_RESTART_DISCOVERY = 0x00000090,
    SPDK_NVMF_FABRIC_SC_AUTH_REQUIRED = 0x00000091


## *
##  RDMA Queue Pair service types
##

type
  spdk_nvmf_rdma_qptype* {.size: sizeof(cint).} = enum ## * Reliable connected
    SPDK_NVMF_RDMA_QPTYPE_RELIABLE_CONNECTED = 0x00000001, ## * Reliable datagram
    SPDK_NVMF_RDMA_QPTYPE_RELIABLE_DATAGRAM = 0x00000002


## *
##  RDMA provider types
##

type
  spdk_nvmf_rdma_prtype* {.size: sizeof(cint).} = enum ## * No provider specified
    SPDK_NVMF_RDMA_PRTYPE_NONE = 0x00000001, ## * InfiniBand
    SPDK_NVMF_RDMA_PRTYPE_IB = 0x00000002, ## * RoCE v1
    SPDK_NVMF_RDMA_PRTYPE_ROCE = 0x00000003, ## * RoCE v2
    SPDK_NVMF_RDMA_PRTYPE_ROCE2 = 0x00000004, ## * iWARP
    SPDK_NVMF_RDMA_PRTYPE_IWARP = 0x00000005


## *
##  RDMA connection management service types
##

type
  spdk_nvmf_rdma_cms* {.size: sizeof(cint).} = enum ## * Sockets based endpoint addressing
    SPDK_NVMF_RDMA_CMS_RDMA_CM = 0x00000001


## *
##  NVMe over Fabrics transport types
##

type
  spdk_nvmf_trtype* {.size: sizeof(cint).} = enum ## * RDMA
    SPDK_NVMF_TRTYPE_RDMA = 0x00000001, ## * Fibre Channel
    SPDK_NVMF_TRTYPE_FC = 0x00000002, ## * Intra-host transport (loopback)
    SPDK_NVMF_TRTYPE_INTRA_HOST = 0x000000FE


## *
##  Address family types
##

type
  spdk_nvmf_adrfam* {.size: sizeof(cint).} = enum ## * IPv4 (AF_INET)
    SPDK_NVMF_ADRFAM_IPV4 = 0x00000001, ## * IPv6 (AF_INET6)
    SPDK_NVMF_ADRFAM_IPV6 = 0x00000002, ## * InfiniBand (AF_IB)
    SPDK_NVMF_ADRFAM_IB = 0x00000003, ## * Fibre Channel address family
    SPDK_NVMF_ADRFAM_FC = 0x00000004, ## * Intra-host transport (loopback)
    SPDK_NVMF_ADRFAM_INTRA_HOST = 0x000000FE


## *
##  NVM subsystem types
##

type
  spdk_nvmf_subtype* {.size: sizeof(cint).} = enum ## * Discovery type for NVM subsystem
    SPDK_NVMF_SUBTYPE_DISCOVERY = 0x00000001, ## * NVMe type for NVM subsystem
    SPDK_NVMF_SUBTYPE_NVME = 0x00000002


## *
##  Connections shall be made over a fabric secure channel
##

type
  spdk_nvmf_treq_secure_channel* {.size: sizeof(cint).} = enum ## * Not specified
    SPDK_NVMF_TREQ_SECURE_CHANNEL_NOT_SPECIFIED = 0x00000000, ## * Required
    SPDK_NVMF_TREQ_SECURE_CHANNEL_REQUIRED = 0x00000001, ## * Not required
    SPDK_NVMF_TREQ_SECURE_CHANNEL_NOT_REQUIRED = 0x00000002


type
  spdk_nvmf_fabric_auth_recv_cmd* = object
    opcode*: uint8
    reserved1*: uint8
    cid*: uint16
    fctype*: uint8             ##  NVMF_FABRIC_COMMAND_AUTHENTICATION_RECV (0x06)
    reserved2*: array[19, uint8]
    sgl1*: spdk_nvme_sgl_descriptor
    reserved3*: uint8
    spsp0*: uint8
    spsp1*: uint8
    secp*: uint8
    al*: uint32
    reserved4*: array[16, uint8]


assert(sizeof(spdk_nvmf_fabric_auth_recv_cmd) == 64, "Incorrect size")
type
  spdk_nvmf_fabric_auth_send_cmd* = object
    opcode*: uint8
    reserved1*: uint8
    cid*: uint16
    fctype*: uint8             ##  NVMF_FABRIC_COMMAND_AUTHENTICATION_SEND (0x05)
    reserved2*: array[19, uint8]
    sgl1*: spdk_nvme_sgl_descriptor
    reserved3*: uint8
    spsp0*: uint8
    spsp1*: uint8
    secp*: uint8
    tl*: uint32
    reserved4*: array[16, uint8]


assert(sizeof(spdk_nvmf_fabric_auth_send_cmd) == 64, "Incorrect size")
type
  spdk_nvmf_fabric_connect_data* = object
    hostid*: array[16, uint8]
    cntlid*: uint16
    reserved5*: array[238, uint8]
    subnqn*: array[256, uint8]
    hostnqn*: array[256, uint8]
    reserved6*: array[256, uint8]


assert(sizeof(spdk_nvmf_fabric_connect_data) == 1024, "Incorrect size")
type
  spdk_nvmf_fabric_connect_cmd* = object
    opcode*: uint8
    reserved1*: uint8
    cid*: uint16
    fctype*: uint8
    reserved2*: array[19, uint8]
    sgl1*: spdk_nvme_sgl_descriptor
    recfmt*: uint16            ##  Connect Record Format
    qid*: uint16               ##  Queue Identifier
    sqsize*: uint16            ##  Submission Queue Size
    cattr*: uint8              ##  queue attributes
    reserved3*: uint8
    kato*: uint32              ##  keep alive timeout
    reserved4*: array[12, uint8]


assert(sizeof(spdk_nvmf_fabric_connect_cmd) == 64, "Incorrect size")
type
  INNER_C_STRUCT_4280484533* = object
    cntlid*: uint16
    authreq*: uint16

  INNER_C_STRUCT_3888453232* = object
    ipo*: uint16
    iattr*: uint8
    reserved*: uint8

  INNER_C_UNION_1960971522* = object {.union.}
    success*: INNER_C_STRUCT_4280484533
    invalid*: INNER_C_STRUCT_3888453232
    raw*: uint32

  spdk_nvmf_fabric_connect_rsp* = object
    status_code_specific*: INNER_C_UNION_1960971522
    reserved0*: uint32
    sqhd*: uint16
    reserved1*: uint16
    cid*: uint16
    status*: spdk_nvme_status


assert(sizeof(spdk_nvmf_fabric_connect_rsp) == 16, "Incorrect size")
const
  SPDK_NVMF_PROP_SIZE_4* = 0
  SPDK_NVMF_PROP_SIZE_8* = 1

type
  INNER_C_STRUCT_24288834* = object
    size* {.bitsize: 2.}: uint8
    reserved* {.bitsize: 6.}: uint8

  spdk_nvmf_fabric_prop_get_cmd* = object
    opcode*: uint8
    reserved1*: uint8
    cid*: uint16
    fctype*: uint8
    reserved2*: array[35, uint8]
    attrib*: INNER_C_STRUCT_24288834
    reserved3*: array[3, uint8]
    ofst*: uint32
    reserved4*: array[16, uint8]


assert(sizeof(spdk_nvmf_fabric_prop_get_cmd) == 64, "Incorrect size")
type
  INNER_C_STRUCT_937454826* = object
    low*: uint32
    high*: uint32

  INNER_C_UNION_3671247723* = object {.union.}
    u64*: uint64
    u32*: INNER_C_STRUCT_937454826

  spdk_nvmf_fabric_prop_get_rsp* = object
    value*: INNER_C_UNION_3671247723
    sqhd*: uint16
    reserved0*: uint16
    cid*: uint16
    status*: spdk_nvme_status


assert(sizeof(spdk_nvmf_fabric_prop_get_rsp) == 16, "Incorrect size")
type
  INNER_C_STRUCT_11233036* = object
    size* {.bitsize: 2.}: uint8
    reserved* {.bitsize: 6.}: uint8

  INNER_C_STRUCT_2794973295* = object
    low*: uint32
    high*: uint32

  INNER_C_UNION_1233798896* = object {.union.}
    u64*: uint64
    u32*: INNER_C_STRUCT_2794973295

  spdk_nvmf_fabric_prop_set_cmd* = object
    opcode*: uint8
    reserved0*: uint8
    cid*: uint16
    fctype*: uint8
    reserved1*: array[35, uint8]
    attrib*: INNER_C_STRUCT_11233036
    reserved2*: array[3, uint8]
    ofst*: uint32
    value*: INNER_C_UNION_1233798896
    reserved4*: array[8, uint8]


assert(sizeof(spdk_nvmf_fabric_prop_set_cmd) == 64, "Incorrect size")
const
  SPDK_NVMF_NQN_MAX_LEN* = 223
  SPDK_NVMF_DISCOVERY_NQN* = "nqn.2014-08.org.nvmexpress.discovery"

## * RDMA transport-specific address subtype

type
  spdk_nvmf_rdma_transport_specific_address_subtype* = object
    rdma_qptype*: uint8        ## * RDMA QP service type (\ref spdk_nvmf_rdma_qptype)
    ## * RDMA provider type (\ref spdk_nvmf_rdma_prtype)
    rdma_prtype*: uint8        ## * RDMA connection management service (\ref spdk_nvmf_rdma_cms)
    rdma_cms*: uint8
    reserved0*: array[5, uint8] ## * RDMA partition key for AF_IB
    rdma_pkey*: uint16
    reserved2*: array[246, uint8]


assert(sizeof(spdk_nvmf_rdma_transport_specific_address_subtype) == 256,
       "Incorrect size")
## * Transport-specific address subtype

type
  spdk_nvmf_transport_specific_address_subtype* = object {.union.}
    raw*: array[256, uint8]     ## * RDMA
    rdma*: spdk_nvmf_rdma_transport_specific_address_subtype


assert(sizeof(spdk_nvmf_transport_specific_address_subtype) == 256,
       "Incorrect size")
## *
##  Discovery Log Page entry
##

type
  INNER_C_STRUCT_1163853123* = object
    secure_channel* {.bitsize: 2.}: uint8 ## * Secure channel requirements (\ref spdk_nvmf_treq_secure_channel)
    reserved* {.bitsize: 6.}: uint8

  spdk_nvmf_discovery_log_page_entry* = object
    trtype*: uint8             ## * Transport type (\ref spdk_nvmf_trtype)
    ## * Address family (\ref spdk_nvmf_adrfam)
    adrfam*: uint8             ## * Subsystem type (\ref spdk_nvmf_subtype)
    subtype*: uint8            ## * Transport requirements
    treq*: INNER_C_STRUCT_1163853123 ## * NVM subsystem port ID
    portid*: uint16            ## * Controller ID
    cntlid*: uint16            ## * Admin max SQ size
    asqsz*: uint16
    reserved0*: array[22, uint8] ## * Transport service identifier
    trsvcid*: array[32, uint8]
    reserved1*: array[192, uint8] ## * NVM subsystem qualified name
    subnqn*: array[256, uint8]  ## * Transport address
    traddr*: array[256, uint8]  ## * Transport-specific address subtype
    tsas*: spdk_nvmf_transport_specific_address_subtype


assert(sizeof(spdk_nvmf_discovery_log_page_entry) == 1024, "Incorrect size")
type
  spdk_nvmf_discovery_log_page* = object
    genctr*: uint64
    numrec*: uint64
    recfmt*: uint16
    reserved0*: array[1006, uint8]
    entries*: array[0, spdk_nvmf_discovery_log_page_entry]


assert(sizeof(spdk_nvmf_discovery_log_page) == 1024, "Incorrect size")
##  RDMA Fabric specific definitions below

const
  SPDK_NVME_SGL_SUBTYPE_INVALIDATE_KEY* = 0x0000000F

type
  spdk_nvmf_rdma_request_private_data* = object
    recfmt*: uint16            ##  record format
    qid*: uint16               ##  queue id
    hrqsize*: uint16           ##  host receive queue size
    hsqsize*: uint16           ##  host send queue size
    reserved*: array[24, uint8]


assert(sizeof(spdk_nvmf_rdma_request_private_data) == 32, "Incorrect size")
type
  spdk_nvmf_rdma_accept_private_data* = object
    recfmt*: uint16            ##  record format
    crqsize*: uint16           ##  controller receive queue size
    reserved*: array[28, uint8]


assert(sizeof(spdk_nvmf_rdma_accept_private_data) == 32, "Incorrect size")
type
  spdk_nvmf_rdma_reject_private_data* = object
    recfmt*: uint16            ##  record format
    status*: spdk_nvme_status


assert(sizeof(spdk_nvmf_rdma_reject_private_data) == 4, "Incorrect size")
type
  spdk_nvmf_rdma_private_data* = object {.union.}
    pd_request*: spdk_nvmf_rdma_request_private_data
    pd_accept*: spdk_nvmf_rdma_accept_private_data
    pd_reject*: spdk_nvmf_rdma_reject_private_data


assert(sizeof(spdk_nvmf_rdma_private_data) == 32, "Incorrect size")
type
  spdk_nvmf_rdma_transport_errors* {.size: sizeof(cint).} = enum
    SPDK_NVMF_RDMA_ERROR_INVALID_PRIVATE_DATA_LENGTH = 0x00000001,
    SPDK_NVMF_RDMA_ERROR_INVALID_RECFMT = 0x00000002,
    SPDK_NVMF_RDMA_ERROR_INVALID_QID = 0x00000003,
    SPDK_NVMF_RDMA_ERROR_INVALID_HSQSIZE = 0x00000004,
    SPDK_NVMF_RDMA_ERROR_INVALID_HRQSIZE = 0x00000005,
    SPDK_NVMF_RDMA_ERROR_NO_RESOURCES = 0x00000006,
    SPDK_NVMF_RDMA_ERROR_INVALID_IRD = 0x00000007,
    SPDK_NVMF_RDMA_ERROR_INVALID_ORD = 0x00000008

