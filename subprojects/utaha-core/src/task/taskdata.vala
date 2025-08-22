namespace Utaha.Core
{
    public sealed class TaskData : Storable, Serialization.Initializable
    {
        public Id id { get; private set; }
        public string alias { get; private set; }
        public string comment { get; private set; }
        public DateTime load_date { get; private set; }
        public DateTime? start_date { get; internal set; }

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
                var el = new Serialization.JsonReader().read(node.read_file("taskdata.json")) as Serialization.TableElement;
                id = Id.from_string(el.get<Serialization.ValueElement>("id").as<string>());
                load_date = new DateTime.from_unix_local(el.get<Serialization.ValueElement>("load_date").as<int64?>());
                alias = el.get<Serialization.ValueElement>("alias").as<string>();
                comment = el.get<Serialization.ValueElement>("comment").as<string>();

                start_date = null;
                if (el.contains("start_date"))
                    start_date = new DateTime.from_unix_local(el.get<Serialization.ValueElement>("start_date").as<int64?>());
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
                var t = new Serialization.TableElement();
                t["id"] = new Serialization.ValueElement(id.uuid);
                t["alias"] = new Serialization.ValueElement(alias);
                t["comment"] = new Serialization.ValueElement(comment);
                t["load_date"] = new Serialization.ValueElement(load_date.to_unix());

                if (start_date != null)
                {
                    t["start_date"] = new Serialization.ValueElement(start_date.to_unix());
                }

                node.write_file("taskdata.json", new Serialization.JsonWriter().write(t));
            } catch (StorageNodeError e)
            {
                throw new StorableError.STORAGE_ERROR(
                    @"Could not dump: $(e.message)"
                );
            }
        }

        protected void _initialize(Serialization.TableElement el) throws Serialization.InitializableError
        {
            id = Id.generate();
            load_date = new DateTime.now();

            if (!el.contains("alias"))
                throw new Serialization.InitializableError.ERROR("Does not have \"alias\" member");
            if (!el.contains("comment"))
                throw new Serialization.InitializableError.ERROR("Does not have \"comment\" member");

            alias = el.get<Serialization.ValueElement>("alias").as<string>();
            comment = el.get<Serialization.ValueElement>("comment").as<string>();
        }
    }
}
