#!/bin/bash

for i in bdev endian ioat json mmio nvme pci_ids scsi trace conf event ioat_spec jsonrpc net nvme_spec pci scsi_spec vtophys copy_engine file iscsi_spec log nvme_intel nvmf_spec rpc string; do
    nim doc --out:doc/spdk/$i.html api/$i.nim
done
