
/**************************************************************************
 *
 *  $Id: lan_util.h 1.1.1.7 2011/09/14 13:51:58 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for lan_util.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: lan_util.h $
 *  Revision 1.1.1.7  2011/09/14 13:51:58  martin
 *  Defined some common return codes.
 *  Updated function prototypes.
 *  Revision 1.1.1.6  2011/08/27 14:26:47  udo
 *  new get_port_ip4_addr() and get_port_ip4_netm()
 *  Revision 1.1.1.5  2011/08/27 13:35:05  udo
 *  new get_port_ip4_addr() and get_port_ip4_netm()
 *  Revision 1.1.1.4  2011/08/25 20:39:14  martin
 *  Defined MBG_MAC_ADDR.
 *  Updated function prototypes
 *  Revision 1.1.1.3  2011/08/04 13:44:55  philipp
 *  prototype for function:  check_port_link
 *  Revision 1.1.1.2  2011/06/22 07:47:48  martin
 *  Cleaned up handling of pragma pack().
 *  Revision 1.1.1.1  2011/04/20 16:09:02  martin
 *  Revision 1.1  2011/03/04 10:01:32  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _LAN_UTIL_H
#define _LAN_UTIL_H


/* Other headers to be included */

#include <mbg_tgt.h>
#include <gpsdefs.h>

#include <stdlib.h>

#if defined( MBG_TGT_UNIX )
  #include <sys/types.h>
  #include <sys/socket.h>
  #include <net/if.h>
#else
  // A dummy declaration to prevent from warnings due to usage
  // of this type with function prototypes.
  struct ifreq
  {
    int dummy;
  };
#endif

#ifdef _LAN_UTIL
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif

#ifdef __cplusplus
extern "C" {
#endif


#if !defined( MAC_SEP_CHAR )
  #define MAC_SEP_CHAR      ':'   // character used to separate octets of a MAC ID
#endif

#if !defined( MAC_SEP_CHAR_ALT )
  #define MAC_SEP_CHAR_ALT  '-'   // alternate character
#endif

#if !defined( IFHWADDRLEN )
  #define IFHWADDRLEN  6    //##+++++ usually defined in net/if.h
#endif

#define MBG_LU_SUCCESS         0  // success
#define MBG_LU_ERR_NSUPP      -1  // function not supported
#define MBG_LU_ERR_PORT_NAME  -2  // port name exceeds max length
#define MBG_LU_ERR_SOCKET     -3  // failed to open socket
#define MBG_LU_ERR_IOCTL      -4  // IOCTL call failed
#define MBG_LU_ERR_NOT_SET    -5  // octets are all 0
#define MBG_LU_ERR_BUFF_SZ    -6  // buffer size too small


typedef struct
{
  uint8_t b[IFHWADDRLEN];
} MBG_MAC_ADDR;



/* function prototypes: */

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 /**
 * @brief Print an IPv4 address to a dotted quad format string.
 *
 * @param s        The string buffer into which to print
 * @param max_len  Maximum length of the string, i.e. size of the buffer
 * @param addr     The IPv4 address
 * @param info     An optional string which is prepended to the string, or NULL
 *
 * @return The overall number of characters printed to the string
 */
 int snprint_ip4_addr( char *s, size_t max_len, const IP4_ADDR *addr, const char *info ) ;

 /**
 * @brief Convert a string to an IP4_ADDR.
 *
 * @param p  Pointer to the IP4_ADDR variable, or NULL, in which case this
 *           function can be used to check if the string is formally correct.
 * @param s  The string to be converted
 *
 * @return  >= 0  on success, number of characters evaluated from the input string
 *         -1  if invalid number found in string
 *         -2  if separator is not a dot '.'
 */
 int str_to_ip4_addr( IP4_ADDR *p, const char *s ) ;

 /**
 * @brief Print a MAC ID or similar array of octets to a string.
 *
 * @param s           The string buffer into which to print
 * @param max_len     Maximum length of the string, i.e. size of the buffer
 * @param octets      An array of octets
 * @param num_octets  The number of octets to be printed from the array
 * @param sep         The separator printed between the bytes, or 0
 * @param info        An optional string which is prepended to the output, or NULL
 *
 * @return  The overall number of characters printed to the string
 */
 int snprint_octets( char *s, size_t max_len, const uint8_t *octets, int num_octets, char sep, const char *info ) ;

 /**
 * @brief Print a MAC address to a string.
 *
 * @param s           The string buffer into which to print
 * @param max_len     Maximum length of the string, i.e. size of the buffer
 * @param p_mac_addr  The MAC address to be printed
 *
 * @return  The overall number of characters printed to the string
 */
 int snprint_mac_addr( char *s, size_t max_len, const MBG_MAC_ADDR *p_mac_addr ) ;

 /**
 * @brief Set a MAC ID or a similar array of octets from a string.
 *
 * @param octets      An array of octets to be set up
 * @param num_octets  The number of octets which can be stored
 * @param s           The string to be converted
 *
 * @return  The overall number of octets decoded from the string
 */
 int str_to_octets( uint8_t *octets, int num_octets, const char *s ) ;

 /**
 * @brief Check if an array of octets is valid, i.e. != 0
 *
 * @param octets      Pointer to the array of octets
 * @param num_octets  Number of octets
 *
 * @return MBG_LU_SUCCESS      octets are valid, i.e. not all 0
 *         MBG_LU_ERR_NOT_SET  octets are invalid, i.e. all 0
 */
 int check_octets_not_all_zero( const uint8_t *octets, int num_octets ) ;

 /**
 * @brief Do a SIOCGxxx IOCTL call to read specific information from a LAN interface
 *
 * @param if_name     Name of the interface
 * @param ioctl_code  One of the predefined system SIOCGxxx IOCTL codes
 * @param p_ifreq     Pointer to a request buffer
 *
 * @return  one of the MBG_LU_xxx codes
 */
 int do_siocg_ioctl( const char *if_name, int ioctl_code, struct ifreq *p_ifreq ) ;

 /**
 * @brief Retrieve the MAC address of a network interface
 *
 * @param if_name     Name of the interface
 * @param p_mac_addr  Pointer to the MAC address buffer to be filled up
 *
 * @return  one of the MBG_LU_xxx codes
 *          on error the MAC addr is set to all 0
 */
 int get_port_mac_addr( const char *if_name, MBG_MAC_ADDR *p_mac_addr ) ;

 /**
 * @brief Retrieve and check the MAC address of a network interface
 *
 * @param if_name   Name of the interface
 * @param p_mac_addr  Pointer to the MAC address buffer to be filled up
 *
 * @return  one of the MBG_LU_xxx codes
 *          on error the MAC addr is set to all 0
 */
 int get_port_mac_addr_check( const char *if_name, MBG_MAC_ADDR *p_mac_addr ) ;

 /**
 * @brief Check the link state of a network interface
 *
 * @param ifname  Name of the interface
 *
 * @return 1 link detected on port
 *         0 no link detected on port
 *         one of the MBG_LU_xxx codes in case of an error
 */
 int check_port_link( const char *if_name ) ;

 /**
 * @brief Retrieve the IPv4 address of a network interface as string
 *
 * @param if_name     Name of the interface
 * @param p_addr_buf  Pointer to the string buffer to be filled up
 * @param buf_size    size of the string buffer
 *
 * @return  one of the MBG_LU_xxx codes
 */
 int get_port_ip4_addr_str( const char *if_name, char *p_addr_buf, int buf_size ) ;

 /**
 * @brief Retrieve the IPv4 net mask of a network interface as string
 *
 * @param if_name     Name of the interface
 * @param p_addr_buf  Pointer to the string buffer to be filled up
 * @param buf_size    size of the string buffer
 *
 * @return  one of the MBG_LU_xxx codes
 */
 int get_port_ip4_netmask_str( const char *if_name, char *p_addr_buf, int buf_size ) ;


/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */


#undef _ext
#undef _DO_INIT

#endif  /* _LAN_UTIL_H */

