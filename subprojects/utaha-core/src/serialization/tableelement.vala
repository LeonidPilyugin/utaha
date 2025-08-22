namespace Utaha.Core.Serialization
{
    public sealed class TableElement : Element
    {
        private HashTable<string, Element> table = new HashTable<string, Element>(str_hash, str_equal);

        public new T @get<T>(string index)
        {
            return table[index];
        }

        public new void @set<T>(string key, T element)
        {
            table[key] = (Element) element;
        }

        public List<unowned string> get_keys()
        {
            return table.get_keys();
        }

        public bool contains(string key)
        {
            return table.contains(key);
        }
    }
}
