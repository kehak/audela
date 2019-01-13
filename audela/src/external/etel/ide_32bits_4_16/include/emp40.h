/*
 * emp40.h
 *
 * Copyright (c) 1997-2016 ETEL SA. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of ETEL SA 
 * ("Confidential Information"). You shall not disclose such Confidential 
 * Information and shall use it only in accordance with the terms of the 
 * license agreement you entered into with ETEL.
 *
 * This software is provided "AS IS" without a warranty or representations of any kind. 
 * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT ARE HEREBY EXCLUDED. ETEL AND ITS 
 * LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING 
 * THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL ETEL OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR 
 * DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS 
 * OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE SOFTWARE, EVEN IF ETEL HAS BEEN ADVISED OF 
 * THE POSSIBILITY OF SUCH DAMAGES. THE ENTIRE RISK ARISING OUT OF USE, PERFORMANCE OR NON-PERFORMANCE OF THE SOFTWARE 
 * REMAINS WITH THE LICENSEE. IF ETEL SHOULD NEVERTHELESS BE FOUND LIABLE, WHETER DIRECTLY OR INDRECTLY, FOR ANY LOSS, 
 * DAMAGE OR INJURY ARISING UNDER THIS AGREEMENT OR OTHERWISE, REGARDLESS OF CAUSE OR ORIGIN, ON ANY BASIS WHATSOEVER, 
 * ITS TOTAL MAXIMUM LIABILITY IS LIMITED TO CHF 100.000 WHICH WILL BE THE COMPLETE AND EXCLUSIVE REMEDY AGAINST ETEL.

 * This software is in particular not designed or intended .for use in on-line control of aircraft, air traffic, aircraft 
 * navigation or aircraft communications; or in the design, construction, Operation or maintenance of any nuclear facility. 
 * Licensee represents and warrants that it will not use or redistribute the Software for such purposes.
 */

 /**********************************************************************************************
									THIRD-PARTY LICENSE

EDI Windows version uses 7ZIP functionality, especially for System Configuration Management.
7z.exe and 7z.dll are piece of binary code, provided with EDI package.
The source code can be found here: http://www.7-zip.org
These piece of program are subject to following licensing:
---------------------------------------------------------------------------
  7-Zip
  -----
  License for use and distribution
  --------------------------------

  7-Zip Copyright (C) 1999-2011 Igor Pavlov.

  Licenses for files are:

    1) 7z.dll: GNU LGPL + unRAR restriction
    2) All other files:  GNU LGPL

  The GNU LGPL + unRAR restriction means that you must follow both 
  GNU LGPL rules and unRAR restriction rules.


  Note: 
    You can use 7-Zip on any computer, including a computer in a commercial 
    organization. You don't need to register or pay for 7-Zip.


  GNU LGPL information
  --------------------

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You can receive a copy of the GNU Lesser General Public License from 
    http://www.gnu.org/


  unRAR restriction
  -----------------

    The decompression engine for RAR archives was developed using source 
    code of unRAR program.
    All copyrights to original unRAR code are owned by Alexander Roshal.

    The license for original unRAR code has the following restriction:

      The unRAR sources cannot be used to re-create the RAR compression algorithm, 
      which is proprietary. Distribution of modified unRAR sources in separate form 
      or as a part of other software is permitted, provided that it is clearly
      stated in the documentation and source comments that the code may
      not be used to develop a RAR (WinRAR) compatible archiver.


  --
  Igor Pavlov
---------------------------------------------------------------------------

**********************************************************************************************************/

/**********************************************************************************************************
 * Modification added by ClearCase CheckIN comments:
 $CC_KEYWORD_EXPAND$
\main\ETL_BR_DEV_PC_MFB\1     Tue Nov  8 17:21:13 2016    ch5151

\main\21     Tue Sep 20 10:26:13 2016    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Tue Sep 20 10:13:24 2016    ch5151

\main\20     Mon Jul  4 15:48:40 2016    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Mon Jul  4 15:39:20 2016    ch5151

\main\12     Fri Nov 20 17:17:18 2015    ch5151

\main\ETL_BR_DEV_ULTIADV_MFB\1     Fri Nov 20 17:14:30 2015    ch5151

\main\11     Fri May  8 11:09:34 2015    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Fri May  8 10:45:59 2015    ch5151

\main\10     Fri Mar 27 13:43:44 2015    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Fri Mar 27 13:38:44 2015    ch5151

\main\9     Fri Feb 27 07:52:24 2015    ch52177

\main\8     Thu Jan 22 18:24:54 2015    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Thu Jan 22 18:22:31 2015    ch5151

\main\7     Thu Jan 22 10:24:22 2015    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Thu Jan 22 09:22:02 2015    ch5151

\main\6     Tue Jan 20 11:47:44 2015    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Tue Jan 20 11:46:11 2015    ch5151

\main\9     Thu Dec 11 16:40:26 2014    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Thu Dec 11 14:57:36 2014    ch5151

\main\5     Fri Sep 26 14:29:40 2014    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Fri Sep 26 14:26:46 2014    ch5151

\main\4     Thu Jul 17 13:41:45 2014    ch52177

\main\ETL_BR_DEV_ULTIMET_BCO\2     Thu Jul 17 13:28:09 2014    ch52177

\main\ETL_BR_DEV_ULTIMET_BCO\1     Thu Jun 26 16:58:32 2014    ch52177

\main\3     Wed Apr 30 07:50:25 2014    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Tue Apr 29 10:52:11 2014    ch5151

\main\2     Thu Feb  6 10:46:58 2014    ch52177

\main\ETL_BR_DEV_ULTIMET_BCO\1     Thu Feb  6 10:44:55 2014    ch52177

\main\1     Thu Feb  6 09:24:39 2014    ch52177
addition of emp library
\main\ETL_BR_DEV_ULTIMET_BCO\1     Thu Feb  6 09:14:09 2014    ch52177
addition of emp library
\main\12     Thu Jan 23 11:21:31 2014    ch5151

\main\ETL_BR_DEV_PC_MFB\1     Thu Jan 23 11:19:23 2014    ch5151
Add dsa_quick_stop flags allowing to stop movement with urgent command without stopping sequence
 *********************************************************************************************************/

/**
 * This header file contains public declarations for the ETEL Metadata Parser library.\n
 * @file emp40.h
 */


#ifndef _EMP40_H
#define _EMP40_H

#ifdef WIN32
	#define _EMP_EXPORT __cdecl                          /* function exported by static library */
#endif /* WIN32 */

#if defined POSIX || defined VXWORKS_6_9
	#define _EMP_EXPORT
#endif

#ifdef F_ITRON
	#define _EMP_EXPORT __cdecl
#endif /*F_ITRON*/

#define EMP_STRING_SIZE 	50
#define EMP_NAME_TAG_SIZE	50

/*------------------------------------------------------------------------------
 * error codes - c
 *-----------------------------------------------------------------------------*/
#define EMP_ESIZEBUF                     -114        /**< size of buffer too big */
#define EMP_EFGETS                       -113        /**< error in fgets */
#define EMP_EALLOC                       -112        /**< memory allocation error */
#define EMP_ECHARNOTSUP                  -111        /**< character or data not supported */
#define EMP_ECONTENTTAG                  -110        /**< error in content of tag */
#define EMP_ECDATA                       -109        /**< error in CDATA value */
#define EMP_ENOENDBUF                    -108        /**< no end of buffer found */
#define EMP_ESIZETAG                     -107        /**< size of tag too big */
#define EMP_ENOENDTAG                    -106        /**< no end of tag found */
#define EMP_ENOITEM                      -105        /**< no item found */
#define EMP_EBADBUFF                     -104        /**< the specified buffer is not correct */
#define EMP_EBADFILE                     -103        /**< the specified file is not correct */
#define EMP_EINTERNAL                    -102        /**< some internal error in the etel software */
#define EMP_EBADSTATE                    -101        /**< this operation is not allowed in this state */
#define EMP_EBADPARAM                    -100        /**< one of the parameter is not valid */



/*------------------------------------------------------------------------------
 * extended types
 *-----------------------------------------------------------------------------*/
/*--------------------------*/
/* byte type				*/
#ifndef __BYTE
	#define __BYTE
	typedef unsigned char byte;
#endif

/*--------------------------*/
/* word type				*/
#ifndef __WORD
	#define __WORD
	typedef unsigned short word;
#endif

/*--------------------------*/
/* dword type				*/
#ifndef __DWORD
	#define __DWORD
	typedef uint32_t dword;
#endif

/*--------------------------*/
/* char_p type				*/
#ifndef __CHAR_P
	#define __CHAR_P
	typedef char *char_p;
#endif

/*--------------------------*/
/* char_cp type				*/
#ifndef __CHAR_CP
	#define __CHAR_CP
	typedef const char *char_cp;
	#ifndef __cplusplus
		#ifndef __BOOL
			#define __BOOL
			typedef byte bool;
		#endif /*BOOL */
	#endif /*__cplusplus */
#endif /*CHAR_CP */

			/*--------------------------*/
/* 64 bits integer			*/
#ifndef __INT64
	#define __INT64
	#if __BYTE_ORDER == __LITTLE_ENDIAN
		typedef struct INT64_DWORD_MODE {
			dword low_dword;
			dword high_dword;
		} INT64_DWORD_MODE;
	#else /*__BYTE_ORDER*/
		typedef struct INT64_DWORD_MODE {
			dword high_dword;
			dword low_dword;
		} INT64_DWORD_MODE;
	#endif /*__BYTE_ORDER*/

	#if __BYTE_ORDER == __LITTLE_ENDIAN
		typedef struct INT64_BYTE_MODE {
			byte byte0;
			byte byte1;
			byte byte2;
			byte byte3;
			byte byte4;
			byte byte5;
			byte byte6;
			byte byte7;
		} INT64_BYTE_MODE;
	#else /*__BYTE_ORDER*/
		typedef struct INT64_BYTE_MODE {
			byte byte7;
			byte byte6;
			byte byte5;
			byte byte4;
			byte byte3;
			byte byte2;
			byte byte1;
			byte byte0;
		} INT64_BYTE_MODE;
	#endif /*__BYTE_ORDER*/

	/*------------------------------*/
	/* WINDOWS 64 bits integer		*/
	#if defined WIN32
		#define eint64 long long
	/*------------------------------*/
	/* POSIX and F_ITRON 64 bits integer		*/
	#elif defined POSIX || defined F_ITRON || defined VXWORKS_6_9
		#define eint64 long long
	#endif
#endif

typedef struct {
	int	  product_code;
	char  product_name[EMP_STRING_SIZE];
	dword fw_version;
} EMP_PRODUCTINFO;

typedef struct {
	int	  count;
} EMP_FWBLOCKTYPE;

typedef struct {
	int	  item_idx;
	int	  nb;
	char  name[EMP_STRING_SIZE];
} EMP_FWBLOCKTYPEITEM;

typedef struct {
	int	  count;
} EMP_FWSTRUCTURE;

typedef struct {
	int	  item_idx;
	int	  hw_revision;
	int	  block_count;
} EMP_FWSTRUCTUREITEM;

typedef struct {
	int	  item_idx;
	int	  nb;
	int	  type;
	int	  size;
	int	  axis;
} EMP_BLOCK;

typedef struct {
	int	  count;
} EMP_GROUPTYPE;

typedef struct {
	int	  item_idx;
	int	  group_idx;
	char  caption[EMP_STRING_SIZE];
} EMP_GROUPTYPEITEM;

typedef struct {
	int	  count;
} EMP_CONVERSIONTYPE;

typedef struct {
	int	  item_idx;
	char  conv_type[EMP_STRING_SIZE];
	int	  code;
	int	  uSecond;
	int	  uPosition;
	int	  uVolt;
	int	  uAmpere;
	int	  uPeriod;
	int	  uForce;
	int	  uTemp;
	char  comment[EMP_STRING_SIZE];
} EMP_CONVERSIONTYPEITEM;

typedef struct {
	int	  count;
} EMP_INCREMENTTYPE;

typedef struct {
	int	  item_idx;
	int	  increment_typ;
	char  description[EMP_STRING_SIZE];
} EMP_INCREMENTTYPEITEM;

typedef struct {
	int	  count;
} EMP_ENUM;

typedef struct {
	int	  item_idx;
	int	  _enum;
	char  caption[EMP_STRING_SIZE];
	int	  enum_value_item_count;
} EMP_ENUMITEM;

typedef struct {
	int	  item_idx;
	char  value[EMP_STRING_SIZE];
	char  caption[EMP_STRING_SIZE];
} EMP_ENUMVALUEITEM;

typedef struct {
	int	  count;
} EMP_COMMAND;

typedef struct {
	int	  item_idx;
	char  cmd_id[EMP_STRING_SIZE];
	int   cmd_nb;
	bool  doc_hidden;
	char  caption[EMP_STRING_SIZE];
	bool  waitflag;
	int   group_idx;
	int   parameters_count;
	int   record_count;
} EMP_COMMANDITEM;

typedef struct {
	int	item_idx;
	int	param;
	bool  returned_parameter;
	char  min_value[EMP_STRING_SIZE];
	char  max_value[EMP_STRING_SIZE];
	char  default_value[EMP_STRING_SIZE];
	int   _enum;
	int	conv_type;
	int	increment_type;
	bool  jump_target;
	char  varname[EMP_STRING_SIZE];
	char  comment[EMP_STRING_SIZE];
} EMP_COMMANDPARAMETER;

typedef struct {
	int	item_idx;
	int	record_nb;
} EMP_COMMANDRECORD;

typedef struct {
	int count;
} EMP_REGISTERTYPES;

typedef struct {
	int item_idx;
	char type_name[EMP_STRING_SIZE];
	char caption[EMP_STRING_SIZE];
	int type_number;
	int nb_of_idx;
	int nb_of_sidx;
	bool is_list;
	bool restored;
	bool writable;
	int register_count;
} EMP_REGISTERTYPESITEM;

typedef struct {
	int item_idx;
	int index;
	char alias[EMP_STRING_SIZE];
	char caption[EMP_STRING_SIZE];
	bool doc_hidden;
	int group_idx;
	int sidx_num;
	char  min_value[EMP_STRING_SIZE];
	char  max_value[EMP_STRING_SIZE];
	char  default_value[EMP_STRING_SIZE];
	int _enum;
	int restore_from;
	int restore_num;
	bool system;
	int conv_type;
} EMP_REGISTERLISTITEM;

#ifndef EMP_PARSER
#define EMP_PARSER void
#endif


extern int _EMP_EXPORT emp_create_parser_from_buffer (EMP_PARSER **parser, int product, dword version, const char *buffer, const long buffer_size, dword meta_version, dword flags);
extern int _EMP_EXPORT emp_create_parser_from_file (EMP_PARSER **parser, int product, dword version, const char *meta_file_name, dword meta_version, dword flags);
extern int _EMP_EXPORT emp_destroy_parser (EMP_PARSER **parser);
extern bool _EMP_EXPORT emp_is_valid_parser(EMP_PARSER *parser);

extern int _EMP_EXPORT emp_get_ProductInfo (EMP_PARSER *parser, EMP_PRODUCTINFO *product_info);
extern int _EMP_EXPORT emp_get_FWBlockType (EMP_PARSER *parser, EMP_FWBLOCKTYPE *fw_block_type);
extern int _EMP_EXPORT emp_get_FWBlockTypeItem (EMP_PARSER *parser, int block_type_item_idx, EMP_FWBLOCKTYPEITEM *fw_block_type_item);
extern int _EMP_EXPORT emp_get_FWStructure (EMP_PARSER *parser, EMP_FWSTRUCTURE *fw_structure);
extern int _EMP_EXPORT emp_get_FWStructureItem (EMP_PARSER *parser, int hw_revision_item_idx, EMP_FWSTRUCTUREITEM *fw_structure_item);
extern int _EMP_EXPORT emp_get_Block (EMP_PARSER *parser, int hw_revision_item_idx, int block_item_idx, EMP_BLOCK *block);
extern int _EMP_EXPORT emp_get_GroupType (EMP_PARSER *parser, EMP_GROUPTYPE *group_type);
extern int _EMP_EXPORT emp_get_GroupTypeItem (EMP_PARSER *parser, int group_typ_idx, EMP_GROUPTYPEITEM *group_type_item);
extern int _EMP_EXPORT emp_get_ConversionType (EMP_PARSER *parser, EMP_CONVERSIONTYPE *conversion_type);
extern int _EMP_EXPORT emp_get_ConversionTypeItem (EMP_PARSER *parser, int conversion_type_idx, EMP_CONVERSIONTYPEITEM *conversion_type_item);
extern int _EMP_EXPORT emp_get_IncrementType (EMP_PARSER *parser, EMP_INCREMENTTYPE *increment_type);
extern int _EMP_EXPORT emp_get_Increment (EMP_PARSER *parser, int increment_type_idx, EMP_INCREMENTTYPEITEM *increment_type_item);
extern int _EMP_EXPORT emp_get_Enum(EMP_PARSER *parser, EMP_ENUM *enums);
extern int _EMP_EXPORT emp_get_EnumItem(EMP_PARSER *parser, int enums_idx, EMP_ENUMITEM *enums_item);
extern int _EMP_EXPORT emp_get_EnumValueItem(EMP_PARSER *parser, int enum_idx, int enum_value_idx, EMP_ENUMVALUEITEM *enum_value_item);
extern int _EMP_EXPORT emp_get_Command(EMP_PARSER *parser, EMP_COMMAND *command);
extern int _EMP_EXPORT emp_get_CommandItem(EMP_PARSER *parser, int command_idx, EMP_COMMANDITEM *command_item);
extern int _EMP_EXPORT emp_get_CommandParameter(EMP_PARSER *parser, int command_idx, int parameter_idx, EMP_COMMANDPARAMETER *command_parameter);
extern int _EMP_EXPORT emp_get_CommandRecord(EMP_PARSER *parser, int command_idx, int record_idx, EMP_COMMANDRECORD *command_record);
extern int _EMP_EXPORT emp_get_RegisterTypes(EMP_PARSER *parser, EMP_REGISTERTYPES *register_types);
extern int _EMP_EXPORT emp_get_RegisterTypesItem(EMP_PARSER *parser, int register_types_item_idx, EMP_REGISTERTYPESITEM *register_types_item);
extern int _EMP_EXPORT emp_get_RegisterListItem(EMP_PARSER *parser, int register_types_item_idx, int register_list_item_idx, EMP_REGISTERLISTITEM *register_list_item);

//Advanced functions
extern int _EMP_EXPORT emp_get_nb_strings(EMP_PARSER *parser, int *nb_string);
extern int _EMP_EXPORT emp_get_first_string(EMP_PARSER *parser, int size, char *str);
extern int _EMP_EXPORT emp_get_next_string(EMP_PARSER *parser, int size, char *str);

extern char_cp _EMP_EXPORT emp_translate_error(int code);


#endif //_EMP40_H
