namespace Utaha.Core
{
    public abstract class WrapperStatus : Status
    {
        public DateTime? last_active { get; protected set; }
        public Type wrapper_type { get; protected set; }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            if (last_active != null) ht.insert("last_active", last_active.to_string());
            return ht;
        }
    }
}
