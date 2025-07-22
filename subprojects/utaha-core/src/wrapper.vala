namespace Utaha.Core
{
    public abstract class Wrapper : Serializable, IJsonable
    {
        [CCode (has_target = false)]
        public delegate void SignalHandlerMethod (Wrapper wrapper, ProcessSignal signal);

        public abstract WrapperStatus status();

        public abstract void start();

        public abstract void stop();

        public abstract bool on_tick();

        public abstract HashTable<ProcessSignal, SignalHandlerMethod> get_signal_handlers();

        protected abstract void init_json(Json.Object object) throws JsonableError;
    }
}
