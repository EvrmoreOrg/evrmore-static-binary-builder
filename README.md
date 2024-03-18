

# ESBB - Evrmore Static Binary Builder

ESBB is a bash script which can be used to build statically-linked binary executables of the Evrmore Core node software for any of the supported operating systems and CPU families.

ESBB uses the Evrmore Core C++ code to compile Core and all dependencies from the source code in the Github EvrmoreOrg/Evrmore repository. Moreover, ESBB accomplishes its tasks by using the Github-Actions scripts located in the same repository at https:/github.com/EvrmoreOrg/Evrmore/tree/develop/.github/scripts


## Installing the Evrmore Static Binary Builder

ESBB  is best used in a VirtualBox virtual machine or in a Docker container or similar. It is intended to be run on Ubuntu-20.04 as the super-user.

After creating the VM, login and obtain super-user privileges:
```	
	sudo su
```
Then copy the script "**evrmore-static-binary-builder.sh**" into the VM.

Look at the variables at the top of the script. You should not need to change any of them, but you could edit the script if you want to do something special. I often change "GITURL" to point to a local directory instead of to the public Github repository if I have a locally edited version of the Core source code which I am testing.


## Running the script

USAGE:  
```  
./evrmore-static-binary-builder.sh <platform> <branch> <makethreads>  
```
where:  
``` 
    - platform (BUILDFOR) is one of: windows, osx, linux, linux-disable-wallet, arm32v7, arm32v7-disable-wallet, aarch64, or aarch64-disable-wallet  
    - and branch (GITBRANCH) is the git branch to build (e.g.: develop, master, etc)  
    - and makethreads (THREADS) is the number of threads to use while compiling (e.g.: 1, 5, etc)  
```
    

## Hints

Evrmore's large genesis block requires a lot of memory during compilation. Compiling binaries for Windows is especially challenging because the ming-w64 cross-compilation environment does not appear to properly handle large arrays which do not fit in memory. I find that allocating a large 30GB swap space eliminates the errors.

