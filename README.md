
# NIM wrapper to Intel SPDK set of libraries.
</br>

 Original library may be found at https://github.com/spdk/spdk.
 For detailed reference and full set of documentation please refer to http://spdk.io.


## Build the library and dependencies:

  Please note! There are list of dependencies and extra libraries required to be installed for SPDK correct work. It is covered in builds.nim script. It execution will require ```sudo``` privileges. 

<h4> Installation process: </h4> 
```
git clone https://github.com/nimscale/spdk.git
cd spdk
nim e build.nims
```
</br>

## SPDK test
  Build exapmle aplication:</br>
</br>
```
sh Build_example.sh
```
</br>
  Prepare SPDK environment:</br>
```
sudo ./libspdk/scripts/setup.sh</br>
```
  Execute the test application:</br>
```
sudo ./examples/hello_world/hello_world</br>
```
  As result of successful execution you'll get something like :

```
rivasiv@rivasiv-at-gmail.com:~/projects/nimscale/spdk-1$ sudo ./examples/hello_world/hello_world  
EAL: Detected 1 lcore(s)
EAL: Probing VFIO support...
Initializing NVMe Controllers
Attaching to 0000:00:0e.00
Attached to 0000:00:0e.00
Using controller ORCL-VBOX-NVME-VER12 (VB1234-56789        ) with 1 namespaces.
  Namespace ID: 1 size: 8GB
Initialization complete.


  Hello world!

```
# Documentation:

 General library documentation: [SPDK Doc](http://www.spdk.io/doc/)
 API reference: [TBD]
 
 
 </br>
> <h3>Note! Test envoronment is based on Ubuntu 16.04.</h3></br>
