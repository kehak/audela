
/**************************************************************************
 *
 *  $Id: pcpsirq.h 1.7.1.2 2011/06/29 11:03:28 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    OS independent definitions used to handle interrupts from
 *    Meinberg PCI devices.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsirq.h $
 *  Revision 1.7.1.2  2011/06/29 11:03:28  martin
 *  Updated a comment.
 *  Revision 1.7.1.1  2011/02/09 17:22:36  martin
 *  Revision 1.7  2008/12/05 12:20:36  martin
 *  Protect HW access to enable/disable IRQ by mutex.
 *  Support mapped I/O resources.
 *  Changes due to renamed library macros.
 *  Revision 1.6  2007/07/20 10:16:52  martin
 *  Reworte some IRQ macros.
 *  Moved some AMCC specific definitions to amccdefs.h.
 *  Removed obsolete code.
 *  Revision 1.5  2007/06/06 11:15:27Z  martin
 *  Fixed syntax of some macros.
 *  Revision 1.4  2007/03/01 16:15:34Z  martin
 *  Use generic port I/O macros.
 *  Revision 1.3  2004/11/09 14:44:21  martin
 *  Use C99 fixed-size data types if required.
 *  Revision 1.2  2003/04/02 07:51:37  martin
 *  Added support for devices with PCI_ASIC.
 *  Revision 1.1  2001/03/28 09:36:43Z  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _PCPSIRQ_H
#define _PCPSIRQ_H


#include <pcpsdrvr.h>
#include <amccdefs.h>
#include <pci_asic.h>


#define _set_port_bit( _d, _adr, _msk )  \
  _mbg_outp8( (_d), 0, _adr, _mbg_inp8( (_d), 0, _adr ) | (_msk) )

#define _clear_port_bit( _d, _adr, _msk )  \
  _mbg_outp8( (_d), 0, _adr, _mbg_inp8( (_d), 0, _adr ) & ~(_msk) )


// Each of the macros below expects a parameter _d which is
// a pointer to the PCPS_DDEV structure which represents the
// hardware device.

// The macros below generate code only if MCA support is enabled.

#if _PCPS_USE_MCA
  #define MCIC_IRQ              0x04
  #define _mcic_enb_reg( _r )   ( (_r) + 0x0A )
  #define _mcic_ack_reg( _r )   ( (_r) + 0x0B )

  // No MCA dependent local variables required, and no
  // MCA dependent interrupt flag to check.

  // In ISR function, pass acknowledge to the MCA
  // interface chip.
  #define _pcps_ddev_ack_irq_mca( _d )                                              \
  if ( _pcps_ddev_is_mca( _d ) )                                                    \
  {                                                                                 \
    PCPS_IO_ADDR_MAPPED port = _mcic_ack_reg( _pcps_ddev_io_base_mapped( _d, 0 ) ); \
    _set_port_bit( (_d), port, MCIC_IRQ );                                          \
  }

  // In IRQ init function, enable IRQ on the
  // interface chip.
  #define _pcps_ddev_enb_irq_mca( _d )                                    \
  if ( _pcps_ddev_is_mca( _d ) )                                          \
  {                                                                       \
    uint16_t port = _mcic_enb_reg( _pcps_ddev_io_base_mapped( _d, 0 ) );  \
    set_pos_reg( 4, _pcps_ddev_slot_num( _d ), active_irq.map_code );     \
    _set_port_bit( (_d), port, MCIC_IRQ );                                \
  }

  // In IRQ de-init function, disable IRQ on the
  // interface chip.
  #define _pcps_ddev_disb_irq_mca( _d )                                  \
  if ( _pcps_ddev_is_mca( _d ) )                                         \
  {                                                                      \
    uint16_t port = _mcic_enb_reg( _pcps_ddev_io_base_mapped( _d, 0 ) ); \
    _clear_port_bit( (_d), port, MCIC_IRQ );                             \
  }

#else

  // Do nothing if MCA not supported.
  #define _pcps_ddev_enb_irq_mca( _d );
  #define _pcps_ddev_disb_irq_mca( _d );
  #define _pcps_ddev_ack_irq_mca( _d );

#endif



// The macros below generate code only if PCI support is enabled.

#if ( _PCPS_USE_PCI )
  // In ISR function, pass acknowledge to the PCI
  // interface chip.
  // 1.) Read PCI incoming mailbox to clear IRQ.
  // 2.) Clear interrupt source, deassert INTA# signal
  //     and leave interrupt enabled by writing '1's to
  //     the interrupt flag and interrupt enable bits.
  #define _pcps_ddev_ack_irq_pci( _d )                              \
  if ( (_d)->irq_ack_mask )                                         \
  {                                                                 \
    if ( _pcps_ddev_is_pci_amcc( _d ) )                             \
      _mbg_inp32( (_d), 0, _pcps_ddev_io_base_mapped( _d, 0 )       \
                       + AMCC_OP_REG_IMB4 );                        \
                                                                    \
    _mbg_outp32( (_d), 0, (_d)->irq_ack_port, (_d)->irq_ack_mask ); \
  }

  // In IRQ init function, enable IRQ on the
  // interface chip.
  #define _pcps_ddev_enb_irq_pci( _d )                                       \
  if ( (_d)->irq_enb_mask )                                                  \
  {                                                                          \
    uint32_t intcsr = _mbg_inp32_to_cpu( (_d), 0, (_d)->irq_enb_disb_port ); \
    _mbg_outp32( (_d), 0, (_d)->irq_enb_disb_port,                           \
                  intcsr | (_d)->irq_enb_mask );                             \
  }

  // In IRQ de-init function, disable IRQ on the
  // interface chip.
  #define _pcps_ddev_disb_irq_pci( _d )                                      \
  if ( (_d)->irq_disb_mask )                                                 \
  {                                                                          \
    uint32_t intcsr = _mbg_inp32_to_cpu( (_d), 0, (_d)->irq_enb_disb_port ); \
    _mbg_outp32( (_d), 0, (_d)->irq_enb_disb_port,                           \
                  intcsr & ~(_d)->irq_disb_mask );                           \
  }

#else
  // Do nothing if PCI not supported.
  #define _pcps_ddev_enb_irq_pci( _d );
  #define _pcps_ddev_disb_irq_pci( _d );
  #define _pcps_ddev_ack_irq_pci( _d );
#endif



// In ISR function, verify that the hardware device has
// really generated the current IRQ.
// If device is PCI the interface chip's IRQ flag is set.
// For non-PCI devices check the IRQ flag of the clock's
// status port.
#if ( _PCPS_USE_PCI )
  #define _pcps_ddev_has_gen_irq( _d )                                       \
    ( ( (_d)->irq_flag_mask ) ?                                              \
      ( _mbg_inp32( (_d), 0, (_d)->irq_flag_port ) & (_d)->irq_flag_mask ) : \
      ( _pcps_ddev_read_status_port( _d ) & PCPS_ST_IRQF )                   \
    )

#else
  #define _pcps_ddev_has_gen_irq( _d ) \
      ( _pcps_ddev_read_status_port( _d ) & PCPS_ST_IRQF )
#endif


// In ISR function, acknowledge IRQ requests to the
// hardware device.
#define _pcps_ddev_ack_irq( _d )  \
{                                 \
  _pcps_ddev_ack_irq_pci( _d );   \
  _pcps_ddev_ack_irq_mca( _d );   \
}


// The macro below should be called at the end of the
// interrupt initialization function to instruct the
// radio clock hardware to generate IRQs. This code
// must be executed after the IRQ service function
// has been registered.
// The _cmd parameter must be one of the PCPS_IRQ_...
// codes defined in pcpsdefs.h which determine the
// IRQ rate (per second, per minute, etc.)
#define _pcps_ddev_enb_irq( _d, _cmd )   \
{                                        \
  _pcps_sem_inc( _d );                   \
  _pcps_ddev_enb_irq_mca( _d );          \
  _pcps_ddev_enb_irq_pci( _d );          \
  _pcps_write_byte( _d, _cmd );          \
  _pcps_sem_dec( _d );                   \
}


// The macro below should be called at the beginning
// of the interrupt deinitialization function to instruct
// the radio clock hardware to stop generating IRQs.
// This code must be executed before the IRQ service function
// is deregistered.
#define _pcps_ddev_disb_irq( _d )        \
{                                        \
  _pcps_sem_inc( _d );                   \
  _pcps_write_byte( _d, PCPS_IRQ_NONE ); \
  _pcps_ddev_disb_irq_mca( _d );         \
  _pcps_ddev_disb_irq_pci( _d );         \
  _pcps_sem_dec( _d );                   \
}


#endif  /* _PCPSIRQ_H */
