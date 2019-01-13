/***************************************************************************
  Title:    motor.h

  Version:  1.00

  Date:   8/29/1995

  Author(s):  Harry Rivera

  Misc. Routines for PMAC-II Setup Program

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------

***************************************************************************/


#define DC_BRUSH          1
#define DC_BRUSHLESS        2
#define AC_INDUCTION        3
#define STEPPER         4
#define VARIABLE_RELUCTANCE 5

#define NOT_SELECTED        123


// "personality" structures for the motors

struct GLOBAL_MOTOR_SPECS {

  float PWM_frequencyA;
  float PWM_frequencyB;
  float I900; // Max phase & PWM for 1-4
  float I904; // PWM Deadtime for 1-4
  float I906; // Max phase & PWM for 5-8
  float I908; // PWM Deadtime for 5-8
};


struct MOTOR_SPECS {

  char  motor_type;
  char  is_dirty;
  float I9n6; // Output n mode select
  float I9n7; // Output n invert control
};


