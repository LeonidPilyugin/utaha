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

    [Immutable]
    public sealed class BackendStatus : Utaha.Core.BackendStatus
    {
        public int? pid { get; private set; }

        public BackendStatus(bool active, int? pid)
        {
            this.pid = pid;
            this.active = active;
        }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            if (pid != null) ht.insert("pid", pid.to_string());
            return ht;
        }
    }

    public sealed class Backend : Utaha.Core.Backend
    {
        private Screen screen = new Screen();

        public override void load() { }
        public override void dump() { }

        public override Utaha.Core.BackendHealthReport healthcheck()
        {
            return new BackendHealthReport();
        }

        public override void _submit(Utaha.Core.Id id, string[] command) throws Utaha.Core.BackendError
        {
            try
            {
                screen.submit(id.uuid, command);
            } catch (ScreenError e)
            {
                throw new Utaha.Core.BackendError.ERROR(@"Failed to submit process: $(e.message)");
            }
        }

        public override void _cancel(Utaha.Core.Id id) throws Utaha.Core.BackendError
        {
            try
            {
                screen.cancel(id.uuid);
            } catch (ScreenError e)
            {
                throw new Utaha.Core.BackendError.ERROR(@"Failed to cancel process: $(e.message)");
            }
        }

        public override Utaha.Core.BackendStatus status(Utaha.Core.Id id) throws Utaha.Core.BackendError
        {
            Session? session;
            try
            {
                session = screen.find_session(id.uuid);
            } catch (ScreenError e)
            {
                throw new Utaha.Core.BackendError.ERROR(@"Falied to find session: $(e.message)");
            }

            return new BackendStatus(session.pid != null, session.pid);
        }

        protected override void init_json(Json.Object object) throws Utaha.Core.JsonableError { }
    }
}

[ModuleInit]
public static void plugin_init(GLib.TypeModule type_module) { }
