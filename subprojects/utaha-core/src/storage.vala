namespace Utaha.Core
{
    public sealed class Storage
    {
        private StorageNode node;
        private static Storage? storage = null;

        private Storage(string path) throws StorageNodeError
        {
            node = new StorageNode(path);
        }

        public static Storage get_storage() throws StorageNodeError
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

        public List<Task> list_tasks() throws StorageNodeError, StorableError
        {
            Dir dir;
            var result = new List<Task>();
            try
            {
                dir = Dir.open(node.path);

                string? name = null;
                while ((name = dir.read_name()) != null)
                {
                    name = Path.get_basename(name);
                    result.append(get_task(Id.from_string(name)));
                }
            } catch (FileError e)
            {
                throw new StorageNodeError.ERROR(e.message);
            } catch (IdError e)
            {
                throw new StorageNodeError.ERROR(e.message);
            }
            return result;
        }

        public bool has_node(Id id)
        {
            return node.file_exists(id.uuid);
        }

        public StorageNode create_node(Id id) throws StorageNodeError
        {
            if (has_node(id))
                throw new StorageNodeError.ERROR(@"Node $(id.uuid) exists");
            return node.subnode(id.uuid);
        }

        public StorageNode get_node(Id id) throws StorageNodeError
        {
            if (!has_node(id))
                throw new StorageNodeError.ERROR(@"Node $(id.uuid) does not exist");
            return node.subnode(id.uuid);
        }

        public Task get_task(Id id) throws StorageNodeError, StorableError
        {
            return Storable.load_from<Task>(get_node(id));
        }

        public delegate void TaskFunction (Task task);

        public void @foreach(TaskFunction func) throws StorageNodeError, IdError, StorableError
        {
            foreach (unowned string name in node.list_children())
                func(get_task(Id.from_string(name)));
        }
    }
}
