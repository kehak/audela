// absimple.cs
// import interface of abcatalog astrobrick

using System;
using System.Runtime.InteropServices;

public class ABSimple
{
    // import ABSimple static functions
    // theses function can be used by user programs
    [DllImport("libabsimple")]
    public static extern int absimple_processAdd(int a, int b);
    [DllImport("libabsimple")]
    public static extern int absimple_processSub(int a, int b);

    // import ABSimple classes
    // theses classes can not be used by user programs.
    // they are redefined below
    protected class ISimple
    {
        // import ICalculator methods
        [DllImport("libabsimple")]
        public static extern IntPtr ICalculator_createInstance(ErrorHelper.ErrorDelegate errorCallbackFunction);
        [DllImport("libabsimple")]
        public static extern void ICalculator_releaseInstance(HandleRef instancePtr);
        [DllImport("libabsimple")]
        public static extern double ICalculator_add(HandleRef instancePtr, double a);
        [DllImport("libabsimple")]
        public static extern double ICalculator_divide(HandleRef instancePtr, double a);
        [DllImport("libabsimple")]
        public static extern double ICalculator_sub(HandleRef instancePtr, double a);
        [DllImport("libabsimple")]
        public static extern double ICalculator_set(HandleRef instancePtr, double a);
        [DllImport("libabsimple")]
        public static extern double ICalculator_clear(HandleRef instancePtr);

        // import ICalendar methods
        [DllImport("libabsimple")]
        public static extern IntPtr ICalendar_createInstance(ErrorHelper.ErrorDelegate errorCallbackFunction);
        [DllImport("libabsimple")]
        public static extern void ICalendar_releaseInstance(HandleRef instancePtr);
        [DllImport("libabsimple", CharSet = CharSet.Ansi)]
        public static extern IntPtr ICalendar_convertIntToString(HandleRef instancePtr, int year, int month, int day, int hour, int minute, int second);
        [DllImport("libabsimple")]
        public static extern IntPtr ICalendar_convertIntToStruct(HandleRef instancePtr, int year, int month, int day, int hour, int minute, int second);
        [DllImport("libabsimple")]  //, CallingConvention = CallingConvention.Cdecl
        public static extern IntPtr ICalendar_convertStringToStruct(HandleRef instancePtr, string charDate);

        // import IDateTimeStruct methods ( structure => no contructor)
        [DllImport("libabsimple")]
        public static extern void IDateTime_releaseInstance(HandleRef instancePtr);
        [DllImport("libabsimple")]
        public static extern void IDateTime_year_set(HandleRef instancePtr, int value);
        [DllImport("libabsimple")]
        public static extern int IDateTime_year_get(HandleRef instancePtr);
        [DllImport("libabsimple")]
        public static extern void IDateTime_month_set(HandleRef instancePtr, int value);
        [DllImport("libabsimple")]
        public static extern int IDateTime_month_get(HandleRef instancePtr);
        [DllImport("libabsimple")]
        public static extern void IDateTime_day_set(HandleRef instancePtr, int value);
        [DllImport("libabsimple")]
        public static extern int IDateTime_day_get(HandleRef instancePtr);
        [DllImport("libabsimple")]
        public static extern void IDateTime_hour_set(HandleRef instancePtr, int value);
        [DllImport("libabsimple")]
        public static extern int IDateTime_hour_get(HandleRef instancePtr);
        [DllImport("libabsimple")]
        public static extern void IDateTime_minute_set(HandleRef instancePtr, int value);
        [DllImport("libabsimple")]
        public static extern int IDateTime_minute_get(HandleRef instancePtr);
        [DllImport("libabsimple")]
        public static extern void IDateTime_second_set(HandleRef instancePtr, int value);
        [DllImport("libabsimple")]
        public static extern int IDateTime_second_get(HandleRef instancePtr);


        /////////////////////////////////////////////////////////////////////////////////////
        // Manage returned strings
        /////////////////////////////////////////////////////////////////////////////////////    
        [DllImport("libabsimple")]
        public static extern int absimple_releaseCharArray(IntPtr charArrayPtr);
    }


    //=========================================================================
    // ErrorHelper and PendingError
    //=========================================================================       
    protected class ErrorHelper
    {
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void ErrorDelegate(int code, string message);

        public static ErrorDelegate errorDelegate = new ErrorDelegate(SetPendingError);

        static void SetPendingError(int code, string message)
        {
            PendingError.Set(new Error(code, message, PendingError.Retrieve()));
        }
    }

    protected static ErrorHelper errorHelper = new ErrorHelper();

    protected class PendingError
    {
        [System.ThreadStatic]
        private static Error pendingException = null;
        private static int numExceptionsPending = 0;

        public static bool Pending
        {
            get
            {
                bool pending = false;
                if (numExceptionsPending > 0)
                    if (pendingException != null)
                        pending = true;
                return pending;
            }
        }

        public static void Set(Error e)
        {
            if (pendingException != null)
                throw new System.ApplicationException("FATAL: An earlier pending exception from unmanaged code was missed and thus not thrown (" + pendingException.ToString() + ")", e);
            pendingException = e;
            lock (typeof(ABSimple))
            {
                numExceptionsPending++;
            }
        }

        public static Error Retrieve()
        {
            Error e = null;
            if (numExceptionsPending > 0)
            {
                if (pendingException != null)
                {
                    e = pendingException;
                    pendingException = null;
                    lock (typeof(ABSimple))
                    {
                        numExceptionsPending--;
                    }
                }
            }
            return e;
        }
    }

    //=========================================================================
    // Error 
    //========================================================================= 
    public class Error : Exception
    {
        public Error(int code, string message)
            : base(message)
        {
            this.code = code;
        }

        public Error(int code, string message, Error error)
            : base(message, error)
        {
            this.code = code;
        }

        public readonly int code;

    }
    

    //=========================================================================
    // Calculator 
    //========================================================================= 
    public class Calculator
    {
        private HandleRef instancePtr;

        // constructor
        public Calculator()
        {
            System.IntPtr cPtr = ISimple.ICalculator_createInstance(ErrorHelper.errorDelegate);
            instancePtr = new System.Runtime.InteropServices.HandleRef(this, cPtr);
        }

        ~Calculator()
        {
            Dispose();
        }

        public void Dispose()
        {
            lock (this)
            {
                if (instancePtr.Handle != System.IntPtr.Zero)
                {
                    ISimple.ICalculator_releaseInstance(instancePtr);
                    instancePtr = new System.Runtime.InteropServices.HandleRef(null, System.IntPtr.Zero);
                }
                System.GC.SuppressFinalize(this);
            }
        }


        public double add(double a)
        {
            return ISimple.ICalculator_add(instancePtr, a);
        }

        public double divide(double a)
        {
            double result = ISimple.ICalculator_divide(instancePtr, a);
            if (PendingError.Pending) throw PendingError.Retrieve();
            return result;
        }

        public double sub(double a)
        {
            return ISimple.ICalculator_sub(instancePtr, a);
        }

        public double set(double a)
        {
            return ISimple.ICalculator_set(instancePtr, a);
        }

        public double clear(double a)
        {
            return ISimple.ICalculator_clear(instancePtr);
        }

    }

    //=========================================================================
    // Calendar 
    //========================================================================= 
    public class Calendar : System.IDisposable
    {
        private HandleRef instancePtr;

        // constructor
        public Calendar()
        {
            System.IntPtr cPtr = ISimple.ICalendar_createInstance(ErrorHelper.errorDelegate);
            instancePtr = new System.Runtime.InteropServices.HandleRef(this, cPtr);
        }

        ~Calendar()
        {
            Dispose();
        }

        public void Dispose()
        {
            lock (this)
            {
                if (instancePtr.Handle != System.IntPtr.Zero)
                {
                    ISimple.ICalendar_releaseInstance(instancePtr);
                    instancePtr = new System.Runtime.InteropServices.HandleRef(null, System.IntPtr.Zero);
                }
                System.GC.SuppressFinalize(this);
            }
        }


        public string convertIntToString(int year, int month, int day, int hour, int minute, int second)
        {
            IntPtr charArrayPtr = ISimple.ICalendar_convertIntToString(instancePtr, year, month, day, hour, minute, second);
            if (PendingError.Pending) throw PendingError.Retrieve();
            string value = Marshal.PtrToStringAnsi(charArrayPtr);
            ISimple.absimple_releaseCharArray(charArrayPtr);
            return value;

        }

        public DateTime convertIntToStruct(int year, int month, int day, int hour, int minute, int second)
        {
            IntPtr intPtr = ISimple.ICalendar_convertIntToStruct(instancePtr, year, month, day, hour, minute, second);
            if (PendingError.Pending) throw PendingError.Retrieve();
            return new DateTime(intPtr);
        }


        public DateTime convertStringToStruct(string stringDate)
        {
            IntPtr intPtr = ISimple.ICalendar_convertStringToStruct(instancePtr, stringDate);
            if (PendingError.Pending) throw PendingError.Retrieve();
            return new DateTime(intPtr);
        }

    }


    //=========================================================================
    // DateTimeStruct 
    //========================================================================= 
    public class DateTime : System.IDisposable
    {
        private HandleRef instancePtr;

        internal DateTime(System.IntPtr cPtr)
        {
            instancePtr = new System.Runtime.InteropServices.HandleRef(this, cPtr);
        }

        ~DateTime()
        {
            Dispose();
        }

        public void Dispose()
        {
            lock (this)
            {
                if (instancePtr.Handle != System.IntPtr.Zero)
                {
                    ISimple.IDateTime_releaseInstance(instancePtr);
                    instancePtr = new System.Runtime.InteropServices.HandleRef(null, System.IntPtr.Zero);
                }
                System.GC.SuppressFinalize(this);
            }
        }

        public int year
        {
            set { ISimple.IDateTime_year_set(instancePtr, value); }
            get { return ISimple.IDateTime_year_get(instancePtr); }
        }

        public int month
        {
            set { ISimple.IDateTime_month_set(instancePtr, value); }
            get { return ISimple.IDateTime_month_get(instancePtr); }
        }

        public int day
        {
            set { ISimple.IDateTime_day_set(instancePtr, value); }
            get { return ISimple.IDateTime_day_get(instancePtr); }
        }

        public int hour
        {
            set { ISimple.IDateTime_hour_set(instancePtr, value); }
            get { return ISimple.IDateTime_hour_get(instancePtr); }
        }

        public int minute
        {
            set { ISimple.IDateTime_minute_set(instancePtr, value); }
            get { return ISimple.IDateTime_minute_get(instancePtr); }
        }

        public int second
        {
            set { ISimple.IDateTime_second_set(instancePtr, value); }
            get { return ISimple.IDateTime_second_get(instancePtr); }
        }

    }
}

