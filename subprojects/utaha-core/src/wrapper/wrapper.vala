namespace Utaha.Core
{
    public abstract class Wrapper : Storable, IJsonable
    {

        [CCode (has_target = false)]
        public delegate void SignalHandlerMethod (Wrapper wrapper, ProcessSignal signal);

        public abstract WrapperStatus status();

        public abstract async void start() throws WrapperError;

        public abstract void stop();

        public const string stdout_name = "stdout";
        public const string stderr_name = "stderr";

        public override void init() throws Utaha.Core.StorableError
        {
            base.init();
            try
            {
                node.touch_file("stdout");
                node.touch_file("stderr");
            } catch (Utaha.Core.StorageNodeError e)
            {
                throw new Utaha.Core.StorableError.STORAGE_ERROR(
                    @"Could not initialize storage node: $(e.message)"
                );
            }
        }

        public virtual string stdout_path
        {
            owned get
            {
                return node.build(stdout_name);
            }
        }

        public virtual string stderr_path
        {
            owned get
            {
                return node.build(stderr_name);
            }
        }

        public virtual bool on_tick() throws WrapperError
        {
            try
            {
                if (node.file_exists("stop"))
                {
                    stop();
                    node.write_file("stop", "ack");
                    return true;
                }

                return false;
            } catch (StorageNodeError e)
            {
                error(@"Unexpected error: $(e.message)");
            }
        }

        public void query_stop()
        {
            try
            {
                node.touch_file("stop");
                while (node.read_file("stop") != "ack") Thread.usleep(100000);
                node.remove_file("stop");
            } catch (StorageNodeError e)
            {
                error(@"Unexpected error: $(e.message)");
            }
        }

        public abstract HashTable<ProcessSignal?, SignalHandlerMethod> get_signal_handlers();

        protected abstract void init_json(Json.Object object) throws JsonableError;
    }
}
