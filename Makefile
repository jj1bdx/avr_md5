#############################################################################
# Makefile for the project md5test-serial.c
###############################################################################

PROJECT = md5test-serial
MCU = atmega168
TARGET = md5test-serial.elf
CC = avr-gcc

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -O2 -g -DF_CPU=16000000UL
CFLAGS += -MD -MP -MT $(*F).o -MF $(@F).d

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS += -Wl,-Map=md5test-serial.map

## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings

## Objects that must be built in order to link
OBJECTS = md5test-serial.o md5.o uart.o

## Objects explicitly added by the user
LINKONLYOBJECTS = md5.S

## Build
all: $(TARGET) md5test-serial.hex md5test-serial.eep md5test-serial.lss size

## Compile

%.o: %.c
	$(CC) -c $< $(CFLAGS) $(LDFLAGS) -o $@

##Link
$(TARGET): $(OBJECTS)
	 $(CC) -o $(TARGET) $(LDFLAGS) $(OBJECTS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.eep: $(TARGET)
	-avr-objcopy -O ihex $< $@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

size: ${TARGET}
	@echo
	@avr-size ${TARGET}
#	@avr-size -C --mcu=${MCU} ${TARGET}

## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) md5test-serial.elf md5test-serial.hex md5test-serial.eep md5test-serial.lss md5test-serial.map

