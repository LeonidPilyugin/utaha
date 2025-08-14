namespace Utaha.Core
{
    public sealed class Task : Storable, IJsonable
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
                try
                {
                    _node = value;
                    if (taskdata != null) taskdata.node = node == null ? null : node.subnode("taskdata");
                    if (backend != null) backend.node = node == null ? null : node.subnode("backend");
                    if (wrapper != null) wrapper.node = node == null ? null : node.subnode("wrapper");
                } catch (StorageNodeError e)
                {
                    error(@"Unexpected error: $(e.message)");
                }
            }
        }

        public override void init() throws StorableError
        {
            base.init();
            backend.init();
            wrapper.init();
            taskdata.init();
        }

        public override void load() throws StorableError
        {
            try
            {
                backend = Storable.load_from<Backend>(node.subnode("backend"));
                wrapper = Storable.load_from<Wrapper>(node.subnode("wrapper"));
                taskdata = Storable.load_from<TaskData>(node.subnode("taskdata"));
            } catch (StorageNodeError e)
            {
                throw new StorableError.STORAGE_ERROR(e.message);
            }
        }

        public override void dump() throws StorableError
        {
            backend.dump();
            wrapper.dump();
            taskdata.dump();
            base.dump();
        }

        public void start() throws BackendError, TaskError
        {
            if (backend.status().active)
                throw new TaskError.ERROR(@"Task $(taskdata.id.uuid) is already active");
            backend.submit(taskdata.id);
            taskdata.start_date = new DateTime.now();
            dump();
        }

        public void stop() throws BackendError, TaskError
        {
            if (!backend.status().active)
                throw new TaskError.ERROR(@"Task $(taskdata.id.uuid) is not active");
            wrapper.query_stop();
        }

        public void destroy() throws BackendError, StorableError, TaskError
        {
            if (backend.status().active)
                throw new TaskError.ERROR(@"Task $(taskdata.id.uuid) is active");
            remove();
        }

        public override void remove() throws StorableError
        {
            backend.remove();
            wrapper.remove();
            taskdata.remove();
            base.remove();
        }

        public TaskStatus status() throws BackendError
        {
            return new TaskStatus(
                taskdata,
                () => {
                    return backend.status();
                },
                () => {
                    return wrapper.status();
                },
                wrapper.stdout_path,
                wrapper.stderr_path
            );
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
}
