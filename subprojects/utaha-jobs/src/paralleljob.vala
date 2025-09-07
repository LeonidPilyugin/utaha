namespace Utaha.Jobs
{
    public class ParallelJobStatus : Utaha.Core.JobStatus
    {
        public Utaha.Core.JobStatus[] statuses { get; private set; }

        public ParallelJobStatus(Utaha.Core.JobStatus[] statuses)
        {
            job_type = typeof(ParallelJob);
            this.statuses = statuses;
        }

        public override Utaha.Core.Status.Iterable iter
        {
            owned get
            {
                Utaha.Core.Status.Iterable result = base.iter;
                int i = 0;
                foreach (var s in statuses)
                    result.set<Utaha.Core.Status.Iterable>(new Utaha.Core.Status.Iterable.Key.str((i++).to_string()), s.iter);
                return result;
            }
        }
    }

    public class ParallelJob : Utaha.Core.Job
    {
        private Utaha.Core.Job[] jobs;

        public override bool is_finished()
        {
            bool result = true;
            foreach (var j in jobs)
                result &= j.is_finished();
            return result;
        }

        public async override void start()
        {
            foreach (var j in jobs)
                j.start.begin();
            yield;
        }

        public override void stop()
        {
            foreach (var j in jobs)
                if (!j.is_finished()) j.stop();
        }

        public override Utaha.Core.JobStatus status()
        {
            var statuses = new Utaha.Core.JobStatus[jobs.length];
            for (uint i = 0; i < jobs.length; i++)
                statuses[i] = jobs[i].status();
            return new ParallelJobStatus(statuses);
        }

        protected override void _initialize(Utaha.Core.Serialization.TableElement element) throws Utaha.Core.Serialization.InitializableError
        {
            if (!element.contains("workflow"))
                throw new Utaha.Core.Serialization.InitializableError.ERROR(@"Does not have \"workflow\" member");
            if (element.get<Utaha.Core.Serialization.Element>("workflow").get_type() != typeof(Utaha.Core.Serialization.ArrayElement))
                throw new Utaha.Core.Serialization.InitializableError.ERROR(@"Member \"workflow\" is not an array");

            var workflow = element.get<Utaha.Core.Serialization.ArrayElement>("workflow") as Utaha.Core.Serialization.ArrayElement;

            jobs = new Utaha.Core.Job[workflow.length];

            for (uint i = 0; i < workflow.length; i++)
                jobs[i] = Utaha.Core.Serialization.Initializable.initialize<Utaha.Core.Job>(workflow.get<Utaha.Core.Serialization.Element>(i));
        }

        private Utaha.Core.StorageNode? _node;

        public override Utaha.Core.StorageNode? node
        {
            get { return _node; }
            set
            {
                try
                {
                    _node = value;
                    if (jobs != null)
                        for (uint i = 0; i < jobs.length; i++)
                            jobs[i].node = node == null ? null : node.subnode(i.to_string());
                } catch (Utaha.Core.StorageNodeError e)
                {
                    assert_not_reached();
                }
            }
        }

        public override void init() throws Utaha.Core.StorableError
        {
            base.init();
            for (uint i = 0; i < jobs.length; i++)
                jobs[i].init();
        }

        public override void load() throws Utaha.Core.StorableError
        {
            uint n = uint.parse(node.read_file("n"));
            jobs = new Utaha.Core.Job[n];
            for (uint i = 0; i < n; i++)
                jobs[i] = Utaha.Core.Storable.load_from<Utaha.Core.Job>(node.subnode(i.to_string()));
        }

        public override void dump() throws Utaha.Core.StorableError
        {
            node.write_file("n", jobs.length.to_string());
            foreach (var j in jobs)
                j.dump();
            base.dump();
        }

        public override void remove() throws Utaha.Core.StorableError
        {
            node?.remove_file("n");
            for (uint i = 0; i < jobs.length; i++)
                node?.subnode(i.to_string()).remove();
            base.remove();
        }
    }
}
