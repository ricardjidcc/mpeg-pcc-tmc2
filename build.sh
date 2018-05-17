#!/bin/bash

CURDIR=`dirname $0`;
echo -e "\033[0;32mBuild: $(readlink -f $CURDIR) \033[0m";

case "$(uname -s)" in
  Linux*)     MACHINE=Linux;;
  Darwin*)    MACHINE=Mac;;
  CYGWIN*)    MACHINE=Cygwin;;
  MINGW*)     MACHINE=MinGw;;
  *)          MACHINE="UNKNOWN:${unameOut}"
esac

MODE=Release;
CMAKE_FLAGS=;
if [ "$MACHINE" == "Linux" ] ; then NUMBER_OF_PROCESSORS=`grep -c ^processor /proc/cpuinfo`; fi

for i in "$@"
do  
  case "$i" in
    debug|Debug|DEBUG      ) MODE=Debug;;
    release|Release|RELEASE) MODE=Release;;
    *                      ) echo "ERROR: arguments \"$i\" not supported: option = [debug|release]"; exit -1;;
  esac
done

CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_BUILD_TYPE=$MODE";
case "${MACHINE}" in
  Linux) cmake -H${CURDIR} -B${CURDIR}/build/${MODE} -G "Unix Makefiles"              ${CMAKE_FLAGS};; 
  Mac)   cmake -H${CURDIR} -B${CURDIR}/build/${MODE} -G "Xcode"                       ${CMAKE_FLAGS};;
  *)     cmake -H${CURDIR} -B${CURDIR}/build/${MODE} -G "Visual Studio 14 2015 Win64" ${CMAKE_FLAGS};;
esac

case "${MACHINE}" in
  Linux) make -C ${CURDIR}/build/${MODE} -j ${NUMBER_OF_PROCESSORS} ${CMD} -s;; 
  Mac)   echo "Please, open the generated xcode project and build it ";;
  *)     MSBUILD='/c/Program\ Files\ \(x86\)/MSBuild/14.0/Bin/MSBuild.exe';
         if [ -f ${MSBUILD[@]} ] 
         then 
           eval ${MSBUILD[@]} ./build/${MODE}/TMC2.sln /property:Configuration=${MODE};
         else
           echo "MsBuild not found ($MSBUILD)";
           echo "Please, open the generated visual studio solution and build it ";         
         fi
  ;;
esac 