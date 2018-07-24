using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
// Add a reference to C:\Program Files\Microsoft SQL Server\110\Shared\Microsoft.SqlServer.XEvent.Linq.dll for x64 architecture
// or C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Microsoft.SqlServer.XEvent.Linq.dll for x86 architecture.
// and then use the namespace.
using Microsoft.SqlServer.XEvent.Linq;

namespace XeReader_BlogDemo_CTP3
{
    class Program
    {
        /// <summary>
        /// This function will iterate through every event in a set of files from a directory
        /// and return the event name followed by the list of fields and action and their
        /// values for the event.
        /// </summary>
        /// <param name="args"></param>                
        static void Main(string[] args)
        {
            // Create an instance of the enumerable object using a set of XEL files as the source.
            QueryableXEventData events = 
                new QueryableXEventData(@"C:\Temp\*.xel");

            // Iterate through each event in the file.
            foreach (PublishedEvent evt in events)
            {
                // Optionally you can check for specific events rather than respond to each event.
                // Obviously this is going to run for everything. 
                if (evt.Name == evt.Name)
                {
                    // List the event name
                    Console.WriteLine(evt.Name);

                    // Iterate through each field in the current event and return its name and value.
                    foreach (PublishedEventField fld in evt.Fields)
                    {
                        Console.WriteLine("\tField: {0} = {1}", fld.Name, fld.Value);

                        // Optionally take an action if you find a specific field.
                        if (fld.Value.ToString() == "foo")
                        {
                            // Add really important code here.
                        }
                    }

                    // Iterate through each action in thecurrent event and return its name and value.
                    foreach (PublishedAction act in evt.Actions)
                    {
                        Console.WriteLine("\tAction: {0} = {1}", act.Name, act.Value);
                    } 
                }

                
            }

            Console.Read();
        }
    }
}
