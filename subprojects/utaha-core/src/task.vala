namespace Utaha.Core
{
    public sealed class TaskData : Serializable, IJsonable
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
                node.touch_file("taskdata.json");
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
                var parser = new Json.Parser();
                parser.load_from_data(node.read_file("taskdata.json"));
                var object = parser.get_root().get_object();
                init_json(object);
                if (!object.has_member("id"))
                    throw new SerializationError.ERROR("Corrupted taskdata.json");
                id = Id.from_string(object.get_string_member("id"));
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(e.message);
            } catch (Error e)
            {
                throw new SerializationError.ERROR(e.message);
            }
        }

        public override void dump() throws SerializationError
        {
            try
            {
                Json.Builder builder = new Json.Builder();
                builder.begin_object();

                builder.set_member_name("id");
                builder.add_string_value(id.uuid);

                builder.set_member_name("alias");
                builder.add_string_value(alias);

                builder.set_member_name("comment");
                builder.add_string_value(comment);

                builder.end_object();

                Json.Generator generator = new Json.Generator();
                Json.Node root = builder.get_root();
                generator.set_root(root);

                node.write_file("taskdata.json", generator.to_data(null));
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not dump: $(e.message)"
                );
            }
        }

        protected override void init_json(Json.Object object) throws JsonableError
        {
            id = Id.generate();

            if (!object.has_member("alias"))
                throw new JsonableError.ERROR("Does not have \"alias\" member");
            if (!object.has_member("comment"))
                throw new JsonableError.ERROR("Does not have \"comment\" member");

            alias = object.get_string_member("alias");
            comment = object.get_string_member("comment");
        }
    }

    public sealed class Task : Serializable, IJsonable
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

        protected void init_json(Json.Object object) throws JsonableError
        {
            string[] members = { "taskdata", "backend", "wrapper" };
            foreach (unowned string member in members)
            {
                if (!object.has_member(member))
                    throw new JsonableError.ERROR(@"Does not have \"$member\" member");
                if (object.get_member(member).get_node_type() != Json.NodeType.OBJECT)
                    throw new JsonableError.ERROR(@"Member \"$member\" does not contain object");
            }
            taskdata = IJsonable.load_json<TaskData>(object.get_member("taskdata").get_object());
            backend = IJsonable.load_json<Backend>(object.get_member("backend").get_object());
            wrapper = IJsonable.load_json<Wrapper>(object.get_member("wrapper").get_object());
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
