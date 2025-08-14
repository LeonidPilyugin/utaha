namespace Utaha.PosixBackend
{
    // public sealed class BackendHealthReport : Utaha.Core.BackendHealthReport
    // {
    //     public BackendHealthReport()
    //     {
    //         base(true, "OK");
    //     }
    // }

    public sealed class BackendStatus : Utaha.Core.BackendStatus
    {

        public long? pid { get; private set; }

        public BackendStatus(bool active, long? pid)
        {
            backend_type = typeof(Backend);
            this.pid = pid;
            this.active = active;
        }

        public override Utaha.Core.Status.Iterable iter
        {
            owned get
            {
                return base.iter
                    .set<string>(new Utaha.Core.Status.Iterable.Key.str("pid"), pid == null ? "" : pid.to_string());
            }
        }
    }

    public sealed class Backend : Utaha.Core.Backend
    {
        private long? pid = null;

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
                if (node.file_exists("pid"))
                    pid = long.parse(node.read_file("pid"));
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.StorableError.ERROR(e.message);
            }
        }

        public override void dump() throws Utaha.Core.StorableError
        {
            base.dump();
            if (null != this.pid)
                node.write_file("pid", pid.to_string());
        }

        // public override Utaha.Core.BackendHealthReport healthcheck()
        // {
        //     return new BackendHealthReport();
        // }

        public override void _submit(string[] command) throws Utaha.Core.BackendError
        {
            var pid = Posix.fork();

            if (node.file_exists("finished"))
                node.remove_file("finished");

            if (0 == pid)
            {
                var cmd = string.joinv(" ", command);
                Process.spawn_command_line_sync(cmd);
                node.write_file("finished", new DateTime.now().to_unix().to_string());
                Posix.exit(0);
            } else
            {
                this.pid = (long) pid;
            }
        }

        public override void _cancel() throws Utaha.Core.BackendError
        {
            if (0 != Posix.kill((Posix.pid_t) pid, Posix.Signal.KILL))
                throw new Utaha.Core.BackendError.ERROR(@"Failed to kill process $pid");
        }

        public override Utaha.Core.BackendStatus status() throws Utaha.Core.BackendError
        {
            bool active = false;
            if (pid != null && !node.file_exists("finished"))
                active = 0 == Posix.kill((Posix.pid_t) pid, 0);

            return new BackendStatus(active, pid);
        }

        protected override void init_json(Json.Object object) throws Utaha.Core.JsonableError { }
    }
}

[ModuleInit]
public static void plugin_init(GLib.TypeModule type_module) { }
