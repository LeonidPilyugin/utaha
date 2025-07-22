namespace Utaha.Core
{
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

        public void start() throws BackendError
        {
            // if (backend.status(taskdata.id).active)
            //     throw new TaskError.ERROR(@"Task $(taskdata.id.uuid) is already started");
            backend.submit(taskdata.id);
        }

        public void stop() throws BackendError, TaskError
        {
            if (!backend.status(taskdata.id).active)
                throw new TaskError.ERROR(@"Task $(taskdata.id.uuid) is not active");
            wrapper.query_stop();
        }

        public void destroy() throws SerializationError, TaskError
        {
            if (backend.status(taskdata.id).active)
                throw new TaskError.ERROR(@"Task $(taskdata.id.uuid) is active");
            remove();
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
}
