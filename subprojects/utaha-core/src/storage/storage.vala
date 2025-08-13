namespace Utaha.Core
{
    public sealed class Storage : Object, Gee.Traversable<Task>, Gee.Iterable<Task>
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

        private class Iterator : Object, Gee.Traversable<Task>, Gee.Iterator<Task>
        {
            private Id[] ids;
            private int index;
            private Storage storage;

            public Iterator(List<string> ids) throws IdError, StorageError
            {
                this.ids = new Id[ids.length()];
                int i = 0;
                foreach (unowned var id in ids)
                    this.ids[i++] = Id.from_string(id);
                index = -1;
                storage = Storage.get_storage();
            }

            public bool read_only { get { return true; } }

            public bool valid
            {
                get
                {
                    return index >= 0 && index < ids.length;
                }
            }

            public Task get()
            {
                try
                {
                    return storage.get_task(ids[index]);
                } catch (StorableError e)
                {
                    assert_not_reached();
                } catch (StorageError e)
                {
                    assert_not_reached();
                }
            }

            public bool has_next()
            {
                return index + 1 < ids.length;
            }

            public bool next()
            {
                index++;
                return valid;
            }

            public void remove() { }

            public bool @foreach(Gee.ForallFunc<Task> f)
            {
                bool result = true;
                while (next())
                    if (!(result &= f(get()))) break;
                return result;
            }
        }

        public Gee.Iterator<Task> iterator()
        {
            try
            {
                return new Iterator(node.list_children());
            } catch (StorageNodeError e)
            {
                assert_not_reached();
            } catch (IdError e)
            {
                assert_not_reached();
            }
        }

        public bool @foreach(Gee.ForallFunc<Task> f)
        {
            return iterator().@foreach(f);
        }
    }
}
