################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
$(ROOT)/libdcjpeg_dll.c 

OBJS += \
./libdcjpeg_dll.o 

DEPS += \
${addprefix ./, \
libdcjpeg_dll.d \
}


# Each subdirectory must supply rules for building sources it contributes
%.o: $(ROOT)/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	@echo gcc -I../jpeg-6b -O0 -g3 -Wall -c -fmessage-length=0 -fPIC -o$@ $<
	@gcc -I../jpeg-6b -O0 -g3 -Wall -c -fmessage-length=0 -fPIC -o$@ $< && \
	echo -n $(@:%.o=%.d) $(dir $@) > $(@:%.o=%.d) && \
	gcc -MM -MG -P -w -I../jpeg-6b -O0 -g3 -Wall -c -fmessage-length=0 -fPIC  $< >> $(@:%.o=%.d)
	@echo 'Finished building: $<'
	@echo ' '


