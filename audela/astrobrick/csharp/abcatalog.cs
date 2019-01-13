// abcatalog.cs
// import interface of abcatalog astrobrick

using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;  // for List

class ABCatalog
{
    protected class ICatalog
    {
        // import ICatalog methods
        [DllImport("libcatalog")]
        public static extern IntPtr ICatalog_createInstance(ErrorHelper.ErrorDelegate errorDelegate);
        [DllImport("libcatalog")]
        public static extern void ICatalog_releaseInstance(HandleRef instancePtr);
        [DllImport("libcatalog")]
        public static extern IntPtr ICatalog_cstycho2(HandleRef instancePtr, string catalogPath, double ra, double dec, double radius, double magMin, double magMax);
        [DllImport("libcatalog")]
        public static extern IntPtr ICatalog_releaseListOfStarTycho(HandleRef instancePtr, IntPtr starTychoList);	
    }
    
    [StructLayout(LayoutKind.Sequential)] 
    public class StarTycho 
    {		
	    public double ra;
	    public double dec;
	    public double pmRa;
	    public double pmDec;
	    public double errorPmRa;
	    public double errorPmDec;
	    public double meanEpochRA;
	    public double meanEpochDec;
	    public double goodnessOfFitRa;
	    public double goodnessOfFitDec;
	    public double goodnessOfFitPmRa;
	    public double goodnessOfFitPmDec;
	    public double magnitudeB;
	    public double errorMagnitudeB;
	    public double magnitudeV;
	    public double errorMagnitudeV;
	    public double observedRa;
	    public double observedDec;
	    public double epoch1990Ra;
	    public double epoch1990Dec;
	    public double errorObservedRa;
	    public double errorObservedDec;
	    public double correlationRaDec;
	    public int id;
	    public int idTycho1;
	    public int idTycho2;
	    public int numberOfUsedPositions;
	    public int errorRa;
	    public int errorDec;
	    public int proximityIndicator;
	    public int hipparcosId;
	    public Char isTycho1Star;
	    public Char idTycho3;
	    public Char pflag;
	    public Char solutionType;
	    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=3)] 
	    public String componentIdentifierHIP; // Only 3 are needed but to correctly align the structure we add 1 char
    }

    [StructLayout(LayoutKind.Sequential)] 
    protected class StarTychoList
    {
        public StarTycho   star;
        public IntPtr nextStarList;
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
                    lock (typeof(ABCatalog))
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
        public Error(int code, string message) : base(message)
        {
            this.code = code; 
        }

        public Error(int code, string message, Error error) : base (message, error)
        {
            this.code = code;
        }

        public readonly int code; 
       
    }

    //=========================================================================
    // Catalog 
    //========================================================================= 
    public class Catalog : System.IDisposable
    {
        private HandleRef instancePtr;

        // constructor
        public Catalog()
        {
            System.IntPtr cPtr = ICatalog.ICatalog_createInstance(ErrorHelper.errorDelegate);
            instancePtr = new System.Runtime.InteropServices.HandleRef(this, cPtr);
        }

        ~Catalog()
        {
            Dispose();
        }

        public void Dispose() 
        {
            lock (this)
            {
                if (instancePtr.Handle != IntPtr.Zero)
                {
                    ICatalog.ICatalog_releaseInstance(instancePtr);
                    instancePtr = new System.Runtime.InteropServices.HandleRef(null, IntPtr.Zero);
                }
                GC.SuppressFinalize(this);
            }
        }

        public List<StarTycho> cstycho2(string catalogPath, double ra, double dec, double radius, double magMin, double magMax)
        {
            IntPtr starListPtr = ICatalog.ICatalog_cstycho2(instancePtr, catalogPath, ra, dec, radius, magMin, magMax);
            if (PendingError.Pending) throw PendingError.Retrieve();
            List<StarTycho> starList = new List<StarTycho>();
            IntPtr nextStarListPtr = starListPtr;
            while (nextStarListPtr != IntPtr.Zero ) {
                StarTychoList nextStarList = new StarTychoList();
                Marshal.PtrToStructure(nextStarListPtr, nextStarList);
                starList.Add(nextStarList.star);
                nextStarListPtr = nextStarList.nextStarList;
            }
            ICatalog.ICatalog_releaseListOfStarTycho(instancePtr, starListPtr);
            return starList;
        }

    }

}






