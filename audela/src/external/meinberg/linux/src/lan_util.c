
/**************************************************************************
 *
 *  $Id: lan_util.c 1.1.1.13 2011/09/20 16:14:03 martin TEST martin $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Utility functions useful for network programming.
 *
 * -----------------------------------------------------------------------
 *  $Log: lan_util.c $
 *  Revision 1.1.1.13  2011/09/20 16:14:03  martin
 *  Fix for old Linux ethtool headers.
 *  Revision 1.1.1.12  2011/09/14 13:50:48  martin
 *  Rewrote some functions sharing common code.
 *  Use predefined return values for those functions.
 *  Renamed some functions to more appropriate names.
 *  Revision 1.1.1.11  2011/09/08 10:37:36  udo
 *  Revision 1.1.1.10  2011/08/27 14:26:47  udo
 *  new get_port_ip4_addr() and get_port_ip4_netm()
 *  Revision 1.1.1.9  2011/08/27 13:34:57  udo
 *  new get_port_ip4_addr() and get_port_ip4_netm()
 *  Revision 1.1.1.8  2011/08/25 20:39:36  martin
 *  Added new functions to deal with MAC addresses.
 *  Revision 1.1.1.7  2011/08/09 08:13:19  philipp
 *  proper return code evaluating
 *  Revision 1.1.1.6  2011/08/08 16:12:08  martin
 *  Revision 1.1.1.5  2011/08/08 16:02:28  martin
 *  Revision 1.1.1.4  2011/08/04 13:46:12  philipp
 *  Linux implementation of function check_port_link
 *  which performs a link detection test for a specific, given interface
 *  Revision 1.1.1.3  2011/06/21 15:23:30  martin
 *  Fixed build under DOS.
 *  Revision 1.1.1.2  2011/04/20 16:08:55Z  martin
 *  Revision 1.1.1.1  2011/03/04 10:33:22  martin
 *  Implemented dummy snprintf() function for environments
 *  which don't provide this.
 *  Revision 1.1  2011/03/04 10:01:32Z  martin
 *  Initial revision.
 *
 **************************************************************************/

#define _LAN_UTIL
  #include <lan_util.h>
#undef _LAN_UTIL

#include <stdio.h>
#include <string.h>

#if defined ( MBG_TGT_UNIX )

  #if defined ( MBG_TGT_LINUX )

    #include <linux/types.h>

    // Some older versions of linux/types.h don't define u8..u64
    // for user space applications. However, if they do they also
    // define BITS_PER_LONG, so we use this symbol to figure out
    // if we need to define u8..u64 by ourselves.
    #if !defined( BITS_PER_LONG )
      typedef uint8_t u8;
      typedef uint16_t u16;
      typedef uint32_t u32;
      typedef uint64_t u64;
    #endif

    #include <linux/sockios.h>
    #include <linux/ethtool.h>

  #endif

  #include <sys/ioctl.h>
  #include <unistd.h>
  #include <netinet/in.h>
  #include <arpa/inet.h>

#endif


// Maximum size of an IPv4 address string in dotted quad format,
// including a terminating 0, and thus the required minimum size
// for a buffer to take such a string. i.e. "aaa.bbb.ccc.ddd\0".
#define MAX_IP4_ADDR_STR_SIZE   16



#if defined( __BORLANDC__ ) \
    && ( __BORLANDC__ <= 0x410 )   // BC3.1 defines 0x410 !

#include <stdarg.h>

// Declare a snprintf() function if not provided by the
// build environment, though this implementation actually
// does not check the string length  ...

static /*HDR*/
int snprintf( char *s, size_t max_len, const char *fmt, ... )
{
  int n;
  va_list arg_list;

  va_start( arg_list, fmt );
  n = vsprintf( s, fmt, arg_list );
  va_end( arg_list );

  return n;

}  // snprintf

#endif



/*HDR*/
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
int snprint_ip4_addr( char *s, size_t max_len, const IP4_ADDR *addr, const char *info )
{
  int n = 0;

  if ( info )
    n += snprintf( s, max_len, "%s", info );

  // Don't use byte pointers here since this is not safe
  // for both little and big endian targets.
  n += snprintf( &s[n], max_len - n, "%i.%i.%i.%i",
                 ( (*addr) >> 24 ) & 0xFF,
                 ( (*addr) >> 16 ) & 0xFF,
                 ( (*addr) >> 8 ) & 0xFF,
                 ( (*addr) ) & 0xFF
               );
  return n;

}  // snprint_ip4_addr



/*HDR*/
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
int str_to_ip4_addr( IP4_ADDR *p, const char *s )
{
  IP4_ADDR tmp_ip4_addr = 0;
  char *cp;
  int i;

  for ( i = 0, cp = (char *) s; ; )
  {
    unsigned long ul = strtoul( cp, &cp, 10 );

    if ( ul > 255 )  // invalid number
      return -1;

    tmp_ip4_addr |= ul << ( 8 * (3 - i) );

    if ( ++i >= 4 )
      break;        // done

    if ( *cp != '.' )
      return -2;    // invalid string format, dot expected

    cp++;  // skip dot
  }

  if ( p )
    *p = tmp_ip4_addr;

  return cp - (char *) s;  // success

}  // str_to_ip4_addr



/*HDR*/
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
int snprint_octets( char *s, size_t max_len, const uint8_t *octets,
                    int num_octets, char sep, const char *info )
{
  int n = 0;
  int i;

  if ( info )
    n += snprintf( s, max_len, "%s", info );

  for ( i = 0; i < num_octets; i++ )
  {
    if ( i && sep )
      n += snprintf( &s[n], max_len - n, "%c", sep );

    n += snprintf( &s[n], max_len - n, "%02X", octets[i] );
  }

  return n;

}  // snprint_octets



/*HDR*/
/**
 * @brief Print a MAC address to a string.
 *
 * @param s           The string buffer into which to print
 * @param max_len     Maximum length of the string, i.e. size of the buffer
 * @param p_mac_addr  The MAC address to be printed
 *
 * @return  The overall number of characters printed to the string
 */
int snprint_mac_addr( char *s, size_t max_len, const MBG_MAC_ADDR *p_mac_addr )
{
  return snprint_octets( s, max_len, p_mac_addr->b, sizeof( *p_mac_addr ), MAC_SEP_CHAR, NULL );

}  // snprint_mac_addr



/*HDR*/
/**
 * @brief Set a MAC ID or a similar array of octets from a string.
 *
 * @param octets      An array of octets to be set up
 * @param num_octets  The number of octets which can be stored
 * @param s           The string to be converted
 *
 * @return  The overall number of octets decoded from the string
 */
int str_to_octets( uint8_t *octets, int num_octets, const char *s )
{
  char *cp = (char *) s;
  int i;

  // don't use strtok() since that functions modifies the original string
  for ( i = 0; i < num_octets; )
  {
    octets[i] = (uint8_t) strtoul( cp, &cp, 16 );
    i++;

    if ( *cp == 0 )
      break;      // end of string

    if ( ( *cp != MAC_SEP_CHAR ) && ( *cp != MAC_SEP_CHAR_ALT ) )
      break;      // invalid character

    cp++;
  }

  return i;

}  // str_to_octets



/*HDR*/
/**
 * @brief Check if an array of octets is valid, i.e. != 0
 *
 * @param octets      Pointer to the array of octets
 * @param num_octets  Number of octets
 *
 * @return MBG_LU_SUCCESS      octets are valid, i.e. not all 0
 *         MBG_LU_ERR_NOT_SET  octets are invalid, i.e. all 0
 */
int check_octets_not_all_zero( const uint8_t *octets, int num_octets )
{
  int i;

  // check if any of the MAC adddress bytes is != 0
  for ( i = 0; i < num_octets; i++ )
    if ( octets[i] != 0 )
      break;

  if ( i == num_octets ) // *all* bytes are 0
    return MBG_LU_ERR_NOT_SET;

  return 0;

}  // check_octets_not_all_zero



#if defined( MBG_TGT_UNIX )

/*HDR*/
/**
 * @brief Do a SIOCGxxx IOCTL call to read specific information from a LAN interface
 *
 * @param if_name     Name of the interface
 * @param ioctl_code  One of the predefined system SIOCGxxx IOCTL codes
 * @param p_ifreq     Pointer to a request buffer
 *
 * @return  one of the MBG_LU_xxx codes
 */
int do_siocg_ioctl( const char *if_name, int ioctl_code, struct ifreq *p_ifreq )
{
  int fd;
  int rc;

  if ( strlen( if_name ) > ( IFNAMSIZ - 1 ) )
    return MBG_LU_ERR_PORT_NAME;

  fd = socket( AF_INET, SOCK_DGRAM, 0 );

  if ( fd < 0 )
    return MBG_LU_ERR_SOCKET;

  strcpy( p_ifreq->ifr_name, if_name );

  rc = ioctl( fd, ioctl_code, p_ifreq );

  if ( rc < 0 )
    rc = MBG_LU_ERR_IOCTL;

  close( fd );

  return MBG_LU_SUCCESS;

}  // do_siocg_ioctl

#endif  //  defined( MBG_TGT_UNIX )



/*HDR*/
/**
 * @brief Retrieve the MAC address of a network interface
 *
 * @param if_name     Name of the interface
 * @param p_mac_addr  Pointer to the MAC address buffer to be filled up
 *
 * @return  one of the MBG_LU_xxx codes
 *          on error the MAC addr is set to all 0
 */
int get_port_mac_addr( const char *if_name, MBG_MAC_ADDR *p_mac_addr )
{
  int rc = MBG_LU_ERR_NSUPP;

  #if defined( MBG_TGT_LINUX )
    struct ifreq ifr = { { { 0 } } };

    rc = do_siocg_ioctl( if_name, SIOCGIFHWADDR, &ifr );

    if ( rc != MBG_LU_SUCCESS )
      goto fail;

    memcpy( p_mac_addr, ifr.ifr_hwaddr.sa_data, sizeof( *p_mac_addr ) );

    return rc;

fail:
  #endif

  memset( p_mac_addr, 0, sizeof( *p_mac_addr ) );

  return rc;

}  // get_port_mac_addr



/*HDR*/
/**
 * @brief Retrieve and check the MAC address of a network interface
 *
 * @param if_name   Name of the interface
 * @param p_mac_addr  Pointer to the MAC address buffer to be filled up
 *
 * @return  one of the MBG_LU_xxx codes
 *          on error the MAC addr is set to all 0
 */
int get_port_mac_addr_check( const char *if_name, MBG_MAC_ADDR *p_mac_addr )
{
  int rc = get_port_mac_addr( if_name, p_mac_addr );

  if ( rc == MBG_LU_SUCCESS )
  {
    if ( !check_octets_not_all_zero( p_mac_addr->b, sizeof( *p_mac_addr ) ) )
      rc = MBG_LU_ERR_NOT_SET;
  }

  return rc;

}  // get_port_mac_addr_check



/*HDR*/
/**
 * @brief Check the link state of a network interface
 *
 * @param ifname  Name of the interface
 *
 * @return 1 link detected on port
 *         0 no link detected on port
 *         one of the MBG_LU_xxx codes in case of an error
 */
int check_port_link( const char *if_name )
{
  #if defined( MBG_TGT_LINUX )
    struct ifreq ifr = { { { 0 } } };
    struct ethtool_value edata = { 0 };
    int rc;

    edata.cmd = ETHTOOL_GLINK; // defined in ethtool.h
    ifr.ifr_data = (caddr_t) &edata;

    rc = do_siocg_ioctl( if_name, SIOCETHTOOL, &ifr );

    if ( rc == MBG_LU_SUCCESS )
      rc = edata.data != 0;

    return rc;

  #else

    return MBG_LU_ERR_NSUPP;

  #endif

}  // check_port_link



/*HDR*/
/**
 * @brief Retrieve the IPv4 address of a network interface as string
 *
 * @param if_name     Name of the interface
 * @param p_addr_buf  Pointer to the string buffer to be filled up
 * @param buf_size    size of the string buffer
 *
 * @return  one of the MBG_LU_xxx codes
 */
int get_port_ip4_addr_str( const char *if_name, char *p_addr_buf, int buf_size )
{
  int rc = MBG_LU_ERR_NSUPP;

  #if defined( MBG_TGT_LINUX )
    struct ifreq ifr = { { { 0 } } };

    rc = do_siocg_ioctl( if_name, SIOCGIFADDR, &ifr );

    if ( rc != MBG_LU_SUCCESS )
      goto fail;


    if ( buf_size < MAX_IP4_ADDR_STR_SIZE )  //###+++
    {
      rc = MBG_LU_ERR_BUFF_SZ;
      goto fail;
    }

    strncpy( p_addr_buf, inet_ntoa( ( (struct sockaddr_in *) &ifr.ifr_addr )->sin_addr ), buf_size - 1 );
    p_addr_buf[buf_size-1] = 0;   // force terminating 0

    return rc;

fail:
  #endif

  *p_addr_buf = 0;  // make empty string

  return rc;

}  // get_port_ip4_addr_str



/*HDR*/
/**
 * @brief Retrieve the IPv4 net mask of a network interface as string
 *
 * @param if_name     Name of the interface
 * @param p_addr_buf  Pointer to the string buffer to be filled up
 * @param buf_size    size of the string buffer
 *
 * @return  one of the MBG_LU_xxx codes
 */
int get_port_ip4_netmask_str( const char *if_name, char *p_addr_buf, int buf_size )
{
  int rc = MBG_LU_ERR_NSUPP;

  #if defined( MBG_TGT_LINUX )
    struct ifreq ifr = { { { 0 } } };

    rc = do_siocg_ioctl( if_name, SIOCGIFNETMASK, &ifr );

    if ( rc != MBG_LU_SUCCESS )
      goto fail;

    if ( buf_size < MAX_IP4_ADDR_STR_SIZE )  //###++++
    {
      rc = MBG_LU_ERR_BUFF_SZ;
      goto fail;
    }

    strncpy( p_addr_buf, inet_ntoa( ( (struct sockaddr_in *) &ifr.ifr_netmask )->sin_addr ), buf_size - 1 );
    p_addr_buf[buf_size-1] = 0;   // force terminating 0

    return rc;

fail:
  #endif

  *p_addr_buf = 0;  // make empty string

  return rc;

}  // get_port_ip4_netmask_str


