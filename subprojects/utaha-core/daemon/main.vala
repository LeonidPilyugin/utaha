errordomain Error
{
    ERROR,
}


static MainLoop loop = null;
static Utaha.Core.Task task = null;
static HashTable<ProcessSignal?, Utaha.Core.Wrapper.SignalHandlerMethod> handlers;

static void register_signals()
{
    handlers = task.wrapper.get_signal_handlers();
    foreach (ProcessSignal? sig in handlers.get_keys())
        Process.signal(sig, on_signal);
}

static bool timer_callback()
{
    try
    {
        if (task.wrapper.on_tick()) loop.quit();
    } catch (Utaha.Core.WrapperError e)
    {
        error(e.message);
    }
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

static void run(Utaha.Core.Id id, int delay = 100)
{
    try
    {
        task = Utaha.Core.Storage.get_storage().get_task(id);
    } catch (Utaha.Core.StorageError e)
    {
        error(e.message);
    } catch (Utaha.Core.StorableError e)
    {
        error(e.message);
    }

    register_signals();
    loop = new MainLoop();
    var time = new TimeoutSource(delay);
    time.set_callback(timer_callback);
    time.attach(loop.get_context());
    task.wrapper.start.begin();
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
        error(e.message);
    } catch (Utaha.Core.ModuleError e)
    {
        error(e.message);
    }

    return 0;
}
