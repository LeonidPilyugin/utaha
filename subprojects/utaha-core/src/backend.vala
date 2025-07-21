using Toml;

namespace Utaha.Core
{
    public errordomain BackendError
    {
        ERROR,
    }

    public abstract class Backend : Serializable, ITomlable
    {
        public abstract BackendHealthReport healthcheck();

        public void submit(Id id) throws BackendError
        {
            if (this.status(id).active)
                throw new BackendError.ERROR("Is already active");
            string[] cmd = { "utaha-daemon", id.uuid };
            this._submit(id, cmd);
        }

        protected abstract void _submit(Id id, string[] command) throws BackendError;

        public void cancel(Id id) throws BackendError
        {
            if (!this.status(id).active)
                throw new BackendError.ERROR("Is not active");
            this._cancel(id);
        }

        protected abstract void _cancel(Id id) throws BackendError;

        public abstract BackendStatus status(Id id) throws BackendError;

        protected abstract void init_toml(Element element) throws TomlableError;
    }

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

    [Immutable]
    public abstract class BackendStatus : Status
    {
        public bool active { get; protected set; }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            ht.insert("active", active.to_string());
            return ht;
        }
    }
}
