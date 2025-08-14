namespace Utaha.Core
{
    public abstract class BackendStatus : Status
    {
        public bool active { get; protected set; }
        public Type backend_type { get; protected set; }

        public override Iterable iter
        {
            owned get
            {
                return base.iter
                    .set<string>(new Status.Iterable.Key.str("active"), active.to_string());
            }
        }
    }
}
