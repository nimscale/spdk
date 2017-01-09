
#stand alone building of spdk, dpdk

# End nimble section
import ospaths
import strutils

mode = ScriptMode.Verbose

echo "Execute sudo apt install -y gcc g++ make libcunit1-dev libaio-dev libssl-dev"
exec "sudo apt-get update"
exec "sudo apt-get install -y gcc g++ make wget libcunit1-dev libaio-dev libssl-dev"
exec "sudo apt-get install -y libibverbs-dev librdmacm-dev libpciaccess-dev binutils-dev"
#DPDK dependencies
exec "sudo apt-get install -y doxygen graphviz inkscape libcap-dev libpcap-dev libxen-dev"

let
  dirName = "libspdk"

if false == dirExists(dirName):
  exec "git clone https://github.com/spdk/spdk.git " & dirName

withDir dirName:
  exec "git checkout v16.08"                   # Get the latest stable release
  echo " "
  echo "SPDK requires DPDK to be installed."
  echo " "
  echo "Installing DPDK... Release 16.07 is being used."
  echo " "
  exec "wget http://fast.dpdk.org/rel/dpdk-16.07.tar.xz"
  exec "tar xf dpdk-16.07.tar.xz"
  withDir "dpdk-16.07":
    exec "make install T=x86_64-native-linuxapp-gcc DESTDIR=.  EXTRA_CFLAGS=\"-g -O0\""
  #    exec "make config T=x86_64-native-linuxapp-gcc DESTDIR=."
  #    exec "make"
  exec "make DPDK_DIR=./dpdk-16.07/x86_64-native-linuxapp-gcc"
  #  exec "make DPDK_DIR=" & thisDir() & "/dpdk-16.07/x86_64-native-linuxapp-gcc"
  echo "SPDK instalation in the system."
  exec "sudo scripts/setup.sh"
