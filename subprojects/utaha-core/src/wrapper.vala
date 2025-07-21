using Toml;

namespace Utaha.Core
{
    public abstract class Wrapper : Serializable, ITomlable
    {
        [CCode (has_target = false)]
        public delegate void SignalHandlerMethod (Wrapper wrapper, ProcessSignal signal);

        public abstract WrapperStatus status();

        public abstract void start();

        public abstract void stop();

        public abstract bool on_tick();

        public abstract HashTable<ProcessSignal, SignalHandlerMethod> get_signal_handlers();

        protected abstract void init_toml(Element element) throws TomlableError;
    }

    [Immutable]
    public abstract class WrapperStatus : Status
    {
        public DateTime? last_active { get; protected set; }

        public override HashTable<string, string> as_hash_table()
        {
            var ht = base.as_hash_table();
            if (last_active != null) ht.insert("last_active", last_active.to_string());
            return ht;
        }
    }
}
