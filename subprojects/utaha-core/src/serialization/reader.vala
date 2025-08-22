namespace Utaha.Core.Serialization
{
    public abstract class Reader
    {
        public abstract Element read(string data);

        public abstract Element read_file(string path);
    }
}
