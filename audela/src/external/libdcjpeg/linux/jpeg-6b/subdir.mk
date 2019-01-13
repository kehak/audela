################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables
C_SRCS += \
$(ROOT)/jpeg-6b/jcapimin.c \
$(ROOT)/jpeg-6b/jcapistd.c \
$(ROOT)/jpeg-6b/jccoefct.c \
$(ROOT)/jpeg-6b/jccolor.c \
$(ROOT)/jpeg-6b/jcdctmgr.c \
$(ROOT)/jpeg-6b/jchuff.c \
$(ROOT)/jpeg-6b/jcinit.c \
$(ROOT)/jpeg-6b/jcmainct.c \
$(ROOT)/jpeg-6b/jcmarker.c \
$(ROOT)/jpeg-6b/jcmaster.c \
$(ROOT)/jpeg-6b/jcomapi.c \
$(ROOT)/jpeg-6b/jcparam.c \
$(ROOT)/jpeg-6b/jcphuff.c \
$(ROOT)/jpeg-6b/jcprepct.c \
$(ROOT)/jpeg-6b/jcsample.c \
$(ROOT)/jpeg-6b/jctrans.c \
$(ROOT)/jpeg-6b/jdapimin.c \
$(ROOT)/jpeg-6b/jdapistd.c \
$(ROOT)/jpeg-6b/jdatadst.c \
$(ROOT)/jpeg-6b/jdatasrc.c \
$(ROOT)/jpeg-6b/jdcoefct.c \
$(ROOT)/jpeg-6b/jdcolor.c \
$(ROOT)/jpeg-6b/jddctmgr.c \
$(ROOT)/jpeg-6b/jdhuff.c \
$(ROOT)/jpeg-6b/jdinput.c \
$(ROOT)/jpeg-6b/jdmainct.c \
$(ROOT)/jpeg-6b/jdmarker.c \
$(ROOT)/jpeg-6b/jdmaster.c \
$(ROOT)/jpeg-6b/jdmerge.c \
$(ROOT)/jpeg-6b/jdphuff.c \
$(ROOT)/jpeg-6b/jdpostct.c \
$(ROOT)/jpeg-6b/jdsample.c \
$(ROOT)/jpeg-6b/jdtrans.c \
$(ROOT)/jpeg-6b/jerror.c \
$(ROOT)/jpeg-6b/jfdctflt.c \
$(ROOT)/jpeg-6b/jfdctfst.c \
$(ROOT)/jpeg-6b/jfdctint.c \
$(ROOT)/jpeg-6b/jidctflt.c \
$(ROOT)/jpeg-6b/jidctfst.c \
$(ROOT)/jpeg-6b/jidctint.c \
$(ROOT)/jpeg-6b/jidctred.c \
$(ROOT)/jpeg-6b/jmemmgr.c \
$(ROOT)/jpeg-6b/jmemnobs.c \
$(ROOT)/jpeg-6b/jquant1.c \
$(ROOT)/jpeg-6b/jquant2.c \
$(ROOT)/jpeg-6b/jutils.c

OBJS += \
./jpeg-6b/jcapimin.o \
./jpeg-6b/jcapistd.o \
./jpeg-6b/jccoefct.o \
./jpeg-6b/jccolor.o \
./jpeg-6b/jcdctmgr.o \
./jpeg-6b/jchuff.o \
./jpeg-6b/jcinit.o \
./jpeg-6b/jcmainct.o \
./jpeg-6b/jcmarker.o \
./jpeg-6b/jcmaster.o \
./jpeg-6b/jcomapi.o \
./jpeg-6b/jcparam.o \
./jpeg-6b/jcphuff.o \
./jpeg-6b/jcprepct.o \
./jpeg-6b/jcsample.o \
./jpeg-6b/jctrans.o \
./jpeg-6b/jdapimin.o \
./jpeg-6b/jdapistd.o \
./jpeg-6b/jdatadst.o \
./jpeg-6b/jdatasrc.o \
./jpeg-6b/jdcoefct.o \
./jpeg-6b/jdcolor.o \
./jpeg-6b/jddctmgr.o \
./jpeg-6b/jdhuff.o \
./jpeg-6b/jdinput.o \
./jpeg-6b/jdmainct.o \
./jpeg-6b/jdmarker.o \
./jpeg-6b/jdmaster.o \
./jpeg-6b/jdmerge.o \
./jpeg-6b/jdphuff.o \
./jpeg-6b/jdpostct.o \
./jpeg-6b/jdsample.o \
./jpeg-6b/jdtrans.o \
./jpeg-6b/jerror.o \
./jpeg-6b/jfdctflt.o \
./jpeg-6b/jfdctfst.o \
./jpeg-6b/jfdctint.o \
./jpeg-6b/jidctflt.o \
./jpeg-6b/jidctfst.o \
./jpeg-6b/jidctint.o \
./jpeg-6b/jidctred.o \
./jpeg-6b/jmemmgr.o \
./jpeg-6b/jmemnobs.o \
./jpeg-6b/jquant1.o \
./jpeg-6b/jquant2.o \
./jpeg-6b/jutils.o

DEPS += \
${addprefix ./jpeg-6b/, \
jcapimin.d \
jcapistd.d \
jccoefct.d \
jccolor.d \
jcdctmgr.d \
jchuff.d \
jcinit.d \
jcmainct.d \
jcmarker.d \
jcmaster.d \
jcomapi.d \
jcparam.d \
jcphuff.d \
jcprepct.d \
jcsample.d \
jctrans.d \
jdapimin.d \
jdapistd.d \
jdatadst.d \
jdatasrc.d \
jdcoefct.d \
jdcolor.d \
jddctmgr.d \
jdhuff.d \
jdinput.d \
jdmainct.d \
jdmarker.d \
jdmaster.d \
jdmerge.d \
jdphuff.d \
jdpostct.d \
jdsample.d \
jdtrans.d \
jerror.d \
jfdctflt.d \
jfdctfst.d \
jfdctint.d \
jidctflt.d \
jidctfst.d \
jidctint.d \
jidctred.d \
jmemmgr.d \
jmemnobs.d \
jquant1.d \
jquant2.d \
jutils.d \
}


# Each subdirectory must supply rules for building sources it contributes
jpeg-6b/%.o: $(ROOT)/jpeg-6b/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	@echo gcc -I../jpeg-6b -O3 -Wall -c -fmessage-length=0 -fPIC -o$@ $<
	@gcc -I../jpeg-6b -O3 -Wall -c -fmessage-length=0 -fPIC -o$@ $< && \
	echo -n $(@:%.o=%.d) $(dir $@) > $(@:%.o=%.d) && \
	gcc -MM -MG -P -w -I../jpeg-6b -O3 -Wall -c -fmessage-length=0 -fPIC  $< >> $(@:%.o=%.d)
	@echo 'Finished building: $<'
	@echo ' '


