/*
 * dialog.h
 *
 * 32-bit Motion Control Device Driver
 *
 */

typedef struct tag_combobox_entry {
   DWORD wValue;
   LPTSTR szText;
} COMBOBOX_ENTRY;

BOOL    ConfigSetParameters(PREG_ACCESS pRegAccess,PVOID pGeneric);
VOID    ConfigGetParameters(PREG_ACCESS pRegAccess,PCONFIG_LOCATION pLoc);
LRESULT ConfigRemove(PREG_ACCESS pRegAccess, HWND hDlg);
int     Config(HWND hWnd, PREG_ACCESS pRegAccess);
VOID    ConfigErrorMsgBox(HWND hDlg, DWORD wStringId);
int     ConfigLoadComboBox(HWND hDlg,int wID,COMBOBOX_ENTRY *pCBE,int nEntries,DWORD wInitialValue);
DWORD   ConfigGetComboBoxValue(HWND hDlg,int wID,COMBOBOX_ENTRY *pCBE);
int     ConfigSetComboBoxSelection(HWND hDlg,int wID,COMBOBOX_ENTRY *pCBE,int nEntries,DWORD dwSelectValue);
DWORD   ConfigGetEditValue(HWND hDlg,int wID,int numberbase);

DWORD   ConfigConfirmLegalValue(COMBOBOX_ENTRY *pCBE,int nEntries,DWORD wValueToTest);
BOOL CALLBACK PmacSetParameters(DWORD dwDevice,PCONFIG_LOCATION pLoc);
VOID CALLBACK PmacGetParameters(DWORD dwDevice,PCONFIG_LOCATION pLoc);
long CALLBACK PmacConfigureDriver(DWORD dwDevice,PCONFIG_LOCATION pLoc);

long CALLBACK    PmacSelect(HWND hWnd);

