## Welcome to YAAB (yet another automated builder )

This is a new inhouse tool that is used to build and maitian armhf images. 

This Tool was built and tested on Debian Jessie

### The common folder

These are scripts are imported into other parts of the program. 

common/customBuild

If you are building your own distro then you want to alter this file to add all things that you want your distro to contian
This also reads from the file extraPackages 

example: custom apps custom configuration's 

common/extraPackages 

These are the extra packages that are installed to you operating system, this is read when customBuild runs.

common/htmlHelper

Set of bash funtions that are used to make the output web interface




### The config folder 

This used for custom scripts for building the linux kernel
Other Simple configurations also are in there. 

config/deps

Script that is used to make sure that all depenceys are install to a machine that is building images

config/header.html

Part of the templeating web interface that is used to write headers to webpages 


config/body.html 

Part of the templeating web interface that is used to write bodys to webpages

config/footer

Part of the templeating web interface that is used to write footer to webpages, this is also used to close all html tags in the body and header
typical script.. 

add static folder 

add the header 

add the body

add custom input 

add the footer 

config/mailer

The mailing address and other things that are needed in order to send status reports to admins

### The Arcive Folder

This is a cache folder that is used to store things like cross-compilers and maybe even rootFs if you like. 


### The Toolchain folder

This is used after downloading linaro's gcc and exstracting it.

!! THANKS LINARO !!


### The Boards Folder: 

This is the main scripts that are used to build each distro, 

these take 2 arguments: 
 
 $1 the version that you are building (example: 0.1)

 $2 The Distro Name ( example: jessie )

Along with the arguments there is also the 


board<name of board>/files

These are files that are used to set up the os based only on that board type. 

example:  a odroidc1 might  need a custom /etc/securetty file


### The Staic Dir 

This folder conitans all static code that can be used for many different things but for right now is used for bootstrap.


