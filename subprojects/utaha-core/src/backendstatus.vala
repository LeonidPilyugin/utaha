namespace Utaha.Core
{
    public abstract class BackendStatus : Status
    {
        public bool active { get; protected set; }
        public Type backend_type { get; protected set; }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            ht.insert("active", active.to_string());
            return ht;
        }
    }
}
