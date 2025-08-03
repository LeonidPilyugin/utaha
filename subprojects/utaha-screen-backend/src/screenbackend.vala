namespace Utaha.ScreenBackend
{
    public sealed class BackendHealthReport : Utaha.Core.BackendHealthReport
    {
        public string? screen_path { get; private set; }

        public BackendHealthReport()
        {
            screen_path = Environment.find_program_in_path("screen");

            string message = screen_path == null ?
                "Could not find screen executable in $PATH" :
                "OK";

            bool ok = screen_path != null;
            base(ok, message);
        }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            ht.insert("screen-path", screen_path);
            return ht;
        }
    }

    public sealed class BackendStatus : Utaha.Core.BackendStatus
    {
        private int? pid;
        private Utaha.Core.Id? id;

        public int? get_pid()
        {
            return pid;
        }

        public BackendStatus(bool active, int? pid, Utaha.Core.Id? id)
        {
            backend_type = typeof(Backend);
            this.pid = pid;
            this.id = id;
            this.active = active;
        }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            if (pid != null) ht.insert("pid", pid.to_string());
            if (id != null) ht.insert("id", id.uuid);
            return ht;
        }
    }

    public sealed class Backend : Utaha.Core.Backend
    {
        private Utaha.Core.Id? id = null;

        public override void init() throws Utaha.Core.StorableError
        {
            base.init();
            try
            {
                node?.touch_file("log");
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.StorableError.STORAGE_ERROR(
                    @"Could not initialize storage node: $(e.message)"
                );
            }
        }

        public override void load() throws Utaha.Core.StorableError
        {
            try
            {
                base.load();
                if (node.file_exists("id"))
                    id = Utaha.Core.Id.from_string(
                        node.read_file("id")
                    );
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.StorableError.ERROR(e.message);
            } catch (Utaha.Core.IdError e)
            {
                throw new Utaha.Core.StorableError.ERROR(e.message);
            }
        }

        public override void dump() throws Utaha.Core.StorableError
        {
            base.dump();
            if (null != this.id)
                node.write_file("id", id.uuid);
        }

        public override Utaha.Core.BackendHealthReport healthcheck()
        {
            return new BackendHealthReport();
        }

        public override void _submit(string[] command) throws Utaha.Core.BackendError
        {
            try
            {
                id = Utaha.Core.Id.generate();
                Screen.get_instance().submit(id.uuid, command, node.build("log"));
            } catch (ScreenError e)
            {
                throw new Utaha.Core.BackendError.ERROR(@"Failed to submit process: $(e.message)");
            }
        }

        public override void _cancel() throws Utaha.Core.BackendError
        {
            try
            {
                Screen.get_instance().cancel(id.uuid);
            } catch (ScreenError e)
            {
                throw new Utaha.Core.BackendError.ERROR(@"Failed to cancel process: $(e.message)");
            }
        }

        public override Utaha.Core.BackendStatus status() throws Utaha.Core.BackendError
        {
            Session? session;
            try
            {
                session = null == id ? new Session(null, null) : Screen.get_instance().find_session(id.uuid);
            } catch (ScreenError e)
            {
                throw new Utaha.Core.BackendError.ERROR(@"Falied to find session: $(e.message)");
            }

            return new BackendStatus(session.get_pid() != null, session.get_pid(), id);
        }

        protected override void init_json(Json.Object object) throws Utaha.Core.JsonableError { }
    }
}

[ModuleInit]
public static void plugin_init(GLib.TypeModule type_module) { }
