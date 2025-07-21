namespace Utaha.DefaultWrapper
{
    public sealed class WrapperStatus : Utaha.Core.WrapperStatus
    {
        public string[] command { get; private set; }

        public WrapperStatus(string[] command)
        {
            this.command = command;
        }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            ht.set("command", string.joinv(" ", command));
            return ht;
        }
    }

    public sealed class Wrapper : Utaha.Core.Wrapper
    {
        private string[] command;
        private DateTime? last_active = null;
        private SubprocessLauncher launcher = null;
        private Subprocess process = null;

        protected override void init_json(Json.Object object) throws Utaha.Core.JsonableError
        {
            if (!object.has_member("command"))
                throw new Utaha.Core.JsonableError.ERROR(@"Does not have \"command\" member");
            if (object.get_member("command").get_node_type() != Json.NodeType.ARRAY)
                throw new Utaha.Core.JsonableError.ERROR(@"Member \"command\" is not an array");

            var command = object.get_array_member("command");
            this.command = new string[command.get_length()];

            for (uint i = 0; i < command.get_length(); i++)
                this.command[i] = command.get_string_element(i);

            last_active = null;
        }

        public override void init() throws Utaha.Core.SerializationError
        {
            base.init();
            try
            {
                node.touch_file("wrapper.json");
                node.touch_file("stdout");
                node.touch_file("stderr");
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.SerializationError.STORAGE_ERROR(
                    @"Could not initialize storage node: $(e.message)"
                );
            }
        }

        public override void load() throws Utaha.Core.SerializationError
        {
            try
            {
                var parser = new Json.Parser();
                parser.load_from_data(node.read_file("wrapper.json"));
                init_json(parser.get_root().get_object());
                launcher = new SubprocessLauncher(GLib.SubprocessFlags.NONE);
                launcher.set_environ(Environ.get());
                launcher.set_stdout_file_path(node.build("stdout"));
                launcher.set_stderr_file_path(node.build("stderr"));
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.SerializationError.STORAGE_ERROR(e.message);
            } catch (Utaha.Core.JsonableError e)
            {
                throw new Utaha.Core.SerializationError.ERROR(e.message);
            } catch (Error e)
            {
                throw new Utaha.Core.SerializationError.ERROR(e.message);
            }
        }

        public override void dump() throws Utaha.Core.SerializationError
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

                builder.end_object();

                Json.Generator generator = new Json.Generator();
                Json.Node root = builder.get_root();
                generator.set_root(root);

                node.write_file("wrapper.json", generator.to_data(null));
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.SerializationError.STORAGE_ERROR(
                    @"Could not dump: $(e.message)"
                );
            }
        }

        public override Utaha.Core.WrapperStatus status()
        {
            return new WrapperStatus(
                command
            );
        }

        public override void start()
        {
            process = launcher.spawnv(command);
        }

        public override void stop()
        {
            process.force_exit();
        }

        public override bool on_tick()
        {
            last_active = new DateTime.now();
            dump();

            return process.get_if_exited() || process.get_if_signaled();
        }

        private static void on_term(Utaha.Core.Wrapper wrapper, ProcessSignal signal)
        {
            var w = (Wrapper) wrapper;
            w.stop();
            w.dump();
        }

        public override HashTable<ProcessSignal, SignalHandlerMethod> get_signal_handlers()
        {
            var result = new HashTable<ProcessSignal, SignalHandlerMethod>(int_hash, int_equal);
            result.insert(ProcessSignal.TERM, on_term);
            return result;
        }
    }
}

[ModuleInit]
public static void plugin_init(GLib.TypeModule type_module) { }
