namespace Utaha.Core
{
    public abstract class Job : Storable, Serialization.Initializable
    {
        public async abstract void start();

        public abstract void stop();

        public abstract JobStatus status();

        protected abstract void _initialize(Serialization.TableElement element) throws Serialization.InitializableError;
    }
}
