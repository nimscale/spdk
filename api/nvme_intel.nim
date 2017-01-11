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
##  Intel NVMe vendor-specific definitions
##
##  Reference:
##  http://www.intel.com/content/dam/www/public/us/en/documents/product-specifications/ssd-dc-p3700-spec.pdf
##

type
  spdk_nvme_intel_feat* {.size: sizeof(cint).} = enum
    SPDK_NVME_INTEL_FEAT_MAX_LBA = 0x000000C1,
    SPDK_NVME_INTEL_FEAT_NATIVE_MAX_LBA = 0x000000C2,
    SPDK_NVME_INTEL_FEAT_POWER_GOVERNOR_SETTING = 0x000000C6,
    SPDK_NVME_INTEL_FEAT_SMBUS_ADDRESS = 0x000000C8,
    SPDK_NVME_INTEL_FEAT_LED_PATTERN = 0x000000C9,
    SPDK_NVME_INTEL_FEAT_RESET_TIMED_WORKLOAD_COUNTERS = 0x000000D5,
    SPDK_NVME_INTEL_FEAT_LATENCY_TRACKING = 0x000000E2


type
  spdk_nvme_intel_set_max_lba_command_status_code* {.size: sizeof(cint).} = enum
    SPDK_NVME_INTEL_EXCEEDS_AVAILABLE_CAPACITY = 0x000000C0,
    SPDK_NVME_INTEL_SMALLER_THAN_MIN_LIMIT = 0x000000C1,
    SPDK_NVME_INTEL_SMALLER_THAN_NS_REQUIREMENTS = 0x000000C2


type
  spdk_nvme_intel_log_page* {.size: sizeof(cint).} = enum
    SPDK_NVME_INTEL_LOG_PAGE_DIRECTORY = 0x000000C0,
    SPDK_NVME_INTEL_LOG_READ_CMD_LATENCY = 0x000000C1,
    SPDK_NVME_INTEL_LOG_WRITE_CMD_LATENCY = 0x000000C2,
    SPDK_NVME_INTEL_LOG_TEMPERATURE = 0x000000C5,
    SPDK_NVME_INTEL_LOG_SMART = 0x000000CA,
    SPDK_NVME_INTEL_MARKETING_DESCRIPTION = 0x000000DD


type
  spdk_nvme_intel_smart_attribute_code* {.size: sizeof(cint).} = enum
    SPDK_NVME_INTEL_SMART_PROGRAM_FAIL_COUNT = 0x000000AB,
    SPDK_NVME_INTEL_SMART_ERASE_FAIL_COUNT = 0x000000AC,
    SPDK_NVME_INTEL_SMART_WEAR_LEVELING_COUNT = 0x000000AD,
    SPDK_NVME_INTEL_SMART_E2E_ERROR_COUNT = 0x000000B8,
    SPDK_NVME_INTEL_SMART_CRC_ERROR_COUNT = 0x000000C7,
    SPDK_NVME_INTEL_SMART_MEDIA_WEAR = 0x000000E2,
    SPDK_NVME_INTEL_SMART_HOST_READ_PERCENTAGE = 0x000000E3,
    SPDK_NVME_INTEL_SMART_TIMER = 0x000000E4,
    SPDK_NVME_INTEL_SMART_THERMAL_THROTTLE_STATUS = 0x000000EA,
    SPDK_NVME_INTEL_SMART_RETRY_BUFFER_OVERFLOW_COUNTER = 0x000000F0,
    SPDK_NVME_INTEL_SMART_PLL_LOCK_LOSS_COUNT = 0x000000F3,
    SPDK_NVME_INTEL_SMART_NAND_BYTES_WRITTEN = 0x000000F4,
    SPDK_NVME_INTEL_SMART_HOST_BYTES_WRITTEN = 0x000000F5


type
  spdk_nvme_intel_log_page_directory* = object
    version*: array[2, uint8]
    reserved*: array[384, uint8]
    read_latency_log_len*: uint8
    reserved2*: uint8
    write_latency_log_len*: uint8
    reserved3*: array[5, uint8]
    temperature_statistics_log_len*: uint8
    reserved4*: array[9, uint8]
    smart_log_len*: uint8
    reserved5*: array[37, uint8]
    marketing_description_log_len*: uint8
    reserved6*: array[69, uint8]


assert(sizeof(spdk_nvme_intel_log_page_directory) == 512, "Incorrect size")
type
  spdk_nvme_intel_rw_latency_page* = object
    major_revison*: uint16
    minor_revison*: uint16
    buckets_32us*: array[32, uint32]
    buckets_1ms*: array[31, uint32]
    buckets_32ms*: array[31, uint32]


assert(sizeof(spdk_nvme_intel_rw_latency_page) == 380, "Incorrect size")
type
  spdk_nvme_intel_temperature_page* = object
    current_temperature*: uint64
    shutdown_flag_last*: uint64
    shutdown_flag_life*: uint64
    highest_temperature*: uint64
    lowest_temperature*: uint64
    reserved*: array[5, uint64]
    specified_max_op_temperature*: uint64
    reserved2*: uint64
    specified_min_op_temperature*: uint64
    estimated_offset*: uint64


assert(sizeof(spdk_nvme_intel_temperature_page) == 112, "Incorrect size")
type
  spdk_nvme_intel_smart_attribute* = object
    code*: uint8
    reserved*: array[2, uint8]
    normalized_value*: uint8
    reserved2*: uint8
    raw_value*: array[6, uint8]
    reserved3*: uint8

  spdk_nvme_intel_smart_information_page* = object
    attributes*: array[13, spdk_nvme_intel_smart_attribute]


assert(sizeof(spdk_nvme_intel_smart_information_page) == 156, "Incorrect size")
type
  INNER_C_STRUCT_20878198* = object
    power_governor_setting* {.bitsize: 8.}: uint32 ## * power governor setting : 00h = 25W 01h = 20W 02h = 10W
    reserved* {.bitsize: 24.}: uint32

  spdk_nvme_intel_feat_power_governor* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_20878198


assert(sizeof(spdk_nvme_intel_feat_power_governor) == 4, "Incorrect size")
type
  INNER_C_STRUCT_379855288* = object
    reserved* {.bitsize: 1.}: uint32
    smbus_controller_address* {.bitsize: 8.}: uint32
    reserved2* {.bitsize: 23.}: uint32

  spdk_nvme_intel_feat_smbus_address* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_379855288


assert(sizeof(spdk_nvme_intel_feat_smbus_address) == 4, "Incorrect size")
type
  INNER_C_STRUCT_1519419577* = object
    feature_options* {.bitsize: 24.}: uint32
    value* {.bitsize: 8.}: uint32

  spdk_nvme_intel_feat_led_pattern* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_1519419577


assert(sizeof(spdk_nvme_intel_feat_led_pattern) == 4, "Incorrect size")
type
  INNER_C_STRUCT_2567044396* = object
    reset* {.bitsize: 1.}: uint32 ## *
                              ##  Write Usage: 00 = NOP, 1 = Reset E2, E3,E4 counters;
                              ##  Read Usage: Not Supported
                              ##
    reserved* {.bitsize: 31.}: uint32

  spdk_nvme_intel_feat_reset_timed_workload_counters* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_2567044396


assert(sizeof(spdk_nvme_intel_feat_reset_timed_workload_counters) == 4,
       "Incorrect size")
type
  INNER_C_STRUCT_943236979* = object
    enable* {.bitsize: 32.}: uint32 ## *
                                ##  Write Usage:
                                ##  00h = Disable Latency Tracking (Default)
                                ##  01h = Enable Latency Tracking
                                ##

  spdk_nvme_intel_feat_latency_tracking* = object {.union.}
    raw*: uint32
    bits*: INNER_C_STRUCT_943236979


assert(sizeof(spdk_nvme_intel_feat_latency_tracking) == 4, "Incorrect size")
type
  spdk_nvme_intel_marketing_description_page* = object
    marketing_product*: array[512, uint8]


assert(sizeof(spdk_nvme_intel_marketing_description_page) == 512, "Incorrect size")
