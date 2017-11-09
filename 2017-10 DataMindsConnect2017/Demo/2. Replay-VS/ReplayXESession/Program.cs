using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using Microsoft.SqlServer.XEvent.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Configuration;
using Microsoft.SqlServer.Management.Common;



namespace ReplayXESession
{
    class Program
    {
           
        static string XECaptureServer = ConfigurationSettings.AppSettings["XECaptureServer"];
        static string XEReplayServer = ConfigurationSettings.AppSettings["XEReplayServer"];

        static List<string> CommandFilters = new List<string>();
        static List<string> DatabaseList = new List<string>();

        static string CaptureServerConnectionString = "Integrated Security=true;Initial Catalog=master;server=" + XECaptureServer;
        static string ReplayServerConnectionString = "Integrated Security=true;Initial Catalog=master;server=" + XEReplayServer;

        static void Main(string[] args)
        {
            try
            {

                string sqlScript;
                SqlDataReader reader;
                SqlCommand sqlCommand;

                //create the XE session on the server where the events should be captured
                using (SqlConnection sqlConnection = new SqlConnection(CaptureServerConnectionString))
                {
                    sqlConnection.Open();

                    using (SqlCommand cmd = sqlConnection.CreateCommand())
                    {
                        cmd.CommandText = "EXEC master.dbo.CreateXERMLCapture";
                        cmd.ExecuteNonQuery();
                    }

                    //start the XE session if not started
                    try
                    {
                        using (SqlCommand cmd = sqlConnection.CreateCommand())
                        {
                            cmd.CommandText = "ALTER EVENT SESSION XERMLCapture ON SERVER STATE = START";
                            cmd.ExecuteNonQuery();
                        }
                    }
                    catch (SqlException)
                    {
                        //Ignore
                    }
                }

                //read and populate list of online available databases on the replay server
                using (SqlConnection sqlConnection = new SqlConnection(ReplayServerConnectionString))
                {
                    sqlCommand = new SqlCommand();
                    sqlCommand.CommandType = CommandType.Text;
                    sqlCommand.Connection = sqlConnection;
                    sqlConnection.Open();
                    sqlCommand.CommandText = "SELECT NAME FROM sys.databases WHERE state = 0";
                    reader = sqlCommand.ExecuteReader();
                    while (reader.Read())
                    {
                        DatabaseList.Add(reader[0].ToString());
                    }
                }

                ProcessEvents();

            }

            catch (Exception ex)
            {
                Logger log = new Logger();
                log.WriteErrorLog(ex.ToString());
            }

        }

        static void ProcessEvents()
        {
            QueryableXEventData eventstream = new QueryableXEventData(
                @"Data Source = "+XECaptureServer+"; Initial Catalog = master; Integrated Security = SSPI", 
                "XERMLCapture",
                EventStreamSourceOptions.EventStream,
                EventStreamCacheOptions.DoNotCache);

            foreach (PublishedEvent evt in eventstream)
            {
                ReplaySingleEvent(evt);
            }
        }

 

        public static void ReplaySingleEvent(PublishedEvent evt)
        {
            string commandText = "", dbName = "";
            SqlCommand sqlCommand;
            if (evt != null)
            {
                dbName = evt.Actions["database_name"].Value.ToString();

                if (evt.Name == "rpc_completed")
                    commandText = evt.Fields["statement"].Value.ToString();
                else if (evt.Name == "sql_batch_completed")
                    commandText = evt.Fields["batch_text"].Value.ToString();

                Console.WriteLine(Ellipsis(commandText));

                if ((dbName != "") && (commandText != ""))
                {
                    if (DatabaseList.FindIndex(x => x.Equals(dbName, StringComparison.OrdinalIgnoreCase)) != -1)
                    {
                        using (SqlConnection sqlConnection = new SqlConnection(ReplayServerConnectionString))
                        {
                            sqlCommand = new SqlCommand();
                            sqlCommand.CommandText = commandText;
                            sqlCommand.Connection = sqlConnection;
                            sqlConnection.Open();
                            sqlConnection.ChangeDatabase(dbName);
                            sqlCommand.ExecuteNonQuery();
                        }
                    }
                }
            }
        }

        private static string Ellipsis(string commandText)
        {
            String returnValue = commandText;
            if (returnValue != null)
            {
                if (returnValue.Length > 77)
                {
                    returnValue = returnValue.Substring(0, 77) + "...";
                }

            }
            return DateTime.Now.ToString("s") + " " + returnValue;
        }
    }
}
