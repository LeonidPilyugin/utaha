namespace Utaha.Core.Serialization
{
    public interface Initializable : Object
    {
        public static T initialize<T>(Element element) throws InitializableError
            requires(element is TableElement)
        {
            TableElement el = (TableElement) element;
            var type = typeof(T);
            var typename = el.contains("type") ? el.get<ValueElement>("type").as<string>() : type.name();
            var ttype = Type.from_name(typename);

            if (0 == ttype)
                throw new InitializableError.TYPE_ERROR(
                    @"Could not create object of type $typename"
                );

            if (!type.is_a(typeof(Initializable)))
                throw new InitializableError.TYPE_ERROR(
                    @"The type $(type.name()) is not instance of Serializable"
                );
            if (!ttype.is_a(type))
                throw new InitializableError.TYPE_ERROR(
                    @"The type $(type.name()) is not $(ttype.name())"
                );

            var obj = Object.new(ttype);
            var result = (Initializable) obj;
            result._initialize(el);

            return result;
        }

        protected abstract void _initialize(TableElement object) throws InitializableError;
    }
}
