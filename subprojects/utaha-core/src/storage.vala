namespace Utaha.Core
{
    public errordomain SerializationError
    {
        TYPE_ERROR,
        STORAGE_ERROR,
        ERROR,
    }

    public abstract class Serializable : Object
    {
        public virtual StorageNode? node { get; set; }

        public virtual void load() throws SerializationError { }

        public virtual void dump() throws SerializationError { }

        public virtual void init() throws SerializationError
        {
            try
            {
                node?.write_file("type", this.get_type().name());
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not initialize storage node: $(e.message)"
                );
            }
        }

        public virtual void remove() throws SerializationError
        {
            try
            {
                node?.remove();
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not remove storage node: $(e.message)"
                );
            }
        }

        public static T load_from<T>(StorageNode node)
            throws SerializationError, StorageNodeError
        {
            var type = typeof(T);
            var typename = node.read_file("type");
            var ttype = Type.from_name(typename);

            if (0 == ttype)
                throw new SerializationError.TYPE_ERROR(
                    @"Could not create object of type $typename"
                );

            if (!type.is_a(typeof(Serializable)))
                throw new SerializationError.TYPE_ERROR(
                    @"The type $(type.name()) is not instance of Serializable"
                );
            if (!ttype.is_a(type))
                throw new SerializationError.TYPE_ERROR(
                    @"The type $(type.name()) is not $(ttype.name())"
                );

            var obj = Object.new(ttype);

            Serializable result = (Serializable) obj;
            result.node = node;

            result.load();

            return result;
        }
    }

    public errordomain StorageNodeError
    {
        FS_ERROR,
    }

    public sealed class StorageNode
    {
        public string path { get; private set; }
        private File file { get; set; }

        public StorageNode(string path) throws StorageNodeError
        {
            this.path = path;
            file = File.new_for_path(path);
            if (!exists()) init();
        }

        public bool exists()
        {
            return file.query_exists();
        }

        public string build(string name)
        {
            return Path.build_filename(path, name);
        }

        private void init() throws StorageNodeError
        {
            try
            {
                file.make_directory_with_parents();
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(
                    @"Cannot create directory \"$path\": $(e.message)"
                );
            }
        }

        public void remove() throws StorageNodeError
        {
            try
            {
                // if (!file.delete())
                //     throw new StorageNodeError.FS_ERROR(
                //         @"Could not remove directory \"$path\"."
                //     );
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(
                    @"Could not remove directory \"$path\": $(e.message)"
                );
            }
        }

        public StorageNode subnode(string name) throws StorageNodeError
        {
            return new StorageNode(build(name));
        }

        public bool file_exists(string name)
        {
            return File.new_for_path(build(name)).query_exists();
        }

        public void touch_file(string name) throws StorageNodeError
        {
            try
            {
                if (!file_exists(name))
                    File.new_for_path(build(name)).create(FileCreateFlags.NONE);
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(
                    @"Could not create file \"$(build(name))\": $(e.message)"
                );
            }
        }

        public string read_file(string name) throws StorageNodeError
        {
            try
            {
                var input = new DataInputStream(File.new_for_path(build(name)).read());
                string result = input.read_line();
                string? str = input.read_line();

                while (str != null)
                {
                    result = @"$result\n$str";
                    str = input.read_line();
                }

                return result;
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(
                    @"Could not read file \"$(build(name))\": $(e.message)"
                );
            }
        }

        public void write_file(string name, string content) throws StorageNodeError
        {
            touch_file(name);
            try
            {
                var output = File.new_for_path(build(name)).open_readwrite().output_stream as FileOutputStream;
                ssize_t written = 0;
                while (written < content.data.length)
                    written += output.write(content.data[written:]);
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(
                    @"Could not write to file \"$(build(name))\": $(e.message)"
                );
            }
        }
    }

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
