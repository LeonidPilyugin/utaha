namespace Utaha.Core
{
    public sealed class TaskData : Storable, IJsonable
    {
        public Id id { get; private set; }
        public string alias { get; private set; }
        public string comment { get; private set; }

        public TaskData(Id id, string alias, string comment)
        {
            this.id = id;
            this.alias = alias;
            this.comment = comment;
        }

        public override void init() throws StorableError
        {
            base.init();
            try
            {
                node.touch_file("taskdata.json");
            } catch (StorageNodeError e)
            {
                throw new StorableError.STORAGE_ERROR(
                    @"Could not initialize storage node: $(e.message)"
                );
            }
        }

        public override void load() throws StorableError
        {
            try
            {
                var parser = new Json.Parser();
                parser.load_from_data(node.read_file("taskdata.json"));
                var object = parser.get_root().get_object();
                init_json(object);
                if (!object.has_member("id"))
                    throw new StorableError.ERROR("Corrupted taskdata.json");
                id = Id.from_string(object.get_string_member("id"));
            } catch (StorageNodeError e)
            {
                throw new StorableError.STORAGE_ERROR(e.message);
            } catch (Error e)
            {
                throw new StorableError.ERROR(e.message);
            }
        }

        public override void dump() throws StorableError
        {
            try
            {
                Json.Builder builder = new Json.Builder();
                builder.begin_object();

                builder.set_member_name("id");
                builder.add_string_value(id.uuid);

                builder.set_member_name("alias");
                builder.add_string_value(alias);

                builder.set_member_name("comment");
                builder.add_string_value(comment);

                builder.end_object();

                Json.Generator generator = new Json.Generator();
                Json.Node root = builder.get_root();
                generator.set_root(root);

                node.write_file("taskdata.json", generator.to_data(null));
            } catch (StorageNodeError e)
            {
                throw new StorableError.STORAGE_ERROR(
                    @"Could not dump: $(e.message)"
                );
            }
        }

        protected void init_json(Json.Object object) throws JsonableError
        {
            id = Id.generate();

            if (!object.has_member("alias"))
                throw new JsonableError.ERROR("Does not have \"alias\" member");
            if (!object.has_member("comment"))
                throw new JsonableError.ERROR("Does not have \"comment\" member");

            alias = object.get_string_member("alias");
            comment = object.get_string_member("comment");
        }
    }


}
