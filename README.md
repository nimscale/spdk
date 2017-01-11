

<h2> NIM wrapper to Intel SPDK set of libraries. </h2>
</br>
</br>
</br>
>Build the library and dependencies:</br>
>git clone https://github.com/nimscale/spdk.git</br>
>cd spdk</br>
>nim e build.nims</br>
>
> <h3> SPDK test</h3>
>  Build exapmle aplication:</br>
></br>
>nim c --debugger:native --stackTrace:on --lineTrace:on --threads:on --checks:on \\</br>
>--objChecks:on --fieldChecks:on -a:on --debuginfo --dynlibOverride:libspdk \\</br>
>--passL:./libspdk/lib/jsonrpc/libspdk_jsonrpc.a \\</br>
>--passL:./libspdk/lib/iscsi/libspdk_iscsi.a \\</br>
>--passL:./libspdk/lib/copy/libspdk_copy.a \\</br>
>--passL:./libspdk/lib/copy/ioat/libspdk_copy_ioat.a \\</br>
>--passL:./libspdk/lib/conf/libspdk_conf.a \\</br>
>--passL:./libspdk/lib/net/libspdk_net.a \\</br>
>--passL:./libspdk/lib/util/libspdk_util.a \\</br>
>--passL:./libspdk/lib/nvme/libspdk_nvme.a \\</br>
>--passL:./libspdk/lib/scsi/libspdk_scsi.a \\</br>
>--passL:./libspdk/lib/bdev/malloc/libspdk_bdev_malloc.a \\</br>
>--passL:./libspdk/lib/bdev/aio/libspdk_bdev_aio.a \\</br>
>--passL:./libspdk/lib/bdev/libspdk_bdev.a \\</br>
>--passL:./libspdk/lib/bdev/nvme/libspdk_bdev_nvme.a \\</br>
>--passL:./libspdk/lib/nvmf/libspdk_nvmf.a \\</br>
>--passL:./libspdk/lib/cunit/libspdk_cunit.a \\</br>
>--passL:./libspdk/lib/log/libspdk_log.a \\</br>
>--passL:./libspdk/lib/log/rpc/libspdk_log_rpc.a \\</br>
>--passL:./libspdk/lib/trace/libspdk_trace.a \\</br>
>--passL:./libspdk/lib/event/libspdk_event.a \\</br>
>--passL:./libspdk/lib/event/rpc/libspdk_app_rpc.a \\</br>
>--passL:./libspdk/lib/ioat/libspdk_ioat.a \\</br>
>--passL:./libspdk/lib/rpc/libspdk_rpc.a \\</br>
>--passL:./libspdk/lib/json/libspdk_json.a \\</br>
>--passL:./libspdk/lib/memory/libspdk_memory.a \\</br>
>--passL:"-Wl,--start-group -Wl,--whole-archive" \\</br>
>--passL:./libspdk/dpdk-16.07/x86_64-native-linuxapp-gcc/lib/librte_eal.a \\</br>
>--passL:./libspdk/dpdk-16.07/x86_64-native-linuxapp-gcc/lib/librte_mempool.a \\</br>
>--passL:./libspdk/dpdk-16.07/x86_64-native-linuxapp-gcc/lib/librte_ring.a \\</br>
>--passL:./libspdk/dpdk-16.07/x86_64-native-linuxapp-gcc/lib/librte_timer.a \\</br>
>--passL:"-Wl,--end-group -Wl,--no-whole-archive -ldl -lrt" \\</br>
>--passL:/usr/lib/x86_64-linux-gnu/libpciaccess.a \\</br>
>--passL:/usr/lib/x86_64-linux-gnu/librt.a \\</br>
>--passL:/usr/lib/x86_64-linux-gnu/libz.a \\</br>
>./examples/hello_world/hello_world.nim</br>
></br>
>  Setup environment: sudo scripts/setup.sh</br>
>  Execute the test application: sudo ./examples/hello_world/hello_world</br>
> </br>
> </br>
> <h3>!! This tested and works on ubuntu16.04</h3></br>
