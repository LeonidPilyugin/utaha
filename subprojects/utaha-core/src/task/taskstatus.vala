namespace Utaha.Core
{

    public sealed class TaskStatus : Status
    {
        public TaskData taskdata { get; private set; }
        public BackendStatus backend_status { get; private set; }
        public WrapperStatus wrapper_status { get; private set; }
        public string stdout_path { get; private set; }
        public string stderr_path { get; private set; }

        internal TaskStatus(
            TaskData taskdata,
            BackendStatus backend_status,
            WrapperStatus wrapper_status,
            string stdout_path,
            string stderr_path
        )
        {
            this.taskdata = taskdata;
            this.backend_status = backend_status;
            this.wrapper_status = wrapper_status;
            this.stderr_path = stderr_path;
            this.stdout_path = stdout_path;
        }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            ht.insert("id", taskdata.id.uuid);
            ht.insert("alias", taskdata.alias);
            ht.insert("comment", taskdata.comment);
            ht.insert("birth date", taskdata.load_date.to_string());

            var bht = backend_status.as_hash_table();
            foreach (unowned string key in bht.get_keys())
                ht.insert("backend-" + key, bht.get(key));

            var wht = wrapper_status.as_hash_table();
            foreach (unowned string key in wht.get_keys())
                ht.insert("wrapper-" + key, wht.get(key));

            return ht;
        }
    }
}
