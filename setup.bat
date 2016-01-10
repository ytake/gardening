@echo off

set GardeningRoot=%HOMEDRIVE%%HOMEPATH%\.gardening

mkdir "%GardeningRoot%"

copy /-y src\stubs\vagrant.yaml.dist "%GardeningRoot%\vagrant.yaml"
copy /-y src\stubs\append.sh "%GardeningRoot%\append.sh"
copy /-y src\stubs\aliases "%GardeningRoot%\aliases"

set GardeningRoot=
echo initialized
