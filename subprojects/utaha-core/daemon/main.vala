errordomain HandlerError
{
    ERROR,
}

static MainLoop loop = null;
static Utaha.Core.Task task = null;
static HashTable<ProcessSignal, Utaha.Core.Wrapper.SignalHandlerMethod> handlers;

static void register_signals()
{
    var signals = task.wrapper.get_signal_handlers();
    foreach (ProcessSignal sig in signals.get_keys())
        Process.signal(sig, on_signal);
}

static bool timer_callback()
{
    if (task.wrapper.on_tick()) loop.quit();
    return true;
}

static void on_signal(int signal)
{
    if (handlers.contains(signal))
    {
        var func = handlers.get(signal);
        func(task.wrapper, signal);
    }

}

static void run(Utaha.Core.Id id, int delay = 1000)
{
    task = Utaha.Core.Storage.get_storage().get_task(id);
    loop = new MainLoop();
    TimeoutSource time = new TimeoutSource(delay);
    time.set_callback(timer_callback);
    time.attach(loop.get_context());
    task.wrapper.start();
    loop.run();
}

static int main(string[] args)
{
    try
    {
        if (args.length != 2) return 1;
        Utaha.Core.load_modules();
        run(Utaha.Core.Id.from_string(args[1]));
    } catch (Utaha.Core.IdError e)
    {
        return 1;
    } catch (Utaha.Core.ModuleError e)
    {
        return 1;
    } catch (HandlerError e)
    {
        return 1;
    }

    return 0;
}
