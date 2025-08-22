namespace Utaha.Core.Serialization
{
    public sealed class ValueElement : Element
    {
        private Value value;

        public ValueElement(Value v)
        {
            value = v;
        }

        public Type gtype { get { return value.type(); } }

        public G as<G>()
        {
            Type t = typeof(G);

            if (typeof(int) == t)
            {
                return value.get_int();
            } else if (typeof(long) == t)
            {
                return value.get_long();
            } else if (typeof(int64?) == t)
            {
                return (int64?) value.get_int64();
            } else if (typeof(string) == t)
            {
                return value.get_string();
            } else if (typeof(bool?) == t)
            {
                return value.get_boolean();
            }

            assert_not_reached();
        }
    }
}
