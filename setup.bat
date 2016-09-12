@echo off

set GardeningRoot=%HOMEDRIVE%%HOMEPATH%\.gardening

mkdir "%GardeningRoot%"

copy /-y src\stub\vagrant.yaml.dist "%GardeningRoot%\vagrant.yaml"
copy /-y src\stub\append.sh "%GardeningRoot%\append.sh"
copy /-y src\stub\aliases "%GardeningRoot%\aliases"

set GardeningRoot=
echo initialized
