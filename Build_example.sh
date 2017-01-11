#!/usr/bin/env bash

nim c --debugger:native --stackTrace:on --lineTrace:on --threads:on --checks:on \
--objChecks:on --fieldChecks:on -a:on --debuginfo --dynlibOverride:libspdk \
--passL:./libspdk/lib/jsonrpc/libspdk_jsonrpc.a \
--passL:./libspdk/lib/iscsi/libspdk_iscsi.a \
--passL:./libspdk/lib/copy/libspdk_copy.a \
--passL:./libspdk/lib/copy/ioat/libspdk_copy_ioat.a \
--passL:./libspdk/lib/conf/libspdk_conf.a \
--passL:./libspdk/lib/net/libspdk_net.a \
--passL:./libspdk/lib/util/libspdk_util.a \
--passL:./libspdk/lib/nvme/libspdk_nvme.a \
--passL:./libspdk/lib/scsi/libspdk_scsi.a \
--passL:./libspdk/lib/bdev/malloc/libspdk_bdev_malloc.a \
--passL:./libspdk/lib/bdev/aio/libspdk_bdev_aio.a \
--passL:./libspdk/lib/bdev/libspdk_bdev.a \
--passL:./libspdk/lib/bdev/nvme/libspdk_bdev_nvme.a \
--passL:./libspdk/lib/nvmf/libspdk_nvmf.a \
--passL:./libspdk/lib/cunit/libspdk_cunit.a \
--passL:./libspdk/lib/log/libspdk_log.a \
--passL:./libspdk/lib/log/rpc/libspdk_log_rpc.a \
--passL:./libspdk/lib/trace/libspdk_trace.a \
--passL:./libspdk/lib/event/libspdk_event.a \
--passL:./libspdk/lib/event/rpc/libspdk_app_rpc.a \
--passL:./libspdk/lib/ioat/libspdk_ioat.a \
--passL:./libspdk/lib/rpc/libspdk_rpc.a \
--passL:./libspdk/lib/json/libspdk_json.a \
--passL:./libspdk/lib/memory/libspdk_memory.a \
--passL:"-Wl,--start-group -Wl,--whole-archive" \
--passL:./libspdk/dpdk-16.07/x86_64-native-linuxapp-gcc/lib/librte_eal.a \
--passL:./libspdk/dpdk-16.07/x86_64-native-linuxapp-gcc/lib/librte_mempool.a \
--passL:./libspdk/dpdk-16.07/x86_64-native-linuxapp-gcc/lib/librte_ring.a \
--passL:./libspdk/dpdk-16.07/x86_64-native-linuxapp-gcc/lib/librte_timer.a \
--passL:"-Wl,--end-group -Wl,--no-whole-archive -ldl -lrt" \
--passL:/usr/lib/x86_64-linux-gnu/libpciaccess.a \
--passL:/usr/lib/x86_64-linux-gnu/librt.a \
--passL:/usr/lib/x86_64-linux-gnu/libz.a \
./examples/hello_world/hello_world.nim
