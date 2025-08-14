namespace Utaha.Core
{
    public abstract class WrapperStatus : Status
    {
        public DateTime? last_active { get; protected set; }
        public Type wrapper_type { get; protected set; }

        public override Iterable iter
        {
            owned get
            {
                return base.iter
                    .set<string>(new Status.Iterable.Key.str("last active"), last_active.to_string())
                    .set<string>(new Status.Iterable.Key.str("type"), wrapper_type.name());
            }
        }
    }
}
