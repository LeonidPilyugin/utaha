namespace Utaha.Core
{
    public sealed class Task : Storable, Serialization.Initializable
    {
        public TaskData taskdata { get; private set; }
        public Backend backend { get; private set; }
        public Job job { get; private set; }
        private StorageNode? _node;

        public Task()
        {
            taskdata = null;
            backend = null;
            job = null;
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
                    if (job != null) job.node = node == null ? null : node.subnode("job");
                } catch (StorageNodeError e)
                {
                    assert_not_reached();
                }
            }
        }

        public override void init() throws StorableError
        {
            base.init();
            backend.init();
            job.init();
            taskdata.init();
        }

        public override void load() throws StorableError
        {
            try
            {
                backend = Storable.load_from<Backend>(node.subnode("backend"));
                job = Storable.load_from<Job>(node.subnode("job"));
                taskdata = Storable.load_from<TaskData>(node.subnode("taskdata"));
            } catch (StorageNodeError e)
            {
                throw new StorableError.STORAGE_ERROR(e.message);
            }
        }

        public override void dump() throws StorableError
        {
            backend.dump();
            job.dump();
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
            query_stop();
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
            job.remove();
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
                    return job.status();
                }
            );
        }

        protected void _initialize(Serialization.TableElement el) throws Serialization.InitializableError
        {
            string[] members = { "taskdata", "backend", "job" };
            foreach (unowned string member in members)
            {
                if (!el.contains(member))
                    throw new Serialization.InitializableError.ERROR(@"Does not have \"$member\" member");
                if (el.get<Serialization.Element>(member).get_type() != typeof(Serialization.TableElement))
                    throw new Serialization.InitializableError.ERROR(@"Member \"$member\" does not contain object");
            }
            taskdata = Serialization.Initializable.initialize<TaskData>(el["taskdata"]);
            backend = Serialization.Initializable.initialize<Backend>(el["backend"]);
            job = Serialization.Initializable.initialize<Job>(el["job"]);
        }

        public async void daemon_start() throws TaskError
        {
            yield job.start();
        }

        public void daemon_stop()
        {
            job.stop();
        }

        private void query_stop()
        {
            try
            {
                node.touch_file("stop");
                while (node.read_file("stop") != "ack") Thread.usleep(100000);
                node.remove_file("stop");
            } catch (StorageNodeError e)
            {
                assert_not_reached();
            }
        }

        public bool on_tick()
        {
            try
            {
                if (node.file_exists("stop"))
                {
                    job.stop();
                    node.write_file("stop", "ack");
                    return true;
                }

                return job.is_finished();
            } catch (StorageNodeError e)
            {
                assert_not_reached();
            }
        }
    }
}
