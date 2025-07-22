namespace Utaha.Core
{
    public abstract class Storable : Object
    {
        public virtual StorageNode? node { get; set; }

        public virtual void load() throws StorableError { }

        public virtual void dump() throws StorableError { }

        public virtual void init() throws StorableError
        {
            try
            {
                node?.write_file("type", this.get_type().name());
            } catch (StorageNodeError e)
            {
                throw new StorableError.STORAGE_ERROR(
                    @"Could not initialize storage node: $(e.message)"
                );
            }
        }

        public virtual void remove() throws StorableError
        {
            try
            {
                node?.remove();
            } catch (StorageNodeError e)
            {
                throw new StorableError.STORAGE_ERROR(
                    @"Could not remove storage node: $(e.message)"
                );
            }
        }

        public static T load_from<T>(StorageNode node)
            throws StorableError, StorageNodeError
        {
            var type = typeof(T);
            var typename = node.read_file("type");
            var ttype = Type.from_name(typename);

            if (0 == ttype)
                throw new StorableError.TYPE_ERROR(
                    @"Could not create object of type $typename"
                );

            if (!type.is_a(typeof(Storable)))
                throw new StorableError.TYPE_ERROR(
                    @"The type $(type.name()) is not instance of Storable"
                );
            if (!ttype.is_a(type))
                throw new StorableError.TYPE_ERROR(
                    @"The type $(type.name()) is not $(ttype.name())"
                );

            var obj = Object.new(ttype);

            Storable result = (Storable) obj;
            result.node = node;

            result.load();

            return result;
        }
    }
}
