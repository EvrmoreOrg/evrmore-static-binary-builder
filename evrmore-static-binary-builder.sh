#!/bin/bash
# Script to build Evrmore Core statically-linked binaries and included dependencies from source code.
# It can be used to build binaries for any of the supported operating systems and CPU families.
# It is best if you understand it before using it.
# It is best used in a VirtualBox virtual machine or in a Docker container or similar.
# It is intended to be run on Ubuntu-20.04 as the super-user
#
# USAGE: ./evrmore-static-binary-builder.sh <platform> <branch> <makethreads>
# where platform (BUILDFOR) is one of: windows, osx, linux, linux-disable-wallet, arm32v7, arm32v7-disable-wallet, aarch64, or aarch64-disable-wallet
# and branch (GITBRANCH) is the git branch to build (e.g.: develop, master, etc)
# and makethreads (THREADS) is the number of threads to use while compiling (e.g.: 1, 5, etc)

# PREF = prefix to WORKPRE. Set this and the rest will be automagic.
# WORKPRE = the directory where everything happens. we cd $WORKDIR before cloning from git.
# GITDIR is the name of the directory we clone into, from git. 
# GITBRANCH is the branch we checkout from git.
# BUILDFOR is the first argument to this command. See the choices above (linux, windows, etc)
# THREADS is number of threads to use when compiling. Some, like openssl, forces -j1.
# BASEREF should be set to "release" for release. It does not matter what else it is when it's not "release".

BASEREF=dev	# release
RELEASEDIR=/root/release/
PREF=/build/
GITDIR=Evrmore
GITURL=https://github.com/EvrmoreOrg/Evrmore
#GITURL=/root/repo2build/Evrmore
GITBRANCH=$2
WORKPRE=$PREF/$1
WORKDIR=$WORKPRE/$GITDIR/
BUILDFOR=$1
THREADS=$3

if [ $1 = "clean" ]
	then
	echo "Cleaning build directories $PREF*"
	sleep 1
	echo "2..."
	sleep 1
	echo "1..."
	sleep 1
	echo "0..."
	rm -rf $PREF*
	echo "done."
	exit 0
fi	

if [ $# -lt 3 ]
  then
    echo "USAGE: $0 <platform> <git-branch> <make-threads>"
    echo "Example: $0 linux master 8"
	exit 1
fi

# make sure we have git
apt update
apt install git

# checkout git, modify to your own usage.
# if you want to start clean every time uncomment next line.
# rm -rf $WORKPRE
	mkdir -p $WORKPRE
	cd $WORKPRE
	git clone $GITURL
	cd $GITDIR
	git checkout $GITBRANCH
	git pull


cd $WORKDIR
# install depends from apt.
DEBIAN_FRONTEND=noninteractive \
$WORKDIR/.github/scripts/00-install-deps.sh $BUILDFOR


# build or copy depends. Increase number of threads -j2 with -jTHREADS
echo "Setting threads to $THREADS in 02-copy-build*...."
sed -i.old 's/\-j2/\-j'$THREADS'/g' $WORKDIR/.github/scripts/02-copy-build-dependencies.sh
$WORKDIR/.github/scripts/02-copy-build-dependencies.sh $BUILDFOR $WORKDIR
echo "Reverting threads in 02-copy-build*...."
cp $WORKDIR/.github/scripts/02-copy-build-dependencies.sh.old \
$WORKDIR/.github/scripts/02-copy-build-dependencies.sh

# need the next line to prevent "-dirty" on executable names
rm $WORKDIR/.github/scripts/02-copy-build-dependencies.sh.old

# setup environment
$WORKDIR/.github/scripts/03-export-path.sh $BUILDFOR $WORKDIR

# autogen
$WORKDIR/autogen.sh

# configure build
$WORKDIR/.github/scripts/04-configure-build.sh $BUILDFOR $WORKDIR

# build
make -j$THREADS

# run tests
$WORKDIR/.github/scripts/05-binary-checks.sh $BUILDFOR

# we need this to build packages for osx. Should be pushed to master depends.
if [ $1 == "osx" ]
  then
	apt install -y python3-pip
	pip3 install ds_store
fi

# package
$WORKDIR/.github/scripts/06-package.sh $BUILDFOR $WORKDIR $BASEREF


# copy packages to 
mkdir -p $RELEASEDIR
cp $WORKDIR/release/* $RELEASEDIR
echo "Products copied to $RELEASEDIR"
echo "The end."
