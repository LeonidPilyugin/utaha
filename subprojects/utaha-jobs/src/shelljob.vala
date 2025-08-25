namespace Utaha.Jobs
{
    public class ShellJobStatus : Utaha.Core.JobStatus
    {
        public string[] command { get; private set; }

        public ShellJobStatus(string[] command, DateTime? last_active)
        {
            job_type = typeof(ShellJob);
            this.command = command;
            this.last_active = last_active;
        }

        public override Utaha.Core.Status.Iterable iter
        {
            owned get
            {
                return base.iter
                    .set<string>(new Utaha.Core.Status.Iterable.Key.str("command"), string.joinv(" ", command));
            }
        }
    }

    public class ShellJob : Utaha.Core.Job
    {
        private string[] command;
        private DateTime? last_active = null;
        private SubprocessLauncher launcher = null;
        private Subprocess process = null;
        private bool exited = false;

        public async override void start()
        {
            try
            {
                process = launcher.spawnv(command);
                yield process.wait_async();
                exited = true;
            } catch (Error e)
            {
                assert_not_reached();
            }
        }

        public override void stop()
        {
            process.force_exit();
            exited = true;
        }

        public override Utaha.Core.JobStatus status()
        {
            return new ShellJobStatus(
                command,
                last_active
            );
        }

        protected override void _initialize(Utaha.Core.Serialization.TableElement element) throws Utaha.Core.Serialization.InitializableError
        {
            if (!element.contains("command"))
                throw new Utaha.Core.Serialization.InitializableError.ERROR(@"Does not have \"command\" member");
            if (element.get<Utaha.Core.Serialization.Element>("command").get_type() != typeof(Utaha.Core.Serialization.ArrayElement))
                throw new Utaha.Core.Serialization.InitializableError.ERROR(@"Member \"command\" is not an array");

            var command = element.get<Utaha.Core.Serialization.ArrayElement>("command");
            this.command = new string[command.length];

            for (uint i = 0; i < command.length; i++)
                this.command[i] = command.get<Utaha.Core.Serialization.ValueElement>(i).as<string>();

            last_active = null;
        }

        public override void init() throws Utaha.Core.StorableError
        {
            base.init();
            try
            {
                node.touch_file("job.json");
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
                var element = new Utaha.Core.Serialization.JsonReader().read(node.read_file("job.json")) as Utaha.Core.Serialization.TableElement;
                _initialize(element);

                if (!element.contains("last_active"))
                    last_active = null;
                else
                    last_active = new DateTime.from_unix_local(element.get<Utaha.Core.Serialization.ValueElement>("last_active").as<int64?>());

                launcher = new SubprocessLauncher(GLib.SubprocessFlags.NONE);
                launcher.set_environ(Environ.get());
                launcher.set_stdout_file_path(node.build("stdout"));
                launcher.set_stderr_file_path(node.build("stderr"));
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.StorableError.STORAGE_ERROR(e.message);
            } catch (Utaha.Core.Serialization.InitializableError e)
            {
                throw new Utaha.Core.StorableError.ERROR(e.message);
            } catch (Error e)
            {
                throw new Utaha.Core.StorableError.ERROR(e.message);
            }
        }

        public override void dump() throws Utaha.Core.StorableError
        {
            try
            {
                Json.Builder builder = new Json.Builder();
                builder.begin_object();

                builder.set_member_name("command");
                builder.begin_array();
                foreach (unowned string str in command)
                    builder.add_string_value(str);
                builder.end_array();

                if (null != last_active)
                {
                    builder.set_member_name("last_active");
                    builder.add_int_value(last_active.to_unix());
                }

                builder.end_object();

                Json.Generator generator = new Json.Generator();
                Json.Node root = builder.get_root();
                generator.set_root(root);

                node.write_file("job.json", generator.to_data(null));
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.StorableError.STORAGE_ERROR(
                    @"Could not dump: $(e.message)"
                );
            }
        }
    }
}

[ModuleInit]
public static void plugin_init(GLib.TypeModule type_module) { }
