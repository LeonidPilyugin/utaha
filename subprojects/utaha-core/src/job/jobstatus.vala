namespace Utaha.Core
{
    public abstract class JobStatus : Status
    {
        public DateTime? last_active { get; protected set; }
        public Type job_type { get; protected set; }

        public override Iterable iter
        {
            owned get
            {
                return base.iter
                    .set<string>(new Status.Iterable.Key.str("last active"), last_active.to_string())
                    .set<string>(new Status.Iterable.Key.str("type"), job_type.name());
            }
        }
    }
}
