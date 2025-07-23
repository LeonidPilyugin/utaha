namespace Utaha.Core
{
    public sealed class Storage
    {
        private StorageNode node;
        private static Storage? storage = null;

        private Storage(string path) throws StorageError
        {
            try
            {
                node = new StorageNode(path);
            } catch (StorageNodeError e)
            {
                throw new StorageError.ERROR(e.message);
            }
        }

        public static Storage get_storage() throws StorageError
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

        public List<Task> list_tasks() throws StorageError, StorableError
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
                throw new StorageError.ERROR(e.message);
            } catch (IdError e)
            {
                throw new StorageError.ERROR(e.message);
            }
            return result;
        }

        public bool has_node(Id id)
        {
            return node.file_exists(id.uuid);
        }

        public StorageNode create_node(Id id) throws StorageError
        {
            if (has_node(id))
                throw new StorageError.ERROR(@"Node $(id.uuid) exists");
            try
            {
                return node.subnode(id.uuid);
            } catch (StorageNodeError e)
            {
                throw new StorageError.ERROR(e.message);
            }
        }

        public StorageNode get_node(Id id) throws StorageError
        {
            if (!has_node(id))
                throw new StorageError.ERROR(@"Node $(id.uuid) does not exist");
            try
            {
                return node.subnode(id.uuid);
            } catch (StorageNodeError e)
            {
                throw new StorageError.ERROR(e.message);
            }
        }

        public Task get_task(Id id) throws StorageError, StorableError
        {
            try
            {
                return Storable.load_from<Task>(get_node(id));
            } catch (StorageNodeError e)
            {
                throw new StorageError.ERROR(e.message);
            }
        }

        public delegate void TaskFunction (Task task);

        public void @foreach(TaskFunction func) throws StorageError, StorableError
        {
            try
            {
                foreach (unowned string name in node.list_children())
                    func(get_task(Id.from_string(name)));
            } catch (IdError e)
            {
                throw new StorageError.ERROR(e.message);
            } catch (StorageNodeError e)
            {
                throw new StorageError.ERROR(e.message);
            }
        }
    }
}
