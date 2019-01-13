-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../../../../Makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: libgphoto2.so

# Tool invocations
libgphoto2.so: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C Linker'
	gcc -ldl -lm -lstdc++ -L/usr/lib -ltclstub8.5 -L/usr/lib -ltkstub8.5 -Xlinker -rpath $(OUTPUTDIR) -L../../libgphoto2_port/libgphoto2_port/linux -shared -o"libgphoto2.so" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(EXECUTABLES)$(C_DEPS) libgphoto2.so
	-@echo ' '

install: all
	cp libgphoto2.so $(OUTPUTDIR)/libgphoto2.so
	cp ../libgphoto2.h $(EXTINC)/libgphoto2.h
	-@echo ' '

.PHONY: all clean dependents install
.SECONDARY:

-include ../makefile.targets
