using Utaha.Core;
using Toml;

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

        protected override void init_toml(Element element) throws TomlableError
        {
            var command = element["command"].as_array();
            this.command = new string[command.size];

            for (int i = 0; i < command.size; i++)
                this.command[i] = command.get(i).as<string>();

            last_active = null;
        }

        public override void init() throws SerializationError
        {
            base.init();
            try
            {
                node.touch_file("wrapper.toml");
                node.touch_file("stdout");
                node.touch_file("stderr");
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not initialize storage node: $(e.message)"
                );
            }
        }

        public override void load() throws SerializationError
        {
            try
            {
                Element doc = new Parser(node.read_file("wrapper.toml")).parse();
                init_toml(doc);
                launcher = new SubprocessLauncher(GLib.SubprocessFlags.NONE);
                launcher.set_environ(Environ.get());
                launcher.set_stdout_file_path(node.build("stdout"));
                launcher.set_stderr_file_path(node.build("stderr"));
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not load: $(e.message)"
                );
            } catch (TomlableError e)
            {
                throw new SerializationError.ERROR(
                    @"TOML error: $(e.message)"
                );
            } catch (Error e)
            {
                throw new SerializationError.ERROR(
                    @"Error: $(e.message)"
                );
            }
        }

        public override void dump() throws SerializationError
        {
            try
            {
                Writer writer = new Writer();
                Element doc = new Element.table();
                var arr = new Gee.ArrayList<Element>();

                for (int i = 0; i < command.length; i++)
                    arr.insert(i, new Element(command[i]));
                var ar = new Element.array(arr);
                ar.inline = true;
                doc["command"] = ar;
                node.write_file("wrapper.toml", writer.write(doc));
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not dump: $(e.message)"
                );
            } catch (TomlError e)
            {
                throw new SerializationError.ERROR(
                    @"TOML error: $(e.message)"
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
            // string arr[1];
            // arr[0] = command;
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
