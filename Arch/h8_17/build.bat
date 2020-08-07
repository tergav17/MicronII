@ECHO OFF
echo Building MICRON for Heathkit H8 with H17 controller

echo Assembling kernel.asm...
bin\zmac -z kernel.asm
copy zout\kernel.cim kernel.bin > NUL


echo Packing kernel.bin into H8D image
java -jar bin\MicronPack.jar h8_17 kernel.bin

echo Formatting .H8D image into .logdisk for emulation...
java -jar bin\format.jar h8d=out.h8d out Z17 5 SS SD

echo Copying all outputs to "out" directory
copy kernel.bin out\kernel.bin > NUL
copy out.h8d out\micron.h8d > NUL
copy out.logdisk out\micron.logdisk > NUL

echo Cleaning up...
del kernel.bin > NUL
del out.h8d > NUL
del out.logdisk > NUL
del /f /q /s zout > NUL
rmdir zout > NUL