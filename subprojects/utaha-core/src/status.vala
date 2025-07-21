namespace Utaha.Core
{
    public abstract class Status : Object
    {
        public virtual HashTable<string, string> as_hash_table()
        {
            return new HashTable<string, string>(str_hash, str_equal);
        }
    }
}
