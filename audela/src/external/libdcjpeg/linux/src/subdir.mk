################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
$(ROOT)/src/jpegmemscr.c \
$(ROOT)/src/libdcjpeg_dll.c 

OBJS += \
./src/jpegmemscr.o \
./src/libdcjpeg_dll.o 

DEPS += \
${addprefix ./src/, \
jpegmemscr.d \
libdcjpeg_dll.d \
}


# Each subdirectory must supply rules for building sources it contributes
src/%.o: $(ROOT)/src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	@echo gcc -fPIC -O2 -Wall -c -I../jpeg-6b -o$@ $<
	@gcc -fPIC -O2 -Wall -c -I../jpeg-6b -o$@ $< && \
	echo -n $(@:%.o=%.d) $(dir $@) > $(@:%.o=%.d) && \
	gcc -fPIC -MM -MG -P -w -I../jpeg-6b -O3 -Wall -c $< >> $(@:%.o=%.d)
	@echo 'Finished building: $<'
	@echo ' '


