namespace Utaha.Core
{
    public abstract class Backend : Storable, IJsonable
    {
        // public abstract BackendHealthReport healthcheck();

        public void submit(Id id) throws BackendError
        {
            if (status().active)
                throw new BackendError.ERROR("Is already active");
            string[] cmd = { "utaha-daemon", id.uuid };
            this._submit(cmd);
        }

        protected abstract void _submit(string[] command) throws BackendError;

        public void cancel() throws BackendError
        {
            if (!status().active)
                throw new BackendError.ERROR("Is not active");
            this._cancel();
        }

        protected abstract void _cancel() throws BackendError;

        public abstract BackendStatus status() throws BackendError;

        protected abstract void init_json(Json.Object object) throws JsonableError;
    }
}
