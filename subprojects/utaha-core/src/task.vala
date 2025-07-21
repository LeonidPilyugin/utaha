using Toml;

namespace Utaha.Core
{
    public sealed class TaskData : Serializable, ITomlable
    {
        public Id id { get; private set; }
        public string alias { get; private set; }
        public string comment { get; private set; }

        public TaskData(Id id, string alias, string comment)
        {
            this.id = id;
            this.alias = alias;
            this.comment = comment;
        }

        public override void init() throws SerializationError
        {
            base.init();
            try
            {
                node.touch_file("taskdata.toml");
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
                Element doc = new Parser(node.read_file("taskdata.toml")).parse();
                id = Id.from_string(doc["id"].as<string>());
                alias = doc["alias"].as<string>();
                comment = doc["comment"].as<string>();
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not load: $(e.message)"
                );
            } catch (TomlError e)
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
                doc["id"] = new Element(id.uuid);
                doc["alias"] = new Element(alias);
                doc["comment"] = new Element(comment);

                node.write_file("taskdata.toml", writer.write(doc));
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

        protected override void init_toml(Element element) throws TomlableError
        {
            try
            {
                id = Id.generate();
                alias = element["alias"].as<string>();
                comment = element["comment"].as<string>();
            } catch (TomlError e)
            {
                throw new TomlableError.TOML_ERROR(e.message);
            }
        }
    }

    public sealed class Task : Serializable, ITomlable
    {
        public TaskData taskdata { get; private set; }
        public Backend backend { get; private set; }
        public Wrapper wrapper { get; private set; }
        private StorageNode? _node;

        public Task()
        {
            taskdata = null;
            backend = null;
            wrapper = null;
            node = null;
        }

        public override StorageNode? node
        {
            get { return _node; }
            set
            {
                _node = value;
                if (taskdata != null) taskdata.node = node == null ? null : node.subnode("taskdata");
                if (backend != null) backend.node = node == null ? null : node.subnode("backend");
                if (wrapper != null) wrapper.node = node == null ? null : node.subnode("wrapper");
            }
        }

        public override void init() throws SerializationError
        {
            base.init();
            backend.init();
            wrapper.init();
            taskdata.init();
        }

        public override void load() throws SerializationError
        {
            try
            {
                backend = Serializable.load_from<Backend>(node.subnode("backend"));
                wrapper = Serializable.load_from<Wrapper>(node.subnode("wrapper"));
                taskdata = Serializable.load_from<TaskData>(node.subnode("taskdata"));
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(e.message);
            }
        }

        public override void dump() throws SerializationError
        {
            backend.dump();
            wrapper.dump();
            taskdata.dump();
            base.dump();
        }

        public void submit() throws BackendError
        {
            backend.submit(taskdata.id);
        }

        public void start() throws BackendError
        {
            backend.submit(taskdata.id);
        }

        public void stop() throws BackendError
        {
            backend.cancel(taskdata.id);
        }

        public override void remove() throws SerializationError
        {
            backend.remove();
            wrapper.remove();
            taskdata.remove();
            base.remove();
        }

        public TaskStatus status() throws BackendError
        {
            return new TaskStatus(taskdata, backend.status(taskdata.id), wrapper.status());
        }

        protected void init_toml(Element element) throws TomlableError
        {
            try
            {
                taskdata = ITomlable.load_toml<TaskData>(element["taskdata"]);
                backend = ITomlable.load_toml<Backend>(element["backend"]);
                wrapper = ITomlable.load_toml<Wrapper>(element["wrapper"]);
            } catch (TomlError e)
            {
                throw new TomlableError.TOML_ERROR(e.message);
            }
        }
    }

    public sealed class TaskStatus : Status
    {
        public TaskData taskdata { get; private set; }
        public BackendStatus backend_status { get; private set; }
        public WrapperStatus wrapper_status { get; private set; }

        internal TaskStatus(TaskData taskdata, BackendStatus backend_status, WrapperStatus wrapper_status)
        {
            this.taskdata = taskdata;
            this.backend_status = backend_status;
            this.wrapper_status = wrapper_status;
        }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            ht.insert("id", taskdata.id.uuid);
            ht.insert("alias", taskdata.alias);
            ht.insert("comment", taskdata.comment);

            var bht = backend_status.as_hash_table();
            foreach (unowned string key in bht.get_keys())
                ht.insert("backend-" + key, bht.get(key));

            var wht = wrapper_status.as_hash_table();
            foreach (unowned string key in wht.get_keys())
                ht.insert("wrapper-" + key, wht.get(key));

            return ht;
        }
    }
}
