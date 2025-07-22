namespace Utaha.Core
{
    public errordomain JsonableError
    {
        TYPE_ERROR,
        ERROR,
    }

    public interface IJsonable : Object
    {
        public static T load_json<T>(Json.Object object) throws JsonableError
        {
            var type = typeof(T);
            var typename = object.has_member("type") ? object.get_string_member("type") : type.name();
            var ttype = Type.from_name(typename);

            if (0 == ttype)
                throw new JsonableError.TYPE_ERROR(
                    @"Could not create object of type $typename"
                );

            if (!type.is_a(typeof(IJsonable)))
                throw new JsonableError.TYPE_ERROR(
                    @"The type $(type.name()) is not instance of Storable"
                );
            if (!ttype.is_a(type))
                throw new JsonableError.TYPE_ERROR(
                    @"The type $(type.name()) is not $(ttype.name())"
                );

            var obj = Object.new(ttype);
            IJsonable result = (IJsonable) obj;
            result.init_json(object);

            return result;
        }

        protected abstract void init_json(Json.Object object) throws JsonableError;
    }
}
