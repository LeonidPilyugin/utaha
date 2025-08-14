namespace Utaha.Core
{
    public abstract class Status
    {
        public sealed class Iterable : Object, Gee.Traversable<unowned Key>, Gee.Iterable<unowned Key>
        {
            [Immutable]
            public class Key
            {
                private string[] sequence;

                private string strjoin { owned get { return string.joinv("", sequence); } }

                public Key(string[] sequence)
                {
                    this.sequence = sequence;
                }

                public Key.str(string str)
                {
                    sequence = { str };
                }

                public static uint hash(Key k)
                {
                    return str_hash(k.strjoin);
                }

                public static bool equal(Key k1, Key k2)
                {
                    return str_equal(k1.strjoin, k2.strjoin);
                }

                public Key? parent()
                {
                    return sequence.length > 0 ? new Key(sequence[:sequence.length - 1]) : null;
                }

                public uint depth { get { return sequence.length; } }

                public unowned string get(uint index)
                    requires (index < depth)
                {
                    return sequence[index];
                }

                public string last { get { return get(depth - 1); } }

                public static Key join(Key k1, Key k2)
                {
                    var a = new Gee.ArrayList<string>.wrap(k1.sequence);
                    a.add_all_array(k2.sequence);
                    return new Key(a.to_array());
                }
            }

            private HashTable<Key, string> data = new HashTable<Key, string>(Key.hash, Key.equal);

            private new string get(Key key)
                requires(key in data)
            {
                return data[key];
            }

            public Iterable set<T>(Key key, T value)
                requires(value is string || value is Iterable)
            {
                if (value is string)
                    data[key] = (string) value;
                else
                {
                    assert(value is Iterable);
                    Iterable it = (Iterable) value;
                    foreach (unowned Key k in it)
                        set(Key.join(key, k), it[k]);
                }
                return this;
            }

            public Gee.Iterator<unowned Key> iterator()
            {
                return new Gee.ArrayList<unowned Key>.wrap(data.get_keys_as_array()).iterator();
            }

            public bool @foreach(Gee.ForallFunc<unowned Key> f)
            {
                return iterator().foreach(f);
            }
        }

        public virtual Iterable iter { owned get { return new Iterable(); } }
    }
}
