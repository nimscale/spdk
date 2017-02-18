
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
 </br>


 </br>
> <h3>Note! Test envoronment is based on Ubuntu 16.04.</h3></br>
