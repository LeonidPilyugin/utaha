using Toml;

namespace Utaha.Core
{
    public errordomain TomlableError
    {
        TYPE_ERROR,
        TOML_ERROR,
        ERROR,
    }

    public interface ITomlable : Object
    {
        public static T load_toml<T>(Element element) throws TomlableError
        {
            var type = typeof(T);
            var typename = element.contains("type") ? element["type"].as<string>() : type.name();
            var ttype = Type.from_name(typename);

            if (0 == ttype)
                throw new TomlableError.TYPE_ERROR(
                    @"Could not create object of type $typename"
                );

            if (!type.is_a(typeof(ITomlable)))
                throw new SerializationError.TYPE_ERROR(
                    @"The type $(type.name()) is not instance of Serializable"
                );
            if (!ttype.is_a(type))
                throw new TomlableError.TYPE_ERROR(
                    @"The type $(type.name()) is not $(ttype.name())"
                );

            var obj = Object.new(ttype);
            ITomlable result = (ITomlable) obj;
            result.init_toml(element);

            return result;
        }

        protected abstract void init_toml(Element element) throws TomlableError;
    }
}
