using System;
using System.Text;
using System.Runtime.InteropServices;
using System.Net;
using System.Windows.Forms;

namespace GetCookies
{
    public class Program
    {
        public static CookieContainer cookies;

        [STAThread]
        public static void Main(string[] args)
        {
            String url;

            // Retrieve the Url from the parameters or use a default.
            url = (args.Length == 1) ? args[0] : "https://btdevconsole.azurewebsites.net/";

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Run the form.
            GetCookiesForm form = new GetCookiesForm(url);
            Application.Run(form);

            cookies = form.Cookies;
        }
    }

    public class GetCookiesForm : Form
    {
        [DllImport("wininet.dll", SetLastError = true)]
        public static extern bool InternetGetCookieEx(string url, string cookieName, StringBuilder cookieData, ref int size, Int32 dwFlags, IntPtr lpReserved);

        private const Int32 InternetCookieHttponly = 0x00002000;

        private System.ComponentModel.IContainer components = null;
        private System.Windows.Forms.WebBrowser webBrowser;
        public CookieContainer Cookies { get; set; }

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.webBrowser = new System.Windows.Forms.WebBrowser();
            this.SuspendLayout();
            // 
            // webBrowser
            // 
            this.webBrowser.Dock = System.Windows.Forms.DockStyle.Fill;
            this.webBrowser.Location = new System.Drawing.Point(0, 0);
            this.webBrowser.MinimumSize = new System.Drawing.Size(20, 20);
            this.webBrowser.Name = "webBrowser";
            this.webBrowser.Size = new System.Drawing.Size(800, 450);
            this.webBrowser.TabIndex = 0;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.webBrowser);
            this.Name = "GetCookies";
            this.Text = "GetCookies";
            this.ResumeLayout(false);

        }

        public GetCookiesForm(String url)
        {
            InitializeComponent();
            webBrowser.Navigate(url);
            webBrowser.DocumentCompleted += WebBrowser_DocumentCompleted;
        }

        public void WebBrowser_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e)
        {
            Uri uri = new Uri(webBrowser.Url.ToString());

            Cookies = GetUriCookieContainer(uri);

            this.Close();
        }

        public static CookieContainer GetUriCookieContainer(Uri uri)
        {
            CookieContainer cookies = null;
            // Determine the size of the cookie
            int datasize = 8192 * 16;
            StringBuilder cookieData = new StringBuilder(datasize);
            if (!InternetGetCookieEx(uri.ToString(), null, cookieData, ref datasize, InternetCookieHttponly, IntPtr.Zero))
            {
                if (datasize < 0)
                    return null;
                // Allocate stringbuilder large enough to hold the cookie
                cookieData = new StringBuilder(datasize);
                if (!InternetGetCookieEx(
                    uri.ToString(),
                    null, cookieData,
                    ref datasize,
                    InternetCookieHttponly,
                    IntPtr.Zero))
                    return null;
            }

            if (cookieData.Length > 0)
            {
                cookies = new CookieContainer();
                cookies.SetCookies(uri, cookieData.ToString().Replace(';', ','));
            }
            return cookies;
        }
    }
}