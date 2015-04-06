#!/bin/bash
## this is used for all commomn things like toochains and 
## the distro that you wahnjt typo use currently UBuntu and debian are the only
## ones that are supported

## this is the dir that is used to tell where odroid builder is installed
rootDir="/home/joseph/Work/sandy/odroidBuilder"

## The type of board that you are building for example U is for the U series of 
## of the odroid boards 
## Only U and C are ready at this point
board="U"

## the distro that you want to build
## IMPORTANT make sure that this all all lower case.
distro="debian"

## the version of the distro that you would like to build
codeName="jessie"

## the version of the distro that you are building
version=0.2

## the host arch.  This only needs to be set if it tells you to set it
# hostArch=""

## variant used to for debootstrap
debootstrapVariant="buildd"

co=$(grep -c processor /proc/cpuinfo)
minueOne=1
cnum=$(expr $co - $minueOne)
buildArch="armhf"
status=0

basedir=$(pwd)/odroid-$version-$board-$codeName
distributeion=$3

## if you want to use a different distro that supports debootstrap 
## Here is where you set the mirror for that distro
mainMirror="http://http.debian.net/debian"
securityMirror="security.debian.org/"

## these are paths to the downloaded cross compile.
gcc49="$rootDir/toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin"
gcc47="$rootDir/toolchains/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin"
eabi="$rootDir/toolchains/arm-eabi-4.4.3/bin"
eabiNone="$rootDir/toolchains/gcc-linaro-arm-none-eabi-4.8-2014.04_linux/bin"
