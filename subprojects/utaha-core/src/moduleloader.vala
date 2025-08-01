namespace Utaha.Core
{
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
}
