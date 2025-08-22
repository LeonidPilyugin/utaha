namespace Utaha.Core.Serialization
{
    public class JsonReader : Reader
    {
        public override Element read(string data)
        {
            var parser = new Json.Parser();
            parser.load_from_data(data);
            return parse(parser.get_root());
        }

        public override Element read_file(string path)
        {
            var parser = new Json.Parser();
            parser.load_from_file(path);
            return parse(parser.get_root());
        }

        private Element parse(Json.Node n)
        {
            Element el = null;

            switch (n.get_node_type())
            {
                case Json.NodeType.NULL:
                    el = new NullElement();
                    break;
                case Json.NodeType.VALUE:
                    el = new ValueElement(n.get_value());
                    break;
                case Json.NodeType.ARRAY:
                    el = new ArrayElement();
                    foreach (unowned var nn in n.get_array().get_elements())
                        ((ArrayElement) el).append(parse(nn));
                    break;
                case Json.NodeType.OBJECT:
                    el = new TableElement();
                    foreach (unowned string key in n.get_object().get_members())
                        ((TableElement) el)[key] = parse(n.get_object().get_member(key));
                    break;
            }

            return el;
        }
    }
}
