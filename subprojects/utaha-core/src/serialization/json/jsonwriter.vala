namespace Utaha.Core.Serialization
{
    public class JsonWriter : Writer
    {
        public override string write(Element element)
        {
            return generate(element).to_data(null);
        }

        public override void write_file(Element element, string path)
        {
            generate(element).to_file(path);
        }

        private Json.Generator generate(Element element)
        {
            var g = new Json.Generator();
            var b = new Json.Builder();

            iter(element, b);

            g.root = b.get_root();
            return g;
        }

        private void iter(Element e, Json.Builder b)
        {
            Type t = e.get_type();
            if (typeof(NullElement) == t)
            {
                b.add_null_value();
            } else if (typeof(ArrayElement) == t)
            {
                b.begin_array();
                for (uint i = 0; i < ((ArrayElement) e).length; i++)
                    iter(((ArrayElement) e).get<Element>(i), b);
                b.end_array();
            } else if (typeof(TableElement) == t)
            {
                b.begin_object();
                var ee = (TableElement) e;
                foreach (unowned string key in ee.get_keys())
                {
                    b.set_member_name(key);
                    iter(ee.get<Element>(key), b);
                }
                b.end_object();
            } else { assert_not_reached(); }
        }
    }
}
