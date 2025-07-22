namespace Utaha.Core
{
    public abstract class BackendHealthReport : Status
    {
        public bool ok { get; private set; }
        public string message { get; private set; }


        protected BackendHealthReport(bool ok, string message)
        {
            this.ok = ok;
            this.message = message;
            check_daemon();
        }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            ht.insert("ok", ok.to_string());
            ht.insert("message", message);
            return ht;
        }

        private void check_daemon()
        {
            if (null != Environment.find_program_in_path("utaha-daemon"))
            {
                ok = false;
                message = "utaha-daemon not found in $PATH";
            }
        }
    }
}
