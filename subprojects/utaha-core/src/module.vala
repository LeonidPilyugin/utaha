namespace Utaha.Core
{
    public errordomain ModuleError
    {
        ERROR,
    }

    private class Module : TypeModule
    {
        [CCode (has_target = false)]
        private delegate void PluginInitFunc (TypeModule module);
        private GLib.Module module = null;
        private string name = null;
        public string? error { get; private set; }

        public Module(string name)
        {
            this.name = name;
            error = null;
        }

        public override bool load()
        {
            module = GLib.Module.open(name, GLib.ModuleFlags.LAZY);
            if (null == module)
            {
                error = @"Module $name not found or invalid file";
                return true;
            }

            void * plugin_init = null;
            if (!module.symbol("plugin_init", out plugin_init))
            {
                error = @"Module $name does not have init function";
                return true;
            }

            ((PluginInitFunc) plugin_init)(this);

            return true;
        }

        public override void unload() {
            module = null;
        }
    }

    private sealed class ModuleLoader
    {
        private static HashTable<string, TypeModule> _modules = null;

        private static HashTable<string, TypeModule> modules
        {
            get
            {
                if (null == _modules)
                    _modules = new HashTable<string, TypeModule>(str_hash, str_equal);
                return _modules;
            }
        }

        public static List<unowned string> list_modules()
        {
            return modules.get_keys();
        }

        public static void load_module(string name) throws ModuleError
        {
            if (list_modules().index(name) >= 0) return;

            var module = new Module(name);
            module.load();

            modules.set(name, module);

            if (null != module.error)
                throw new ModuleError.ERROR(module.error);
        }

        public static void load_dir(string path) throws ModuleError
        {
            Dir dir;
            try
            {
                dir = Dir.open(path);
            } catch (FileError e)
            {
                throw new ModuleError.ERROR(e.message);
            }

            string? name = null;
            while ((name = dir.read_name()) != null)
            {
                name = Path.get_basename(name);
                load_module(Path.build_filename(path, name));
            }
        }

        public static void try_load_dir(string path)
        {
            Dir dir;
            try
            {
                dir = Dir.open(path);
            } catch (FileError e)
            {
                return;
            }

            string? name = null;
            List<uint> names = new List<uint>();
            while ((name = dir.read_name()) != null)
            {
                try
                {
                    name = Path.get_basename(name).split(".")[0];
                    if (names.index(name.hash()) >= 0) continue;
                    names.append(name.hash());
                    load_module(Path.build_filename(path, name));
                }
                // catch (ModuleError e) { warning(@"Failed $name: $(e.message)"); }
                catch (ModuleError e) { }
            }
        }

        public static void load_dirs(string[] pathes) throws ModuleError
        {
            foreach (unowned string path in pathes)
                try_load_dir(path);
        }
    }

    public static void load_modules() throws ModuleError
    {
        string path = string.join(":",
            Path.build_filename("usr", "share", "utaha", "modules"),
            Path.build_filename(Environment.get_home_dir(), ".local", "share", "utaha", "modules")
        );
        string? user_path = Environment.get_variable("UTAHA_MODULE_PATH");
        if (user_path != null)
            path = string.join(":", path, user_path);
        ModuleLoader.load_dirs(path.split(":"));
    }
}
