// abcatalog_test.cs
// abcatalog astrobrick sample tests

using System;
using System.Collections.Generic;  // for List

namespace console_test
{
    class ABCatalog_test
    {
        public static void test_tycho2()
        {
            Console.WriteLine("\n");
            Console.WriteLine("-------------------------------------------------------------------------------");
            Console.WriteLine("abcatalog_test   test_tycho2");
            Console.WriteLine("-------------------------------------------------------------------------------");

            try
            {
                // create a catalog instance
                ABCatalog.Catalog catalog = new ABCatalog.Catalog();

                // set tycho catalog path
                string catalogFolder;
                if (System.Environment.OSVersion.Platform == PlatformID.Unix || System.Environment.OSVersion.Platform == PlatformID.MacOSX)
                {
                    // Linux default path= ~home/.audela/catalog/TYCHO-2
                    string homePath = System.Environment.GetFolderPath(System.Environment.SpecialFolder.Personal);
                    catalogFolder = System.IO.Path.Combine(homePath, ".audela/catalog");
                }
                else
                {
                    // Windows default path: USER_APPDATA\AudeLA\catalog\TYCHO-2
                    string homePath = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData);
                    catalogFolder = System.IO.Path.Combine(homePath, "AudeLA/catalog");
                }

                string tychoFolder = System.IO.Path.Combine(catalogFolder, "TYCHO-2");

                // get stars
                double ra = 1;
                double dec = 0;
                double radius = 11;
                double magMin = -99;
                double magMax = 99;
                Console.WriteLine("catalog.cstycho2( {0}, {1}, {2}, {3}, {4}, {5} ) \n", tychoFolder, ra, dec, radius, magMin, magMax);
                List<ABCatalog.StarTycho> starList = catalog.cstycho2(tychoFolder, ra, dec, radius, magMin, magMax);

                for (int i = 0; i < starList.Count; i++)
                {
                    ABCatalog.StarTycho star = starList[i];
                    // display stars
                    Console.WriteLine("star " + i + "\n"
                    + "ra                       " + star.ra + "\n"
                    + "dec                      " + star.dec + "\n"
                    + "pmRa                     " + star.pmRa + "\n"
                    + "pmDec                    " + star.pmDec + "\n"
                    + "errorPmRa                " + star.errorPmRa + "\n"
                    + "errorPmDec               " + star.errorPmDec + "\n"
                    + "meanEpochRA              " + star.meanEpochRA + "\n"
                    + "meanEpochDec             " + star.meanEpochDec + "\n"
                    + "goodnessOfFitRa          " + star.goodnessOfFitRa + "\n"
                    + "goodnessOfFitDec         " + star.goodnessOfFitDec + "\n"
                    + "goodnessOfFitPmRa        " + star.goodnessOfFitPmRa + "\n"
                    + "goodnessOfFitPmDec       " + star.goodnessOfFitPmDec + "\n"
                    + "magnitudeB               " + star.magnitudeB + "\n"
                    + "errorMagnitudeB          " + star.errorMagnitudeB + "\n"
                    + "magnitudeV               " + star.magnitudeV + "\n"
                    + "errorMagnitudeV          " + star.errorMagnitudeV + "\n"
                    + "observedRa               " + star.observedRa + "\n"
                    + "observedDec              " + star.observedDec + "\n"
                    + "epoch1990Ra              " + star.epoch1990Ra + "\n"
                    + "epoch1990Dec             " + star.epoch1990Dec + "\n"
                    + "errorObservedRa          " + star.errorObservedRa + "\n"
                    + "errorObservedDec         " + star.errorObservedDec + "\n"
                    + "correlationRaDec         " + star.correlationRaDec + "\n"
                    + "id                       " + star.id + "\n"
                    + "idTycho1                 " + star.idTycho1 + "\n"
                    + "idTycho2                 " + star.idTycho2 + "\n"
                    + "numberOfUsedPositions    " + star.numberOfUsedPositions + "\n"
                    + "errorRa                  " + star.errorRa + "\n"
                    + "errorDec                 " + star.errorDec + "\n"
                    + "proximityIndicator       " + star.proximityIndicator + "\n"
                    + "hipparcosId              " + star.hipparcosId + "\n"
                    + "isTycho1Star             " + star.isTycho1Star + "\n"
                    + "idTycho3                 " + star.idTycho3 + "\n"
                    + "pflag                    " + star.pflag + "\n"
                    + "solutionType             " + star.solutionType + "\n"
                    + "componentIdentifierHIP	" + star.componentIdentifierHIP + "\n"
                    );
                }


            }
            catch (ABCatalog.Error exception)
            {
                Console.WriteLine("ERROR Ilibcatalog : code=" + exception.code + " message=" + exception.Message);
            }

            // wait for hit return key
            Console.WriteLine(" hit return key...");
            Console.ReadLine();
        }
    }
}
