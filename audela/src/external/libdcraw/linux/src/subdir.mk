################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables
C_SRCS += \
$(ROOT)/src/dcraw.c \
$(ROOT)/src/libdcraw.c

OBJS += \
./src/dcraw.o \
./src/libdcraw.o

DEPS += \
${addprefix ./src/, \
dcraw.d \
libdcraw.d \
}


# Each subdirectory must supply rules for building sources it contributes
src/%.o: $(ROOT)/src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	@echo gcc -O3 -Wall -c -fmessage-length=0 -fPIC -o$@ $<
	@gcc -O3 -Wall -c -fmessage-length=0 -fPIC -o$@ $< && \
	echo -n $(@:%.o=%.d) $(dir $@) > $(@:%.o=%.d) && \
	gcc -MM -MG -P -w -O3 -Wall -c -fmessage-length=0 -fPIC  $< >> $(@:%.o=%.d)
	@echo 'Finished building: $<'
	@echo ' '


