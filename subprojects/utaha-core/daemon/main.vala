errordomain Error
{
    ERROR,
}

static MainLoop loop = null;
static Utaha.Core.Task task = null;

static void register_signals()
{
    Process.signal(
        ProcessSignal.HUP,
        (s) => { }
    );
    Process.signal(
        ProcessSignal.TERM,
        (s) => {
            task.daemon_stop();
        }
    );
}

static bool timer_callback()
{
    if (task.on_tick()) loop.quit();
    return true;
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
    task.daemon_start.begin();
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
