################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables
C_SRCS += \
../canon.c \
../crc.c \
../library.c \
../serial.c \
../usb.c \
../util.c

OBJS += \
./canon.o \
./crc.o \
./library.o \
./serial.o \
./usb.o \
./util.o

C_DEPS += \
./canon.d \
./crc.d \
./library.d \
./serial.d \
./usb.d \
./util.d


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -I../../../libgphoto2_port/libgphoto2_port -I../../../linux -I../../../libgphoto2 -I.. -O3 -w -c -fmessage-length=0 -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


