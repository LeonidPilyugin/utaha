namespace Utaha.Core
{
    public sealed class Task : Storable, Serialization.Initializable
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

        protected void _initialize(Serialization.TableElement el) throws Serialization.InitializableError
        {
            string[] members = { "taskdata", "backend", "wrapper" };
            foreach (unowned string member in members)
            {
                if (!el.contains(member))
                    throw new Serialization.InitializableError.ERROR(@"Does not have \"$member\" member");
                if (el.get<Serialization.Element>(member).get_type() != typeof(Serialization.TableElement))
                    throw new Serialization.InitializableError.ERROR(@"Member \"$member\" does not contain object");
            }
            taskdata = Serialization.Initializable.initialize<TaskData>(el["taskdata"]);
            backend = Serialization.Initializable.initialize<Backend>(el["backend"]);
            wrapper = Serialization.Initializable.initialize<Wrapper>(el["wrapper"]);
        }
    }
}
