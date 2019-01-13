// absimple_test.cs
// absimple astrobrick sample tests

using System;

namespace console_test
{
    class absimple_test
    {
        public static void test_1()
        {
            Console.WriteLine("\n");
            Console.WriteLine("-------------------------------------------------------------------------------");
            Console.WriteLine("absimple_test   test_1");
            Console.WriteLine("-------------------------------------------------------------------------------");
            int a = 8;
            int b = 4;

            int result = ABSimple.absimple_processAdd(a, b);
            Console.WriteLine("ABSimple_processAdd: " + a + " + " + b + " = " + result);

            int result2 = ABSimple.absimple_processSub(a, b);
            Console.WriteLine("ABSimple_processSub: " + a + " - " + b + " = " + result2);
        }

        public static void test_calculator()
        {
            Console.WriteLine("\n");
            Console.WriteLine("-------------------------------------------------------------------------------");
            Console.WriteLine("absimple_test   test_calculator");
            Console.WriteLine("-------------------------------------------------------------------------------");

            try
            {
                // create calculator instance
                ABSimple.Calculator calculator = new ABSimple.Calculator();
                
                double a = 8;
                double result = calculator.set(a);
                Console.WriteLine("simple.set " + a + " result= " + result);
                a = 4;
                result = calculator.add(a);
                Console.WriteLine("simple.add " + a + " result= " + result);
                a = 5;
                result = calculator.divide(a);
                Console.WriteLine("simple.divide " + a + " result= " + result);
                a = 0;
                result = calculator.divide(a);
                Console.WriteLine("simple.divide " + a + " result= " + result);
            }
            catch (ABSimple.Error exception)
            {
                Console.WriteLine("ERROR code=" + exception.code + " message=" + exception.Message);
            }

        }

        public static void test_calendar()
        {
            Console.WriteLine("\n");
            Console.WriteLine("-------------------------------------------------------------------------------");
            Console.WriteLine("absimple_test   test_calendar");
            Console.WriteLine("-------------------------------------------------------------------------------");

            // create calendar instance
            ABSimple.Calendar calendar = new ABSimple.Calendar();
                
            try
            {
                string string3 = calendar.convertIntToString(2015, 2, 1, 14, 5, 10);
                Console.WriteLine("simple.convertIntToString: " + string3);

                ABSimple.DateTime dateTimeStruct2 = calendar.convertIntToStruct(2015, 2, 1, 14, 5, 10);
                Console.WriteLine("simple.convertIntToStruct: "
                    + dateTimeStruct2.year + " " + dateTimeStruct2.month + " " + dateTimeStruct2.day
                    + " " + dateTimeStruct2.hour + " " + dateTimeStruct2.minute + " " + dateTimeStruct2.second);
                
                string dateTimeString = "2015-01-02T14:05:10";
                ABSimple.DateTime dateTimeStruct3 = calendar.convertStringToStruct(dateTimeString);
                Console.WriteLine("simple.convertStringToStruct: "
                    + dateTimeStruct3.year + " " + dateTimeStruct3.month + " " + dateTimeStruct3.day
                    + " " + dateTimeStruct3.hour + " " + dateTimeStruct3.minute + " " + dateTimeStruct3.second);
            }
            catch (ABSimple.Error exception)
            {
                Console.WriteLine("ERROR code=" + exception.code + " message=" + exception.Message);
            }


            try
            {
                ABSimple.DateTime dateTimeStruct4 = calendar.convertStringToStruct("");
                Console.WriteLine("simple.convertStringToStruct: "
                    + dateTimeStruct4.year + " " + dateTimeStruct4.month + " " + dateTimeStruct4.day
                    + " " + dateTimeStruct4.hour + " " + dateTimeStruct4.minute + " " + dateTimeStruct4.second);
            }
            catch (ABSimple.Error exception)
            {
                Console.WriteLine("ERROR code=" + exception.code + " message=" + exception.Message);
            }
            //catch (SEHException seh)
            //{
            //    Console.WriteLine("SEHException=" + seh.Message + " code=" + seh.ErrorCode + "type=" + seh.GetType());
            //}
            //catch (Exception exception)
            //{
            //    Console.WriteLine("Exception=" + exception.Message + " code=" + exception.Source + "type=" + exception.GetType());
            //} 

            // wait for hit return key
            Console.WriteLine(" hit return key...");
            Console.ReadLine();
           
        }
    }
}
