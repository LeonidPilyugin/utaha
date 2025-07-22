namespace Utaha.Core
{
    public abstract class Backend : Storable, IJsonable
    {
        public abstract BackendHealthReport healthcheck();

        public void submit(Id id) throws BackendError
        {
            if (this.status(id).active)
                throw new BackendError.ERROR("Is already active");
            string[] cmd = { "utaha-daemon", id.uuid };
            this._submit(id, cmd);
        }

        protected abstract void _submit(Id id, string[] command) throws BackendError;

        public void cancel(Id id) throws BackendError
        {
            if (!this.status(id).active)
                throw new BackendError.ERROR("Is not active");
            this._cancel(id);
        }

        protected abstract void _cancel(Id id) throws BackendError;

        public abstract BackendStatus status(Id id) throws BackendError;

        protected abstract void init_json(Json.Object object) throws JsonableError;
    }
}
