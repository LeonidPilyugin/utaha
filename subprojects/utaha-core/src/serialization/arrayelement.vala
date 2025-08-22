namespace Utaha.Core.Serialization
{
    public sealed class ArrayElement : Element
    {
        private Array<Element> array = new Array<Element>();

        public new T @get<T>(uint index)
        {
            return array.data[index];
        }

        public new void @set<T>(uint index, T element)
        {
            array.data[index] = (Element) element;
        }

        public void append(Element element)
        {
            array.append_val(element);
        }

        public uint length { get { return array.length; } }
    }
}
