namespace Utaha.Core
{
    public sealed class Storage
    {
        private StorageNode node;
        private static Storage? storage = null;

        private Storage(string path)
        {
            node = new StorageNode(path);
        }

        public static Storage get_storage()
        {
            if (storage == null)
            {
                string? path = Environment.get_variable("UTAHA_STORAGE_PATH");
                if (path == null)
                    path = Path.build_filename(Environment.get_home_dir(), ".utaha");
                storage = new Storage(path);
            }

            return storage;
        }

        public List<Task> list_tasks()
        {
            Dir dir;
            var result = new List<Task>();
            try
            {
                dir = Dir.open(node.path);
            } catch (FileError e)
            {
                throw new ModuleError.ERROR(e.message);
            }

            string? name = null;
            while ((name = dir.read_name()) != null)
            {
                name = Path.get_basename(name);
                result.append(get_task(Id.from_string(name)));
            }

            return result;
        }

        public StorageNode get_node(Id id)
        {
            return node.subnode(id.uuid);
        }

        public Task get_task(Id id)
        {
            return Serializable.load_from<Task>(get_node(id));
        }
    }
}
