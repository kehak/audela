################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables
C_SRCS += \
../gphoto2-port-info-list.c \
../gphoto2-port-log.c \
../gphoto2-port-portability.c \
../gphoto2-port-result.c \
../gphoto2-port-version.c \
../gphoto2-port.c

OBJS += \
./gphoto2-port-info-list.o \
./gphoto2-port-log.o \
./gphoto2-port-portability.o \
./gphoto2-port-result.o \
./gphoto2-port-version.o \
./gphoto2-port.o

C_DEPS += \
./gphoto2-port-info-list.d \
./gphoto2-port-log.d \
./gphoto2-port-portability.d \
./gphoto2-port-result.d \
./gphoto2-port-version.d \
./gphoto2-port.d


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -I../../../linux -I.. -I../../../libltdl -O3 -Wall -c -fmessage-length=0 -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


