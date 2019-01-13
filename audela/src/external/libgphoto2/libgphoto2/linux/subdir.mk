################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables
C_SRCS += \
../bayer.c \
../exif.c \
../gamma.c \
../gphoto2-abilities-list.c \
../gphoto2-camera.c \
../gphoto2-context.c \
../gphoto2-file.c \
../gphoto2-filesys.c \
../gphoto2-library.c \
../gphoto2-list.c \
../gphoto2-result.c \
../gphoto2-setting.c \
../gphoto2-version.c \
../gphoto2-widget.c \
../jpeg.c \
../libgphoto2.c

OBJS += \
./bayer.o \
./exif.o \
./gamma.o \
./gphoto2-abilities-list.o \
./gphoto2-camera.o \
./gphoto2-context.o \
./gphoto2-file.o \
./gphoto2-filesys.o \
./gphoto2-library.o \
./gphoto2-list.o \
./gphoto2-result.o \
./gphoto2-setting.o \
./gphoto2-version.o \
./gphoto2-widget.o \
./jpeg.o \
./libgphoto2.o

C_DEPS += \
./bayer.d \
./exif.d \
./gamma.d \
./gphoto2-abilities-list.d \
./gphoto2-camera.d \
./gphoto2-context.d \
./gphoto2-file.d \
./gphoto2-filesys.d \
./gphoto2-library.d \
./gphoto2-list.d \
./gphoto2-result.d \
./gphoto2-setting.d \
./gphoto2-version.d \
./gphoto2-widget.d \
./jpeg.d \
./libgphoto2.d


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -I../../linux -I../../libltdl -I../../libgphoto2_port/libgphoto2_port -I.. -O3 -w -c -fmessage-length=0 -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


