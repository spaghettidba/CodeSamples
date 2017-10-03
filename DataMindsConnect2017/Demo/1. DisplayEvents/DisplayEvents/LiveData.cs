using Microsoft.SqlServer.XEvent.Linq;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;


namespace DisplayEvents
{
    public partial class LiveData : Form
    {
        private Thread XEStreamReader;

        public LiveData()
        {
            InitializeComponent();

        }


        private void InitializeXESession()
        {
            string ConnectionString = @"Integrated Security=SSPI;Initial Catalog=master;Data Source=(local)\SQL2014";
            QueryableXEventData eventstream = new QueryableXEventData(
                ConnectionString, 
                "XERMLCapture",
                EventStreamSourceOptions.EventStream,
                EventStreamCacheOptions.DoNotCache);
            foreach (PublishedEvent evt in eventstream)
            {
                this.Invoke((MethodInvoker)delegate() { AddRow(evt); });
            }
        }


        private void AddRow(PublishedEvent evt)
        {

            int idx = dataGridView1.Rows.Add();
            DataGridViewRow newRow = dataGridView1.Rows[idx];
            newRow.Cells[0].Value = evt.Name;
            newRow.Cells[1].Value = evt.Timestamp;
            newRow.Tag = evt;

            //scroll to last row
            dataGridView1.FirstDisplayedScrollingRowIndex = dataGridView1.RowCount - 1;


        }

        private void LiveData_Load(object sender, EventArgs e)
        {
           XEStreamReader = new Thread(InitializeXESession);
           XEStreamReader.Start();

        }

        private void LiveData_FormClosing(object sender, FormClosingEventArgs e)
        {
            XEStreamReader.Abort();
        }



        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            // Display detail information
            dataGridView2.Rows.Clear();

            PublishedEvent evt = (PublishedEvent)dataGridView1.Rows[e.RowIndex].Tag;
            

            foreach (PublishedEventField fld in evt.Fields)
            {
                int idx = dataGridView2.Rows.Add();
                DataGridViewRow newRow = dataGridView2.Rows[idx];
                newRow.Cells[0].Value = fld.Name;
                newRow.Cells[1].Value = fld.Value;
            }
            foreach (PublishedAction act in evt.Actions)
            {
                int idx = dataGridView2.Rows.Add();
                DataGridViewRow newRow = dataGridView2.Rows[idx];
                newRow.Cells[0].Value = act.Name;
                newRow.Cells[1].Value = act.Value;
            }
        }

       
    }
}
