namespace Utaha.Core
{
    public abstract class Serializable : Object
    {
        public virtual StorageNode? node { get; set; }

        public virtual void load() throws SerializationError { }

        public virtual void dump() throws SerializationError { }

        public virtual void init() throws SerializationError
        {
            try
            {
                node?.write_file("type", this.get_type().name());
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not initialize storage node: $(e.message)"
                );
            }
        }

        public virtual void remove() throws SerializationError
        {
            try
            {
                node?.remove();
            } catch (StorageNodeError e)
            {
                throw new SerializationError.STORAGE_ERROR(
                    @"Could not remove storage node: $(e.message)"
                );
            }
        }

        public static T load_from<T>(StorageNode node)
            throws SerializationError, StorageNodeError
        {
            var type = typeof(T);
            var typename = node.read_file("type");
            var ttype = Type.from_name(typename);

            if (0 == ttype)
                throw new SerializationError.TYPE_ERROR(
                    @"Could not create object of type $typename"
                );

            if (!type.is_a(typeof(Serializable)))
                throw new SerializationError.TYPE_ERROR(
                    @"The type $(type.name()) is not instance of Serializable"
                );
            if (!ttype.is_a(type))
                throw new SerializationError.TYPE_ERROR(
                    @"The type $(type.name()) is not $(ttype.name())"
                );

            var obj = Object.new(ttype);

            Serializable result = (Serializable) obj;
            result.node = node;

            result.load();

            return result;
        }
    }
}
