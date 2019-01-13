/*
 * motmsg.h
 *
 * 32-bit Motion Control Device Driver
 *
 * User-Mode Motion and MCI device-specific commands for the motion control
 *
 */

#ifndef _MOTMSG_H
  #define _MOTMSG_H

/****************************************************************************
                            Pmac Messages
****************************************************************************/
  #define WM_PMACNOTIFY     (WM_USER+100)

/****************************************************************************
                            Motion Messages
****************************************************************************/
  #define MOT_FIRST               DRV_USER
  #define MOT_OPEN                (MOT_FIRST + 1)
  #define MOT_CLOSE               (MOT_FIRST + 2)
  #define MOT_INTR_INIT           (MOT_FIRST + 3)
  #define MOT_INTR_TERM           (MOT_FIRST + 4)
  #define MOT_SENDLINE            (MOT_FIRST + 5)
  #define MOT_RESPPENDING         (MOT_FIRST + 6)
  #define MOT_GETLINE             (MOT_FIRST + 7)
  #define MOT_GET_ROM_VER         (MOT_FIRST + 8)
  #define MOT_GET_ROM_DATE        (MOT_FIRST + 9)

  #define MOT_LAST                (MOT_FIRST + 100)

/****************************************************************************
                        Motion Error Return Values
****************************************************************************/

  #define MOT_ERR_OK               (0)                /* No error */
  #define MOT_ERR_BASE             (1)                /* Error Base */
  #define MOT_ERR_NONSPECIFIC      (MOT_ERR_BASE)
  #define MOT_ERR_BADFORMAT        (MOT_ERR_BASE + 1)
  #define MOT_ERR_STILLPLAYING     (MOT_ERR_BASE + 2)
  #define MOT_ERR_UNPREPARED       (MOT_ERR_BASE + 3)
  #define MOT_ERR_NOTDETECTED      (MOT_ERR_BASE + 4) /* HW not detected */
  #define MOT_ERR_BADINSTALL       (MOT_ERR_BASE + 5) /* Can not get Profile */
  #define MOT_ERR_SIZEFIELD        (MOT_ERR_BASE + 6)
  #define MOT_ERR_PARAM1           (MOT_ERR_BASE + 7)
  #define MOT_ERR_PARAM2           (MOT_ERR_BASE + 8)
  #define MOT_ERR_CONFIG1          (MOT_ERR_BASE + 9)
  #define MOT_ERR_CONFIG2          (MOT_ERR_BASE + 10)
  #define MOT_ERR_FLAGS            (MOT_ERR_BASE + 11)

  #define MOT_ERR_NOTSUPPORTED     (MOT_ERR_BASE + 12) /* function not suported */
  #define MOT_ERR_NOMEM            (MOT_ERR_BASE + 13) /* out of memory */
  #define MOT_ERR_ALLOCATED        (MOT_ERR_BASE + 14) /* device is allocated */
  #define MOT_ERR_BADDEVICEID      (MOT_ERR_BASE + 15)
  #define MOT_ERR_INVALHANDLE      (MOT_ERR_BASE + 16)
  #define MOT_ERR_BADERRNUM        (MOT_ERR_BASE + 17)
  #define MOT_ERR_NO_BUFFERS       (MOT_ERR_BASE + 18) /* out of buffers */

  #define MOT_ERR_MEM_CONFLICT     (MOT_ERR_BASE + 19)  /* Mem conflict detected */
  #define MOT_ERR_IO_CONFLICT      (MOT_ERR_BASE + 20)  /* I/O conflict detected */
  #define MOT_ERR_DMA_CONFLICT     (MOT_ERR_BASE + 21)  /* DMA conflict detected */
  #define MOT_ERR_INT_CONFLICT     (MOT_ERR_BASE + 22)  /* Interrupt conflict detected */
  #define MOT_ERR_LASTERROR        (MOT_ERR_BASE + 23)
  #define MOT_ERR_USER_MSG         (MOT_ERR_BASE + 100) /* Hardware specific errors */


/******************************************************************************
 *                        MCI Motion Message Messages
 ******************************************************************************/

  #define MCI_MOT_FIRST          (MCI_USER_MESSAGES + 1)
  #define MCI_MOT_JOG            (MCI_MOT_FIRST)
  #define MCI_MOT_HOME           (MCI_MOT_FIRST + 1)
  #define MCI_MOT_DISABLE        (MCI_MOT_FIRST + 2)
  #define MCI_MOT_INTR_INIT      (MCI_MOT_FIRST + 3)
  #define MCI_MOT_INTR_TERM      (MCI_MOT_FIRST + 4)
  #define MCI_MOT_LAST           (MCI_MOT_FIRST + 50)

/* psuedo Interrupt message implementation (ongoing) */

  #define MCI_MOT_IN_POSITION        0x4001
  #define MCI_MOT_BUFFER_REQUEST     0x4002
  #define MCI_MOT_FATAL_FOLLOW_ERROR 0x4004
  #define MCI_MOT_FOLLOW_ERROR       0x4008
  #define MCI_MOT_HOST_REQUEST       0x4010
  #define MCI_MOT_IR5                0x4020
  #define MCI_MOT_IR6                0x4040
  #define MCI_MOT_IR7                0x4080

/************************************************************
 * MOT Device-Specific Extended MCI Message Flags
 ************************************************************/

  #define MCI_MOT_MOTOR        0x00010000L
  #define MCI_MOT_SPEED        0x00020000L
  #define MCI_MOT_STOP         0x00040000L
  #define MCI_MOT_POS          0x00080000L
  #define MCI_MOT_NEG          0x00100000L
  #define MCI_MOT_MASK         0x00200000L
  #define MCI_MOT_HAND         0x00400000L

/************************************************************
 * MOT Device-Specific Extended MCI Message Data Structures
 ************************************************************/

typedef struct {
  DWORD dwCallback;
  DWORD dwUser;
  DWORD dwWHandle;
  DWORD intrMask;
} MOT_INTR_INIT_PARMS, *PMOT_INTR_INIT_PARMS;

typedef struct {
  DWORD dwCallback;
  DWORD dwUser;
  DWORD intrMask;
} MOT_INTR_TERM_PARMS, *PMOT_INTR_TERM_PARMS;

typedef struct {
  DWORD dwCallback;
  DWORD dwUser;
  DWORD axisInt;
  DWORD speedStr;
  DWORD szSpeedStr;
} MOT_SERVO_JOG_PARMS, *PMOT_SERVO_JOG_PARMS;

// Functions --------------------------------------------------------------
  #ifdef __cplusplus
extern "C" {
  #endif

  /* functions in motmsg.c */
  LRESULT CALLBACK PmacMotionMessage(DWORD, UINT, LPARAM, LPARAM);

  #ifdef __cplusplus
}
  #endif

#endif

