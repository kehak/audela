#ifndef _VANTAGEPRO_H_
#define _VANTAGEPRO_H_

//#include <windows.h>

#pragma warning (disable : 4996)

/**********************************************************************/
#define DllAccess extern "C"  __declspec( dllexport )

#define INCHES                   0
#define MM                       1
#define MB                       2
#define HECTO_PASCAL             3

#define FAHRENHEIT               0
#define CELSIUS                  1

#define MPH                      0
#define KNOTS                    1
#define KPH                      2
#define METERS_PER_SECOND        3

#define KM                       1
#define MILES                    0

#define FEET                     1
#define METERS                   0

#define START_OF_VP_DLL_ERRORS  -32700
#define COM_ERROR               -32701 
#define MEMORY_ERROR            -32702 
#define COM_OPEN_ERROR          -32703
#define NOT_LOADED_ERROR        -32704
#define BAD_DATA_ID             -32705
#define BUFFER_TOO_SMALL_ERROR  -32706
#define PARAMETER_ERROR         -32707

#define BAD_DATA             (-32768)   // smallest 16 bit signed number
#define BAD_DATA_POS         ( 32767)   // largest 16 bit signed number
#define BAD_DATA_NEG         (-32768)   // smallest 16 bit signed number

// Rain Collecter types .
#define  ENGLISH_10           (0) // 10'th inch
#define  ENGLISH_100          (1) // 100'th inch
#define  METRIC_5             (2) // 5'th mm
#define  METRIC_1             (3) // 1 mm
#define  ENGLISH_OTHER        (4) // other inch
#define  METRIC_OTHER         (5) // other mm
#define  METRIC_01            (6) // 0.1 mm Vantage Only

// Constants used by Get/SetVantageTxConfig_V
#define NO_TX                 (0)   // No transmiter on this ID  
#define ISS_TX                (1)   // An ISS station configured as an ISS. Only one allowed per VantagePro.  
#define TEMP_ONLY_TX          (2)   // Temperature only station  
#define TEMP_HUM_TX           (3)   // Temperature/humidity station  
#define ISS_AS_TEMP_ONLY_TX   (4)   // An ISS station configured as a Temp only station.  
#define ISS_AS_TEMP_HUM_TX    (5)   // An ISS station configured as a Temp/Hum station.  
#define TEMP_HUM_AS_ISS_TX    (6)   // A Temp/Hum (or Temp Only) station configured as an ISS.  
#define WIND_TX               (7)   // Wireless Annemometer station  
#define LEAF_TX               (8)   // Leaf Wetness/Temperature station  
#define SOIL_TX               (9)   // Soil Moisture/Temperature station  
#define LEAF_SOIL_TX          (10)  // Combined Leaf and Soil station  
#define SENSORLINK_TX         (11)  // SensorLink transmitter  
#define RETRANSMIT_TX         (12)  // VantagePro will retransmit ISS data on this ID  

// Wind Cup Size constants
#define LARGE_WIND_CUPS       (1)
#define SMALL_WIND_CUPS       (2)
#define OTHER_WIND_CUPS       (3)

// Temperature Averaging settings
#define TEMPERATURE_SAMPLED   (1)
#define TEMPERATURE_AVERAGED  (2)


// These are the indexes of the "system Timeouts" used in SetSystemTimeOuts()
#define  TO_STANDARD       (0)
#define  TO_DUMP_AFTER     (1)
#define  TO_MODEM          (2)
#define  TO_LOOPBACK       (3)
#define  TO_LOOP           (4)
#define  TO_FLUSH          (5)
#define  TO_DONE           (6)
#define  TO_STANDARD_MODEM (7)
#define  TO_STANDARD_MONITOR  (8)
#define  TO_STANDARD_MONITOR_MODEM  (9)
#define  TO_AUTO_DETECT		(10)

/**********************************************************************/
// List of pre-defined Time Zones

#define TZ_ENIWETOK         (0)  // -12:00 Eniwetok, Kwajalein 
#define TZ_MIDWAY           (1)  // -11:00 Midway Island, Samoa 
#define TZ_HAWAII           (2)  // -10:00 Hawaii 
#define TZ_ALASKA           (3)  // -09:00 Alaska 
#define TZ_PACIFIC          (4)  // -08:00 Pacific Time, Tijuana 
#define TZ_MOUNTAIN         (5)  // -07:00 Mountain Time 
#define TZ_CENTRAL          (6)  // -06:00 Central Time 
#define TZ_MEXICO_CITY      (7)  // -06:00 Mexico City 
#define TZ_CENTRAL_AMERICA  (8)  // -06:00 Central America 
#define TZ_BOGOTA           (9)  // -05:00 Bogota, Lima, Quito 
#define TZ_EASTERN         (10)  // -05:00 Eastern Time 
#define TZ_ATLANTIC        (11)  // -04:00 Atlantic Time 
#define TZ_CARACAS         (12)  // -04:00 Caracas, La Paz, Santiago 
#define TZ_NEWFOUNDLAND    (13)  // -03:30 Newfoundland 
#define TZ_BRASILIA        (14)  // -03:00 Brasilia 
#define TZ_BUENOS_AIRES    (15)  // -03:00 Buenos Aires, Georgetown, Greenland 
#define TZ_MID_ATLANTIC    (16)  // -02:00 Mid-Atlantic 
#define TZ_AZORES          (17)  // -01:00 Azores, Cape Verde Is. 
#define TZ_GMT             (18)  //  00:00 Greenwich Mean Time, Dublin, Edinburgh, Lisbon, London 
#define TZ_MONROVIA        (19)  //  00:00 Monrovia, Casablanca 
#define TZ_BERLIN          (20)  // +01:00 Berlin, Rome, Amsterdam, Bern, Stockholm, Vienna 
#define TZ_PARIS           (21)  // +01:00 Paris, Madrid, Brussels, Copenhagen, W Central Africa 
#define TZ_PRAGUE          (22)  // +01:00 Prague, Belgrade, Bratislava, Budapest, Ljubljana 
#define TZ_ATHENS          (23)  // +02:00 Athens, Helsinki, Istanbul, Minsk, Riga, Tallinn 
#define TZ_CAIRO           (24)  // +02:00 Cairo 
#define TZ_EAST_EUROPE     (25)  // +02:00 Eastern Europe, Bucharest 
#define TZ_PRETORIA        (26)  // +02:00 Harare, Pretoria 
#define TZ_ISRAEL          (27)  // +02:00 Israel, Jerusalem 
#define TZ_BAGHDAD         (28)  // +03:00 Baghdad, Kuwait, Nairobi, Riyadh 
#define TZ_MOSCOW          (29)  // +03:00 Moscow, St. Petersburg, Volgograd 
#define TZ_TEHRAN          (30)  // +03:30 Tehran 
#define TZ_ABU_DHABI       (31)  // +04:00 Abu Dhabi, Muscat, Baku, Tblisi, Yerevan, Kazan 
#define TZ_KABUL           (32)  // +04:30 Kabul 
#define TZ_ISLAMABAD       (33)  // +05:00 Islamabad, Karachi, Ekaterinburg, Tashkent 
#define TZ_BOMBAY          (34)  // +05:30 Bombay, Calcutta, Madras, New Delhi, Chennai 
#define TZ_COLOMBO         (35)  // +06:00 Almaty, Dhaka, Colombo, Novosibirsk, Astana 
#define TZ_BANGKOK         (36)  // +07:00 Bangkok, Jakarta, Hanoi, Krasnoyarsk 
#define TZ_BEIJING         (37)  // +08:00 Beijing, Chongqing, Urumqi, Irkutsk, Ulaan Bataar 
#define TZ_HONG_KONG       (38)  // +08:00 Hong Kong, Perth, Singapore, Taipei, Kuala Lumpur 
#define TZ_TOKYO           (39)  // +09:00 Tokyo, Osaka, Sapporo, Seoul, Yakutsk 
#define TZ_ADELAIDE        (40)  // +09:30 Adelaide 
#define TZ_DARWIN          (41)  // +09:30 Darwin 
#define TZ_BRISBANE        (42)  // +10:00 Brisbane, Melbourne, Sydney, Canberra 
#define TZ_GUAM            (43)  // +10:00 Hobart, Guam, Port Moresby, Vladivostok 
#define TZ_SOLOMON_ISLANDS (44)  // +11:00 Magadan, Solomon Is, New Caledonia 
#define TZ_FIJI            (45)  // +12:00 Fiji, Kamchatka, Marshall Is. 
#define TZ_WELLINGTON      (46)  // +12:00 Wellington, Auckland 

#define TZ_FIRST_TIME_ZONE (TZ_ENIWETOK)
//#define TZ_LAST_TIME_ZONE  (TZ_WELLINGTON)

struct DateTime
{   
	short int month;
	short int day;
	short int hour;
	short int min;
}; 

struct DateTimeStamp
{
	int minute;
	int hour;
	int day;
	int month;
	int year;
};


struct WeatherUnits
{   
 char TempUnit;
 char RainUnit;
 char BaromUnit;
 char WindUnit;
 char elevUnit;
}; 

struct WeatherRecordStruct
{
   short year;
   char  month;
   char  day;
   short packedTime;

   char  dateStr[16];
   char  timeStr[16];
   float heatIndex;
   float windChill;
   float hiOutsideTemp;
   float lowOutsideTemp;
   float dewPoint;
   float windSpeed;
   short windDirection;
   char  windDirectionStr[5];
   float hiWindSpeed;
   float rain;
   float barometer;
   float insideTemp;
   float outsideTemp;
   float insideHum;
   float outsideHum;

   short archivePeriod;

   short solarRad;
   float uv;
   float et;
   short hiWindDirection;
   char  hiWindDirectionStr[5];
};


struct CurrentVantageCalibration
{
    //console readings
	float tempIn;
	float tempOut;
	BYTE humIn;
	BYTE humOut;

    //calibration offsets
	float tempInOffset;
	float tempOutOffset;
	char humInOffset;
	char humOutOffset;
};

/**********************************************************************/
// New Structures for version 2.3

/*****
   WeatherRecordStructEx
   Holds a data record from the VantagePro archive memory. The data is stored 
   in the units currently selected in the DLL. This structure contains more 
   data fields than the WeatherRecordStruct used by previous versions of the 
   DLL and is filled in by GetArchiveRecordEx_V. 
 *****/
struct  WeatherRecordStructEx
{
    short year;
    char month;
    char day;
    short packedTime;
    char dateStr[16];
    char timeStr[16];
    short archivePeriod;

    float outsideTemp;
    float hiOutsideTemp;
    float lowOutsideTemp;
    float insideTemp;

    float barometer;
    short barometerTrend;

    float outsideHum;
    float insideHum;

    float rain;
    float hiRainRate;

    float windSpeed;
    float hiWindSpeed;
    short windDirection;
    char windDirectionStr[5];
    short hiWindDirection;
    char hiWindDirectionStr[5];

    short numWindSamples;
    short numExpectedSamples;

    short solarRad;
    short hiSolarRad;
    float UV;
    float hiUV;

    float et;

    float extraTemp[3];
    float extraHum[2];
    float soilTemp[4];
    float leafTemp[2];

    float soilMoisture[4];
    float leafWetness[2];

    float heatIndex;
    float THWIndex;
    float THSWIndex;
    float windChill;
    float dewPoint;

    float insideHeatIndex;
    float insideDewPoint;
};

/*****
   ReceptionStats
   Holds the reception statistics for the ISS or wireless anemometer station on 
   the VantagePro console since midnight or since they were cleared manualy on 
   the console. The data is filled in by GetReceptionData_V. 
 *****/
struct  ReceptionStats
{
    long totalPacketsReceived;
    long totalPacketsMissed;
    long numberOfResynchs;
    long maxInARow;
    long numCRCerrors;
};

/*****
   LatLonValue
   Holds a latitude or longitude value. They can be expressed either as a floating 
   point number that holds degrees and fractions or as integer degrees, minutes, 
   and seconds. Both set of data fields are filled in when reading a value from 
   the VantagePro. The "bUseFranctionalDegrees" field is used to select which set 
   of data the DLL should use when writing the data to the weather station (0 = use 
   the integer degrees/minutes/seconds fields; 1 = use the fractionalDegrees field). 

   Positive degree values are used for North latitude and East longitude. Negitive 
   degrees are used for South latitude and West longitude. When using the integer 
   degrees/minutes/seconds fields, only the degrees value is negative. The minutes 
   and seconds fields are always positive numbers between 0 and 60. 

   The data is filled in by GetVantageLat_V and GetVantageLon_V. The data structure 
   is used to write new values to the VantagePro by SetVantageLat_V and SetVantageLon_V.
 *****/
struct  LatLonValue
{
    short bUseFractionalDegrees;
    float fractionalDegrees;
    short bNegativeDegrees;
    short degrees;
    short minutes;
    short seconds;
};

/*****
   TxConfiguration
   Holds the transmiter configuration data read from the VantagePro console, or to 
   be written to it. The data fields are filled in by GetVantageTxConfig_V and 
   written to the weather station by SetVantageTxConfig_V. 

   For each of the 8 transmitter ID's the corresponding txType entry indicates the 
   selected Weather Transmitter Type, and the repeater entry indicates the selected 
   VantagePro 2 repeater. For the repeater entry, use 0 for no repeater (or for 
   VantagePro 1 systems), or a value from 1 to 8 to select repeater A through H. 

   Note: The txType values used by the DLL do not match the ones specified in the 
   Vantage Programmers reference. The DLL will determine the weather station 
   firmware version and write the correct values to the station. 
 *****/
struct  TxConfiguration
{
    short txType[8];
    short repeater[8];
};

/*****
 BarCalData
   Holds information about the current sea-level correction for the barometer 
   sensor on the VantagePro console. The data values are filled in by 
   GetBarometerData_V. 

   Barometer, temperature, and elevation values are given in the current DLL units. 
   The correntBarometer value is the most recently measured barometer reading (normaly 
   updated every 15 minutes) corrected to sea-level. To determine the raw reading, 
   subtract the barCalibrationOffset from it and divide the result by the 
   barCalibrationRatio. 

 *****/
struct  BarCalData
{
    float currentBarometer;
    float elevation;
    float dewPoint;
    float virtualTemp;
    short int humCfactor;
    float barCalibrationRatio;
    float barCalibrationOffset;
};

/*****
 TimeZoneSetting
   Holds information about the time zone and daylight savings mode settings on the console

   Holds information about the Time Zone and Daylight Savings settings on the VantagePro console. 
     This structure is used by the functions GetTimeZoneSettings_V and SetTimeZoneSettings_V. 

   The time zone can either be specified from a list (with bUseTimeZoneList = 1 and timeZone = a 
     constant from the Time Zone List) or by a GMT/UTC offset (with bUseTimeZoneList = 0 and 
     GMToffset = number of hours that clocks should be set ahead or behind GMT/UTC). The GMTofset 
     value is rounded to the nearest 15 minute (0.25 hour) time. The time zone set should be based 
     on the "Standard" time zone. Adjustments for daylight savings are taken into consideration by 
     the two daylight savings settings. 

   Set bAutoDaylightSavings = 1 to have the console automatically switch Daylight Savings on or off. 
     The exact dates that this occurs vary depending on the latitude/longitude settings. See the 
     WeatherLink on-line help file for more details.

   Set bAutoDaylightSavings = 0 to control daylight savings mode manually. (i.e. your location does 
     not observe daylight savings time, or does not use the same starting and ending dates that the 
     VantagePro console uses.) 

   bDaylightSavingsOnNow will indicate whether daylight savings time is currently in effect.
   If automatic daylight savings mode is selected, GetTimeZoneSettings_V will return the current status, 
     and the value is ignored by SetTimeZoneSettings_V.
   If manual daylight savings mode is selected, the value is used by both GetTimeZoneSettings_V and 
     SetTimeZoneSettings_V. 

   Note: Current versions of the VantagePro firmware (as of October 2005) do not account for the recent 
     changes in the daylight savings starting and ending dates in the US that are scheduled to take effect 
     fall 2007. This change should not effect European and Australian weather stations. 
 *****/
struct TimeZoneSetting
{
   short bUseTimeZoneList;
   short timeZone;
   float GMToffset;
   short bAutoDaylightSavings;
   short bDaylightSavingsOnNow;
};


/*--------------------------------------------------------------------------
Current Active Alarm Fields

Retrieves the current bit field alarm status. 
---------------------------------------------------------------------------*/

struct ActiveAlarmFields
{
	BYTE insideAlarms, rainAlarms;
	unsigned short outsideAlarms; 
	BYTE tempHumAlarms[8],leafSoilAlarms[4];
};


/**********************************************************************/

//Initialization Functions
DllAccess float     _stdcall GetDllVersion_V(void);
DllAccess short int _stdcall OpenCommPort_V (short int comPort, int baudRate);
DllAccess short int _stdcall OpenDefaultCommPort_V (void);
DllAccess short int _stdcall OpenUSBPort_V (unsigned int usbDeviceSerialNumber);
DllAccess unsigned int _stdcall GetUSBDevSerialNumber_V();
DllAccess short int _stdcall OpenTCPIPPort_V (const char *tcpPort, const char *IPAddr);
DllAccess short int _stdcall CloseCommPort_V (void);
DllAccess short int _stdcall CloseUSBPort_V (void);
DllAccess short int _stdcall CloseTCPIPPort_V (void);
DllAccess short int _stdcall SetCommTimeoutVal_V(short int ReadTimeout, short int WriteTimeout);
DllAccess short int _stdcall SetVantageTimeoutVal_V(short int timeOutType);
DllAccess void      _stdcall GetUnits_V(WeatherUnits* Units);
DllAccess short int _stdcall SetUnits_V (WeatherUnits* Units);
DllAccess char      _stdcall GetRainCollectorModel_V(void);
DllAccess short int _stdcall SetRainCollectorModel_V (char rainCModel);


//Lowlevel Functions
DllAccess short int _stdcall GetSerialChar_V (void);
DllAccess short int _stdcall PutSerialStr_V (char *stringtoport);
DllAccess short int _stdcall PutSerialChar_V (unsigned char c);

//Station Configuration Functions
DllAccess short int _stdcall InitStation_V(void);
DllAccess short int _stdcall GetModelNo_V(void);
DllAccess short int _stdcall GetStationTime_V (DateTimeStamp *);
DllAccess short int _stdcall SetStationTime_V (DateTimeStamp *);
DllAccess short int _stdcall GetArchivePeriod_V (void);
DllAccess short int _stdcall SetArchivePeriod_V (int intervalCode);
DllAccess short int _stdcall PutTotalRain_V (short TotalRain);

DllAccess short int _stdcall GetStationFirmwareDate_V ( DateTimeStamp *timeStamp);
DllAccess short int _stdcall GetStationFirmwareVersion_V ( char *verSt);DllAccess short int _stdcall GetReceptionData_V ( ReceptionStats *receptionStats);
DllAccess short int _stdcall GetVantageLat_V ( LatLonValue *latitude);
DllAccess short int _stdcall SetVantageLat_V ( LatLonValue *latitude);
DllAccess short int _stdcall GetVantageLon_V ( LatLonValue *longitude);
DllAccess short int _stdcall SetVantageLon_V ( LatLonValue *longitude);
DllAccess short int _stdcall SetVantageLamp_V (short int lampState);
DllAccess short int _stdcall SetNewBaud_V (short int baud);
DllAccess short int _stdcall GetVantageTxConfig_V ( TxConfiguration *txConfig);
DllAccess short int _stdcall SetVantageTxConfig_V ( TxConfiguration *txConfig);
DllAccess short int _stdcall GetBarometerData_V ( BarCalData *barCalData);
DllAccess short int _stdcall SetRainCollectorModelOnStation_V (short int rainCModel);
DllAccess short int _stdcall GetRainCollectorModelOnStation_V ();
DllAccess short int _stdcall GetAndSetRainCollectorModelOnStation_V ();

// Current Data Functions
DllAccess short int _stdcall LoadCurrentVantageData_V (void);
DllAccess float     _stdcall GetBarometer_V (void);
DllAccess float     _stdcall GetOutsideTemp_V (void);
DllAccess float     _stdcall GetDewPt_V (void);
DllAccess float     _stdcall GetWindChill_V (void);
DllAccess float     _stdcall GetInsideTemp_V (void);
DllAccess short int _stdcall GetInsideHumidity_V (void);
DllAccess short int _stdcall GetOutsideHumidity_V (void);
DllAccess float     _stdcall GetTotalRain_V (void);
DllAccess float     _stdcall GetDailyRain_V (void);
DllAccess float     _stdcall GetMonthlyRain_V (void);
DllAccess float     _stdcall GetStormRain_V (void);
DllAccess float     _stdcall GetWindSpeed_V(void);
DllAccess short     _stdcall GetWindDir_V (void);
DllAccess char*     _stdcall GetWindDirStr_V(char* dirStr);
DllAccess float     _stdcall GetRainRate_V (void);
DllAccess float     _stdcall GetET_V(void);
DllAccess float     _stdcall GetMonthlyET_V (void);
DllAccess float     _stdcall GetYearlyET_V (void);
DllAccess short     _stdcall GetSolarRad_V(void);
DllAccess float     _stdcall GetUV_V(void);
DllAccess float     _stdcall GetHeatIndex_V(void);

DllAccess short int _stdcall GetActiveAlarms_V( ActiveAlarmFields &alarmFieldStruct );
DllAccess float     _stdcall GetCurrentDataByID_V (DWORD id);
DllAccess short int _stdcall GetCurrentDataStrByID_V  (DWORD id, char *s, short int bufferLength);
DllAccess short int _stdcall GetStartOfCurrentStorm_V (DateTimeStamp *dt);
DllAccess short int _stdcall GetSunriseTime_V (DateTimeStamp *dt);
DllAccess short int _stdcall GetSunsetTime_V (DateTimeStamp *dt);

//Alarm Functions
DllAccess int       _stdcall LoadVantageAlarms_V(void);
DllAccess short int _stdcall SetVantageAlarms_V (void);

// Get alarm values
DllAccess float     _stdcall GetBarRiseAlarm_V (void);
DllAccess float     _stdcall GetBarFallAlarm_V (void);
DllAccess int       _stdcall GetTimeAlarm_V (void);
DllAccess char*     _stdcall GetTimeAlarmStr_V (void);
DllAccess float     _stdcall GetInsideLowTempAlarm_V (void);
DllAccess float     _stdcall GetInsideHiTempAlarm_V (void);
DllAccess float     _stdcall GetOutsideLowTempAlarm_V (void);
DllAccess float     _stdcall GetOutsideHiTempAlarm_V (void);
DllAccess short int _stdcall GetLowInsideHumAlarm_V (void);
DllAccess short int _stdcall GetHiInsideHumAlarm_V (void);
DllAccess float     _stdcall GetLowOutsideHumAlarm_V (void);
DllAccess float     _stdcall GetHiOutsideHumAlarm_V (void);
DllAccess float     _stdcall GetLowWindChillAlarm_V (void);
DllAccess float     _stdcall GetLowDewPtAlarm_V(void) ;
DllAccess float     _stdcall GetHiDewPtAlarm_V(void) ;
DllAccess short int _stdcall GetHiSolarRadAlarm_V (void);
DllAccess short int _stdcall GetHiWindSpeedAlarm_V (void);
DllAccess short int _stdcall GetHi10MinWindSpeedAlarm_V (void);
DllAccess short int _stdcall GetHiHeatIndexAlarm_V (void);
DllAccess short int _stdcall GetHiTHSWAlarm_V (void);
DllAccess float     _stdcall GetHiRainRateAlarm_V (void);
DllAccess float     _stdcall GetHiDailyRainAlarm_V (void);
DllAccess float     _stdcall GetHiRainStormAlarm_V (void);
DllAccess float     _stdcall GetFlashFloodAlarm_V (void);
DllAccess float     _stdcall GetHiUVAlarm_V (void);
DllAccess float     _stdcall GetHiUVMedAlarm_V (void);

//DllAccess float     _stdcall GetHiDailyETAlarm ();

DllAccess  float    _stdcall GetLowExtraTempAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetHiExtraTempAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetLowExtraHumAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetHiExtraHumAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetLowSoilTempAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetHiSoilTempAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetLowSoilMoistureAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetHiSoilMoistureAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetLowLeafTempAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetHiLeafTempAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetLowLeafWetAlarm_V(short sensorNumber);
DllAccess  float    _stdcall GetHiLeafWetAlarm_V(short sensorNumber);


// Put Alarm thresholds
DllAccess short int _stdcall PutBarRiseAlarm_V (float barRiseAlarm);
DllAccess short int _stdcall PutBarFallAlarm_V (float barFallAlarm);
DllAccess short int _stdcall PutTimeAlarm_V (char* timeAlarm);
DllAccess short int _stdcall PutInsideLowTempAlarm_V (float lowtempAlarm);
DllAccess short int _stdcall PutInsideHiTempAlarm_V (float hitempAlarm);
DllAccess short int _stdcall PutOutsideLowTempAlarm_V (float lowtempAlarm);
DllAccess short int _stdcall PutOutsideHiTempAlarm_V (float hitempAlarm);
DllAccess short int _stdcall PutLowInsideHumAlarm_V (short int lowInsideAlarm);
DllAccess short int _stdcall PutHiInsideHumAlarm_V (short int hiInsideAlarm);
DllAccess short int _stdcall PutLowOutsideHumAlarm_V (short int lowOutsideAlarm);
DllAccess short int _stdcall PutHiOutsideHumAlarm_V (short int hiOutsideAlarm);
DllAccess short int _stdcall PutLowWindChillAlarm_V (float lowWindChillAlarm);
DllAccess short int _stdcall PutLowDewPtAlarm_V (int lowDewPoint);
DllAccess short int _stdcall PutHiDewPtAlarm_V (int hiDewPoint);
DllAccess short int _stdcall PutHiSolarRadAlarm_V (short solarAlarm);
DllAccess short int _stdcall PutHiWindSpeedAlarm_V (float hiAlarm);
DllAccess short int _stdcall PutHi10MinWindSpeedAlarm_V (float hiAlarm);
DllAccess short int _stdcall PutHiHeatIndexAlarm_V (float heatAlarm);
DllAccess short int _stdcall PutHiTHSWAlarm_V (float thswAlarm);
DllAccess short int _stdcall PutHiRainFloodAlarm_V (float hiAlarm);
DllAccess short int _stdcall PutRainPerDayAlarm_V (float hiAlarm);
DllAccess short int _stdcall PutRainStormAlarm_V (float hiAlarm);
DllAccess short int _stdcall PutRainRateAlarm_V (float hiAlarm);
DllAccess short int _stdcall PutHiUVAlarm_V (float uvAlarm);
DllAccess short int _stdcall PutHiUVMedAlarm_V (float uvMedAlarm);

//DllAccess short int _stdcall PutHiDailyEtAlarm (float etAlarm);

// Add Extra Temp/Hum alarms here
// Add Leaf/Soil Alarms here

// Clear Alarm thresholds 
DllAccess short int _stdcall ClearBarRiseAlarm_V (void);
DllAccess short int _stdcall ClearBarFallAlarm_V (void);
DllAccess short int _stdcall ClearTimeAlarm_V (void);
DllAccess short int _stdcall ClearInsideLowTempAlarm_V (void);
DllAccess short int _stdcall ClearInsideHiTempAlarm_V (void);
DllAccess short int _stdcall ClearOutsideLowTempAlarm_V (void);
DllAccess short int _stdcall ClearOutsideHiTempAlarm_V (void);
DllAccess short int _stdcall ClearLowInsideHumAlarm_V (void);
DllAccess short int _stdcall ClearHiInsideHumAlarm_V (void);
DllAccess short int _stdcall ClearLowOutsideHumAlarm_V (void);
DllAccess short int _stdcall ClearHiOutsideHumAlarm_V (void);
DllAccess short int _stdcall ClearLowWindChillAlarm_V (void);
DllAccess short int _stdcall ClearLowDewPtAlarm_V (void);
DllAccess short int _stdcall ClearHiDewPtAlarm_V (void);
DllAccess short int _stdcall ClearHiSolarRadAlarm_V (void);
DllAccess short int _stdcall ClearHiWindSpeedAlarm_V (void);
DllAccess short int _stdcall ClearHi10MinWindSpeedAlarm_V (void);
DllAccess short int _stdcall ClearHiHeatIndexAlarm_V (void);
DllAccess short int _stdcall ClearHiTHSWAlarm_V (void);
DllAccess short int _stdcall ClearHiRainFloodAlarm_V (void);
DllAccess short int _stdcall ClearHiRainPerDayAlarm_V (void);
DllAccess short int _stdcall ClearRainStormAlarm_V (void);
DllAccess short int _stdcall ClearRainRateAlarm_V (void);
DllAccess short int _stdcall ClearHiUVAlarm_V (void);
DllAccess short int _stdcall ClearHiUVMedAlarm_V (void);

// Add Extra Temp/Hum alarms here
// Add Leaf/Soil Alarms here

//HiLow Functions
DllAccess int       _stdcall LoadVantageHiLows_V(void);

DllAccess float     _stdcall GetHiOutsideTemp_V(void); 
DllAccess float     _stdcall GetLowOutsideTemp_V(void); 
DllAccess short int _stdcall GetHiLowTimesOutTemp_V (DateTime* DateTimeHiOutTemp, DateTime* DateTimeLowOutTemp);

DllAccess float     _stdcall GetHiInsideTemp_V(void); 
DllAccess float     _stdcall GetLowInsideTemp_V(void); 
DllAccess short int _stdcall GetHiLowTimesInTemp_V (DateTime* DateTimeHiInTemp, DateTime* DateTimeLowInTemp);

DllAccess short int _stdcall GetHiOutsideHum_V(void); 
DllAccess short int _stdcall GetLowOutsideHum_V(void); 
DllAccess short int _stdcall GetHiLowTimesOutHum_V (DateTime* DateTimeHiOutHum, DateTime* DateTimeLowOutHum);

DllAccess short int _stdcall GetHiInsideHum_V(void); 
DllAccess short int _stdcall GetLowInsideHum_V(void); 
DllAccess short int _stdcall GetHiLowTimesInHum_V (DateTime* DateTimeHiInHum, DateTime* DateTimeLowInHum);

DllAccess float     _stdcall GetHiDewPt_V(void); 
DllAccess float     _stdcall GetLowDewPt_V(void); 
DllAccess short int _stdcall GetHiLowTimesDewPt_V (DateTime* DateTimeHiDewPt, DateTime* DateTimeLowDewPt);

DllAccess float     _stdcall GetLowWindChill_V(void); 
DllAccess short int _stdcall GetLowTimesWindChill_V (DateTime* DateTimeLowWindChill);

DllAccess float     _stdcall GetHiWindSpeed_V(void);
DllAccess short int _stdcall GetHiTimesWindSpeed_V (DateTime* DateTimeHiWindSpeed);

DllAccess float _stdcall GetHiLowDataByID_V(DWORD weatherDataID );
DllAccess short int _stdcall GetHiLowDataStrByID_V(DWORD weatherDataID, char *s, short int bufferLength);
DllAccess short int _stdcall GetHiLowTimeByID_V(DWORD weatherDataID, DateTimeStamp *dateTimeValue);
DllAccess short int _stdcall GetHiLowTimeStrByID_V(DWORD weatherDataID, char *s, short int bufferLength);

//Calibrate Functions
DllAccess int _stdcall LoadVantageCalibration_V(CurrentVantageCalibration &vantageCalibration);

DllAccess int _stdcall PutOutsideTempCalibrationValue_V(float calValue);
DllAccess int _stdcall PutInsideTempCalibrationValue_V(float calValue);
DllAccess int _stdcall PutOutsideHumCalibrationValue_V(short calValue);
DllAccess int _stdcall PutInsideHumCalibrationValue_V(short calValue);

DllAccess int _stdcall PutOutsideTempCalibrationOffset_V(float calValue);
DllAccess int _stdcall PutInsideTempCalibrationOffset_V(float calValue);
DllAccess int _stdcall PutOutsideHumCalibrationOffset_V(short calValue);
DllAccess int _stdcall PutInsideHumCalibrationOffset_V(short calValue);


DllAccess int _stdcall PutOutsideTempCalibrationValueEx_V(int sensorNumber, float calValue);
DllAccess int _stdcall PutOutsideTempCalibrationOffsetEx_V(int sensorNumber, float calValue);

DllAccess int _stdcall PutOutsideHumCalibrationValueEx_V(int sensorNumber, short calValue);
DllAccess int _stdcall PutOutsideHumCalibrationOffsetEx_V(int sensorNumber, short calValue);


DllAccess int _stdcall SetVantageCalibration_V();
DllAccess int       _stdcall PutBarometer_V (float bar, short elev);

DllAccess int _stdcall PutWindDirCalibrationOffset_V( short windDirCal );
DllAccess int _stdcall GetWindDirCalibrationOffset_V( short &windDirCal );

DllAccess int _stdcall PutLowExtraTempAlarm_V( int sensorNumber, float lowtempExAlarm );
DllAccess int _stdcall PutHiExtraTempAlarm_V( int sensorNumber, float hitempExAlarm );
DllAccess int _stdcall PutLowExtraHumAlarm_V( int sensorNumber, int lowHumExAlarm );
DllAccess int _stdcall PutHiExtraHumAlarm_V( int sensorNumber, int hiHumExAlarm );
DllAccess int _stdcall PutLowSoilTempAlarm_V( int sensorNumber, int lowSoilTempAlarm );
DllAccess int _stdcall PutHiSoilTempAlarm_V( int sensorNumber, int hiSoilTempAlarm );
DllAccess int _stdcall PutLowSoilMoistureAlarm_V( int sensorNumber, int lowSoilMoistureAlarm );
DllAccess int _stdcall PutHiSoilMoistureAlarm_V( int sensorNumber, int hiSoilMoistureAlarm );
DllAccess int _stdcall PutLowLeafTempAlarm_V( int sensorNumber, int lowLeafTempAlarm );
DllAccess int _stdcall PutHiLeafTempAlarm_V( int sensorNumber, int hiLeafTempAlarm );
DllAccess int _stdcall PutLowLeafWetAlarm_V( int sensorNumber, int lowLeafWetAlarm );
DllAccess int _stdcall PutHiLeafWetAlarm_V( int sensorNumber, int hiLeafWetAlarm );
DllAccess short int _stdcall ClearLowExtraTempAlarm_V (int sensorNumber);
DllAccess short int _stdcall ClearHiExtraTempAlarm_V (int sensorNumber);
DllAccess short int _stdcall ClearLowExtraHumAlarm_V ( int sensorNumber );
DllAccess short int _stdcall ClearHiExtraHumAlarm_V ( int sensorNumber );
DllAccess short int _stdcall ClearLowSoilTempAlarm_V ( int sensorNumber );
DllAccess short int _stdcall ClearHiSoilTempAlarm_V ( int sensorNumber );
DllAccess short int _stdcall ClearLowSoilMoistureAlarm_V ( int sensorNumber );
DllAccess short int _stdcall ClearHiSoilMoistureAlarm_V ( int sensorNumber );
DllAccess short int _stdcall ClearLowLeafTempAlarm_V(short sensorNumber);
DllAccess short int _stdcall ClearHiLeafTempAlarm_V(short sensorNumber);
DllAccess short int _stdcall ClearLowLeafWetAlarm_V(short sensorNumber);
DllAccess short int _stdcall ClearHiLeafWetAlarm_V(short sensorNumber);


//Download functions
DllAccess int       _stdcall DownloadData_V(DateTimeStamp dateTimeStamp);
DllAccess int       _stdcall DownloadWebData_V(DateTimeStamp dateTimeStamp, char *userName, char *password);
DllAccess short int _stdcall GetNumberOfArchiveRecords_V(void);
DllAccess short int _stdcall GetMemoryArchiveRecordCount_V(void);
DllAccess short int _stdcall GetMemoryArchiveCountAfterDate_V(DateTimeStamp *dateTimeStamp);
DllAccess short int _stdcall GetArchiveRecord_V(WeatherRecordStruct* newRecord, short int i);
DllAccess short int _stdcall GetArchiveRecordEx_V(WeatherRecordStructEx* newRecordStruct, short int i);

//Clear functions
DllAccess int _stdcall ClearVantageLows_V(void);
DllAccess int _stdcall ClearVantageAlarms_V(void);
DllAccess int _stdcall ClearVantageCalNums_V(void);
DllAccess int _stdcall ClearCurrentData_V(void);
DllAccess int _stdcall ClearStoredData_V(void);
DllAccess int _stdcall ClearReceiveBuffer_V (void);
 

#endif
