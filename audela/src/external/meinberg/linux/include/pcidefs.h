
/**************************************************************************
 *
 *  $Id: pcidefs.h 1.7 2008/06/09 10:43:09 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Common definitions to be used with PCI.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcidefs.h $
 *  Revision 1.7  2008/06/09 10:43:09  martin
 *  Added PCI_CMD_ENB_MEM_ACC code.
 *  Revision 1.6  2005/09/19 13:06:15Z  martin
 *  Added definition for number of base address registers.
 *  Revision 1.5  2004/11/09 13:15:05Z  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Revision 1.4  2001/02/05 16:28:21Z  MARTIN
 *  Don't include stdlib.h.
 *  Revision 1.3  2000/09/11 13:51:10  MARTIN
 *  Moved structure PCI_IRQ_ROUTE_BUFFER to pci_dos.h.
 *  Revision 1.2  2000/07/21 11:56:20  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _PCIDEFS_H
#define _PCIDEFS_H


/* Other headers to be included */

#include <words.h>


#ifdef _PCIDEFS
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */


// Available PCI subfunction codes depend on the operating system
// so they are defined in the associated headers.

// The interrupt number used to access PCI BIOS in real mode:
#define PCI_BIOS_INT           0x1A


// The function code is put into the AH register when a PCI function
// is called:
#define PCI_BIOS_FNC           0xB1


// The PCI subfunction codes listed below are put into the AL register
// when PCI functions are called. Other registers must be set according
// to the subfunction specs:
#define PCI_BIOS_PRESENT       0x01
#define PCI_FIND_DEVICE        0x02
#define PCI_FIND_CLASS_CODE    0x03
#define PCI_GEN_SPECIAL_CYCLE  0x06
#define PCI_READ_CFG_BYTE      0x08
#define PCI_READ_CFG_WORD      0x09
#define PCI_READ_CFG_DWORD     0x0A
#define PCI_WRITE_CFG_BYTE     0x0B
#define PCI_WRITE_CFG_WORD     0x0C
#define PCI_WRITE_CFG_DWORD    0x0D
#define PCI_GET_IRQ_ROUTING    0x0E


// List of PCI BIOS return codes:
#define PCI_SUCCESS            0x00
#define PCI_NO_SUCCESS         0x01  // (not returned by BIOS)
#define PCI_FUNC_NOT_SUPP      0x81
#define PCI_BAD_VENDOR_ID      0x83
#define PCI_DEVICE_NOT_FOUND   0x86
#define PCI_BAD_REGISTER_NUMB  0x87
#define PCI_BUFFER_TOO_SMALL   0x89


// The 80x86 Flags Register Carry Flag bit returns completion status.
// If the Carry Flag is set, the function call did not succeed.
#define CARRY_FLAG 0x01


// The signature "PCI " is returned in EDX when the subfunction
// PCI_BIOS_PRESENT has been called:
#define PCI_BIOS_SIGNATURE     0x20494350UL


// The code below represents an invalid vendor id
// or wildcard:
#define PCI_INV_VENDOR_ID      0xFFFFU


// The number of possible PCI devices per bus:
#define PCI_DEVICES_PER_BUS    32


// A variable of the type below is used to keep
// the PCI interrupt routing information:
typedef struct
{
  uint8_t bus;
  uint8_t device_number;
  uint8_t inta_link;
  uint16_t inta_map;
  uint8_t intb_link;
  uint16_t intb_map;
  uint8_t intc_link;
  uint16_t intc_map;
  uint8_t intd_link;
  uint16_t intd_map;
  uint8_t slot;
  uint8_t reserved;
} PCI_IRQ_ROUTE_ENTRY;


// List of PCI BIOS return codes

#define PCI_SUCCESS            0x00
#define PCI_NO_SUCCESS         0x01   // not returned by BIOS
#define PCI_FUNC_NOT_SUPP      0x81
#define PCI_BAD_VENDOR_ID      0x83
#define PCI_DEVICE_NOT_FOUND   0x86
#define PCI_BAD_REGISTER_NUMB  0x87
#define PCI_BUFFER_TOO_SMALL   0x89



// The 80x86 flags register carry flag bit returns completion status.
// If the carry flag is set, the function call did not succeed.

#ifndef CARRY_FLAG
  #define CARRY_FLAG 0x01
#endif


// The signature "PCI " is returned in EDX when the subfunction
// PCI_BIOS_PRESENT has been called.

#define PCI_BIOS_SIGNATURE     0x20494350UL


// PCI configuration space registers

#define PCI_CS_VENDOR_ID         0x00
#define PCI_CS_DEVICE_ID         0x02
#define PCI_CS_COMMAND           0x04
#define PCI_CS_STATUS            0x06
#define PCI_CS_REVISION_ID       0x08
#define PCI_CS_CLASS_CODE        0x09
#define PCI_CS_CACHE_LINE_SIZE   0x0C
#define PCI_CS_MASTER_LATENCY    0x0D
#define PCI_CS_HEADER_TYPE       0x0E
#define PCI_CS_BIST              0x0F
#define PCI_CS_BASE_ADDRESS_0    0x10
#define PCI_CS_BASE_ADDRESS_1    0x14
#define PCI_CS_BASE_ADDRESS_2    0x18
#define PCI_CS_BASE_ADDRESS_3    0x1C
#define PCI_CS_BASE_ADDRESS_4    0x20
#define PCI_CS_BASE_ADDRESS_5    0x24
#define PCI_CS_EXPANSION_ROM     0x30
#define PCI_CS_INTERRUPT_LINE    0x3C
#define PCI_CS_INTERRUPT_PIN     0x3D
#define PCI_CS_MIN_GNT           0x3E
#define PCI_CS_MAX_LAT           0x3F

#define PCI_CS_N_BASE_ADDRESS    6     /* max number of address spaces */


#define PCI_CMD_ENB_IO_ACC       0x01
#define PCI_CMD_ENB_MEM_ACC      0x02


typedef struct
{
  uint8_t prog_if;
  uint8_t sub;
  uint8_t base;
} PCI_CLASS;

#define PCI_N_BASE_ADDR_FIELD  6

typedef struct
{
  uint16_t vendor_id;
  uint16_t device_id;
  uint16_t command;
  uint16_t status;
  uint8_t revision_id;
  PCI_CLASS class_code;
  uint8_t cache_line_size;
  uint8_t latency_timer;
  uint8_t header_type;
  uint8_t bist;
  uint32_t base_addr[PCI_N_BASE_ADDR_FIELD];
  uint32_t cardbus_cis;
  uint16_t sub_vendor_id;
  uint16_t sub_system_id;
  uint32_t expansion_rom_base;
  uint32_t res_0;
  uint32_t res_1;
  uint8_t irq_line;
  uint8_t irq_pin;
  uint8_t min_gnt;
  uint8_t max_lat;
} PCI_CFG_SPACE;



// some known vendor IDs, in alphabetical order:

#define PCI_VENDOR_3COM                 0x10B7
#define PCI_VENDOR_ADAPTEC_1            0x9004
#define PCI_VENDOR_ADAPTEC_2            0x9005
#define PCI_VENDOR_AMCC                 0x10E8
#define PCI_VENDOR_AMD                  0x1022
#define PCI_VENDOR_ASUS                 0x1000
#define PCI_VENDOR_CIRRUS_LOGIC         0x1013
#define PCI_VENDOR_ELSA                 0x5333
#define PCI_VENDOR_IBM                  0x1014
#define PCI_VENDOR_INTEL                0x8086
#define PCI_VENDOR_MATROX               0x102B
#define PCI_VENDOR_MEINBERG             0x1360

/* End of header body */

#undef _ext



/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

// currently none

#ifdef __cplusplus
}
#endif


#endif  /* _PCIDEFS_H */

