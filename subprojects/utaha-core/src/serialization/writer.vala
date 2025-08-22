namespace Utaha.Core.Serialization
{
    public abstract class Writer
    {
        public abstract string write(Element element);

        public abstract void write_file(Element element, string path);
    }
}
