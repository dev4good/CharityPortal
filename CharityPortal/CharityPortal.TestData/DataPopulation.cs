using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using CharityPortal.Data;

namespace CharityPortal.DataPopulation
{
    [TestClass]
    public class DataPopulation
    {
        static DataContextContainer _db;
        public TestContext TestContext { get; set; }

        [ClassInitialize]
        public static void TestStart(TestContext context)
        {
            _db = new DataContextContainer();
        }

        [ClassCleanup]
        public static void TestEnd()
        {
            _db.SaveChanges();
            _db.Dispose();
        }

        [TestMethod]
        [DataSource("System.Data.Odbc",
            @"Driver={Microsoft Excel Driver (*.xls)};DriverId=790;Dbq=dev4good_charityportal_testdata.xls;DefaultDir=.", "Tag$", DataAccessMethod.Sequential)]
        public void PopulateTags()
        {
            var t = new Tag()
            {
                Name = (string)TestContext.DataRow["Name"]
            };
            _db.AddToTags(t);
        }
    }
}
