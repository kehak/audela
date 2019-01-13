--- generic/mysqltcl.c.orig	2008-04-02 16:46:38.000000000 +0200
+++ generic/mysqltcl.c	2008-04-02 16:52:11.000000000 +0200
@@ -42,11 +42,6 @@
 #include <tcl.h>
 #include <mysql.h>
 
-#if (MYSQL_VERSION_ID<40100)
-  #error You need Mysql version 4.1 or higher to compile mysqltcl
-#endif
-
-
 #include <errno.h>
 #include <string.h>
 #include <ctype.h>
@@ -97,6 +92,8 @@
 #define MYSQL_STATUS_MSG  "message"
 #define MYSQL_STATUS_NULLV  "nullvalue"
 
+#define FUNCTION_NOT_AVAILABLE "function not available"
+
 /* C variable corresponding to mysqlstatus(nullvalue) */
 #define MYSQL_NULLV_INIT ""
 
@@ -714,7 +711,10 @@
 static CONST char* MysqlConnectOpt[] =
     {
       "-host", "-user", "-password", "-db", "-port", "-socket","-encoding",
-      "-ssl", "-compress", "-noschema","-odbc","-multistatement","-multiresult",
+      "-ssl", "-compress", "-noschema","-odbc",
+#if (MYSQL_VERSION_ID >= 40107)
+      "-multistatement","-multiresult",
+#endif
       "-localfiles","-ignorespace","-foundrows","-interactive","-sslkey","-sslcert",
       "-sslca","-sslcapath","-sslciphers",NULL
     };
@@ -731,7 +731,9 @@
   char *socket = NULL;
   char *encodingname = NULL;
 
+#if (MYSQL_VERSION_ID >= 40107)
   int isSSL = 0;
+#endif
   char *sslkey = NULL;
   char *sslcert = NULL;
   char *sslca = NULL;
@@ -746,7 +748,10 @@
     MYSQL_CONNHOST_OPT, MYSQL_CONNUSER_OPT, MYSQL_CONNPASSWORD_OPT,
     MYSQL_CONNDB_OPT, MYSQL_CONNPORT_OPT, MYSQL_CONNSOCKET_OPT, MYSQL_CONNENCODING_OPT,
     MYSQL_CONNSSL_OPT, MYSQL_CONNCOMPRESS_OPT, MYSQL_CONNNOSCHEMA_OPT, MYSQL_CONNODBC_OPT,
-    MYSQL_MULTISTATEMENT_OPT,MYSQL_MULTIRESULT_OPT,MYSQL_LOCALFILES_OPT,MYSQL_IGNORESPACE_OPT,
+#if (MYSQL_VERSION_ID >= 40107)
+    MYSQL_MULTISTATEMENT_OPT,MYSQL_MULTIRESULT_OPT,
+#endif
+    MYSQL_LOCALFILES_OPT,MYSQL_IGNORESPACE_OPT,
     MYSQL_FOUNDROWS_OPT,MYSQL_INTERACTIVE_OPT,MYSQL_SSLKEY_OPT,MYSQL_SSLCERT_OPT,
     MYSQL_SSLCA_OPT,MYSQL_SSLCAPATH_OPT,MYSQL_SSLCIPHERS_OPT
   };
@@ -787,8 +792,15 @@
       encodingname = Tcl_GetStringFromObj(objv[++i],NULL);
       break;
     case MYSQL_CONNSSL_OPT:
+#if (MYSQL_VERSION_ID >= 40107)
       if (Tcl_GetBooleanFromObj(interp,objv[++i],&isSSL) != TCL_OK )
 	return TCL_ERROR;
+#else
+      if (Tcl_GetBooleanFromObj(interp,objv[++i],&booleanflag) != TCL_OK )
+	return TCL_ERROR;
+      if (booleanflag)
+        flags |= CLIENT_SSL;
+#endif
       break;
     case MYSQL_CONNCOMPRESS_OPT:
       if (Tcl_GetBooleanFromObj(interp,objv[++i],&booleanflag) != TCL_OK )
@@ -808,6 +820,7 @@
       if (booleanflag)
 	flags |= CLIENT_ODBC;
       break;
+#if (MYSQL_VERSION_ID >= 40107)
     case MYSQL_MULTISTATEMENT_OPT:
       if (Tcl_GetBooleanFromObj(interp,objv[++i],&booleanflag) != TCL_OK )
 	return TCL_ERROR;
@@ -822,7 +835,7 @@
       if (booleanflag)
 	flags |= CLIENT_MULTI_RESULTS;
       break;
-
+#endif
     case MYSQL_LOCALFILES_OPT:
       if (Tcl_GetBooleanFromObj(interp,objv[++i],&booleanflag) != TCL_OK )
 	return TCL_ERROR;
@@ -881,9 +894,11 @@
 #if (MYSQL_VERSION_ID>=32350)
   mysql_options(handle->connection,MYSQL_READ_DEFAULT_GROUP,groupname);
 #endif
+#if (MYSQL_VERSION_ID >= 40107)
   if (isSSL) {
       mysql_ssl_set(handle->connection,sslkey,sslcert, sslca, sslcapath, sslcipher);
   }
+#endif
 
   if (!mysql_real_connect(handle->connection, hostname, user,
                                 password, db, port, socket, flags)) {
@@ -1514,7 +1529,11 @@
   static CONST char* MysqlDbOpt[] =
     {
       "dbname", "dbname?", "tables", "host", "host?", "databases",
-      "info","serverversion","serverversionid","sqlstate","state",NULL
+      "info","serverversion",
+#if (MYSQL_VERSION_ID >= 40107)
+      "serverversionid","sqlstate",
+#endif
+      "state",NULL
     };
   enum dboption {
     MYSQL_INFNAME_OPT, MYSQL_INFNAMEQ_OPT, MYSQL_INFTABLES_OPT,
@@ -1548,8 +1567,10 @@
     break;
   case MYSQL_INFO:
   case MYSQL_INF_SERVERVERSION:
+#if (MYSQL_VERSION_ID >= 40107)
   case MYSQL_INFO_SERVERVERSION_ID:
   case MYSQL_INFO_SQLSTATE:
+#endif
   case MYSQL_INFO_STATE:
     break;
 
@@ -1606,12 +1627,14 @@
   case MYSQL_INF_SERVERVERSION:
      Tcl_SetObjResult(interp, Tcl_NewStringObj(mysql_get_server_info(handle->connection),-1));
      break;
+#if (MYSQL_VERSION_ID >= 40107)
   case MYSQL_INFO_SERVERVERSION_ID:
 	 Tcl_SetObjResult(interp, Tcl_NewIntObj(mysql_get_server_version(handle->connection)));
 	 break;
   case MYSQL_INFO_SQLSTATE:
      Tcl_SetObjResult(interp, Tcl_NewStringObj(mysql_sqlstate(handle->connection),-1));
      break;
+#endif
   case MYSQL_INFO_STATE:
      Tcl_SetObjResult(interp, Tcl_NewStringObj(mysql_stat(handle->connection),-1));
      break;
@@ -1638,7 +1661,11 @@
   char **option;
   static CONST char* MysqlInfoOpt[] =
     {
-      "connectparameters", "clientversion","clientversionid", NULL
+      "connectparameters", "clientversion",
+#if (MYSQL_VERSION_ID >= 40107)
+      "clientversionid",
+#endif
+      NULL
     };
   enum baseoption {
     MYSQL_BINFO_CONNECT, MYSQL_BINFO_CLIENTVERSION,MYSQL_BINFO_CLIENTVERSIONID
@@ -1668,9 +1695,11 @@
   case MYSQL_BINFO_CLIENTVERSION:
     Tcl_SetObjResult(interp, Tcl_NewStringObj(mysql_get_client_info(),-1));
     break;
+#if (MYSQL_VERSION_ID >= 40107)
   case MYSQL_BINFO_CLIENTVERSIONID:
     Tcl_SetObjResult(interp, Tcl_NewIntObj(mysql_get_client_version()));
     break;
+#endif
   }
   return TCL_OK ;
 }
@@ -1987,6 +2016,10 @@
 
 static int Mysqltcl_AutoCommit(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
 {
+#if (MYSQL_VERSION_ID < 40107)
+  Tcl_AddErrorInfo(interp, FUNCTION_NOT_AVAILABLE);
+  return TCL_ERROR;
+#else
   MysqlTclHandle *handle;
   int isAutocommit = 0;
 
@@ -1999,6 +2032,7 @@
   	mysql_server_confl(interp,objc,objv,handle->connection);
   }
   return TCL_OK;
+#endif
 }
 /*
  *----------------------------------------------------------------------
@@ -2010,6 +2044,10 @@
 
 static int Mysqltcl_Commit(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
 {
+#if (MYSQL_VERSION_ID < 40107)
+  Tcl_AddErrorInfo(interp, FUNCTION_NOT_AVAILABLE);
+  return TCL_ERROR;
+#else
   MysqlTclHandle *handle;
 
   if ((handle = mysql_prologue(interp, objc, objv, 2, 2, CL_CONN,
@@ -2019,6 +2057,7 @@
   	mysql_server_confl(interp,objc,objv,handle->connection);
   }
   return TCL_OK;
+#endif
 }
 /*
  *----------------------------------------------------------------------
@@ -2030,6 +2069,10 @@
 
 static int Mysqltcl_Rollback(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
 {
+#if (MYSQL_VERSION_ID < 40107)
+  Tcl_AddErrorInfo(interp, FUNCTION_NOT_AVAILABLE);
+  return TCL_ERROR;
+#else
   MysqlTclHandle *handle;
 
   if ((handle = mysql_prologue(interp, objc, objv, 2, 2, CL_CONN,
@@ -2039,6 +2082,7 @@
       mysql_server_confl(interp,objc,objv,handle->connection);
   }
   return TCL_OK;
+#endif
 }
 /*
  *----------------------------------------------------------------------
@@ -2050,6 +2094,10 @@
 
 static int Mysqltcl_MoreResult(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
 {
+#if (MYSQL_VERSION_ID < 40107)
+  Tcl_AddErrorInfo(interp, FUNCTION_NOT_AVAILABLE);
+  return TCL_ERROR;
+#else
   MysqlTclHandle *handle;
   int boolResult = 0;
 
@@ -2059,6 +2107,7 @@
   boolResult =  mysql_more_results(handle->connection);
   Tcl_SetObjResult(interp,Tcl_NewBooleanObj(boolResult));
   return TCL_OK;
+#endif
 }
 /*
 
@@ -2072,6 +2121,10 @@
 
 static int Mysqltcl_NextResult(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
 {
+#if (MYSQL_VERSION_ID < 40107)
+  Tcl_AddErrorInfo(interp, FUNCTION_NOT_AVAILABLE);
+  return TCL_ERROR;
+#else
   MysqlTclHandle *handle;
   int result = 0;
 
@@ -2098,6 +2151,7 @@
       Tcl_SetObjResult(interp, Tcl_NewIntObj(handle->res_count));
   }
   return TCL_OK;
+#endif
 }
 /*
  *----------------------------------------------------------------------
@@ -2109,6 +2163,10 @@
 
 static int Mysqltcl_WarningCount(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
 {
+#if (MYSQL_VERSION_ID < 40107)
+  Tcl_AddErrorInfo(interp, FUNCTION_NOT_AVAILABLE);
+  return TCL_ERROR;
+#else
   MysqlTclHandle *handle;
   int count = 0;
 
@@ -2118,6 +2176,7 @@
   count = mysql_warning_count(handle->connection);
   Tcl_SetObjResult(interp,Tcl_NewIntObj(count));
   return TCL_OK;
+#endif
 }
 /*
  *----------------------------------------------------------------------
@@ -2176,13 +2235,19 @@
  *    usage: mysql::setserveroption (-
  *
  */
+#if (MYSQL_VERSION_ID >= 40107)
 static CONST char* MysqlServerOpt[] =
     {
       "-multi_statment_on", "-multi_statment_off",NULL
     };
+#endif
 
 static int Mysqltcl_SetServerOption(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
 {
+#if (MYSQL_VERSION_ID < 40107)
+  Tcl_AddErrorInfo(interp, FUNCTION_NOT_AVAILABLE);
+  return TCL_ERROR;
+#else
   MysqlTclHandle *handle;
   int idx;
   enum enum_mysql_set_option mysqlServerOption;
@@ -2213,6 +2278,7 @@
   	mysql_server_confl(interp,objc,objv,handle->connection);
   }
   return TCL_OK;
+#endif
 }
 /*
  *----------------------------------------------------------------------
@@ -2228,7 +2294,11 @@
   if ((handle = mysql_prologue(interp, objc, objv, 2, 2, CL_CONN,
 			    "handle")) == 0)
     return TCL_ERROR;
+#if (MYSQL_VERSION_ID >= 40107)
   if (mysql_shutdown(handle->connection,SHUTDOWN_DEFAULT)!=0) {
+#else
+  if (mysql_shutdown(handle->connection)!=0) {
+#endif
   	mysql_server_confl(interp,objc,objv,handle->connection);
   }
   return TCL_OK;