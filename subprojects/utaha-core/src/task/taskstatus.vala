namespace Utaha.Core
{
    public sealed class TaskStatus : Status
    {
        public TaskData taskdata { get; private set; }
        public Gee.Lazy<BackendStatus> backend_status { get; private set; }
        public Gee.Lazy<WrapperStatus> wrapper_status { get; private set; }
        public string stdout_path { get; private set; }
        public string stderr_path { get; private set; }

        internal TaskStatus(
            TaskData taskdata,
            Gee.LazyFunc<BackendStatus> backend_status,
            Gee.LazyFunc<WrapperStatus> wrapper_status,
            string stdout_path,
            string stderr_path
        )
        {
            this.taskdata = taskdata;
            this.backend_status = new Gee.Lazy<BackendStatus>(backend_status);
            this.wrapper_status = new Gee.Lazy<WrapperStatus>(wrapper_status);
            this.stderr_path = stderr_path;
            this.stdout_path = stdout_path;
        }

        public override Iterable iter
        {
            owned get
            {
                return base.iter
                    .set<Status.Iterable>(new Status.Iterable.Key.str("backend"), backend_status.value.iter)
                    .set<Status.Iterable>(new Status.Iterable.Key.str("wrapper"), wrapper_status.value.iter);
            }
        }
    }
}
