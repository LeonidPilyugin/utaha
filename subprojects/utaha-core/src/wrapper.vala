namespace Utaha.Core
{
    public abstract class Wrapper : Storable, IJsonable
    {

        [CCode (has_target = false)]
        public delegate void SignalHandlerMethod (Wrapper wrapper, ProcessSignal signal);

        public abstract WrapperStatus status();

        public abstract async void start() throws WrapperError;

        public abstract void stop();

        public virtual bool on_tick() throws WrapperError
        {
            if (node.file_exists("stop"))
            {
                stop();
                node.write_file("stop", "ack");
                return true;
            }

            return false;
        }

        public async void query_stop()
        {
            node.touch_file("stop");
            yield;
            while (node.read_file("stop") != "ack") Thread.usleep(100000);
            node.remove_file("stop");
        }

        public abstract HashTable<ProcessSignal?, SignalHandlerMethod> get_signal_handlers();

        protected abstract void init_json(Json.Object object) throws JsonableError;
    }
}
