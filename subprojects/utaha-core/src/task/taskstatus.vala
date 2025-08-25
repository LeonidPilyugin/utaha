namespace Utaha.Core
{
    public sealed class TaskStatus : Status
    {
        public TaskData taskdata { get; private set; }
        public Gee.Lazy<BackendStatus> backend_status { get; private set; }
        public Gee.Lazy<JobStatus> job_status { get; private set; }

        internal TaskStatus(
            TaskData taskdata,
            Gee.LazyFunc<BackendStatus> backend_status,
            Gee.LazyFunc<JobStatus> job_status
        )
        {
            this.taskdata = taskdata;
            this.backend_status = new Gee.Lazy<BackendStatus>(backend_status);
            this.job_status = new Gee.Lazy<JobStatus>(job_status);
        }

        public override Iterable iter
        {
            owned get
            {
                return base.iter
                    .set<Status.Iterable>(new Status.Iterable.Key.str("backend"), backend_status.value.iter)
                    .set<Status.Iterable>(new Status.Iterable.Key.str("job"), job_status.value.iter);
            }
        }
    }
}
