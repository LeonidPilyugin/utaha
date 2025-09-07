namespace Utaha.Core
{
    public sealed class TaskStatus : Status
    {
        public TaskData taskdata { get; private set; }
        public BackendStatus backend_status { get; private set; }
        public JobStatus job_status { get; private set; }

        internal TaskStatus(
            TaskData taskdata,
            BackendStatus backend_status,
            JobStatus job_status
        )
        {
            this.taskdata = taskdata;
            this.backend_status = backend_status;
            this.job_status = job_status;
        }

        public override Iterable iter
        {
            owned get
            {
                return base.iter
                    .set<Status.Iterable>(new Status.Iterable.Key.str("backend"), backend_status.iter)
                    .set<Status.Iterable>(new Status.Iterable.Key.str("job"), job_status.iter);
            }
        }
    }
}
