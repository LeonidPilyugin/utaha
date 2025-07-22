namespace Utaha.App
{
    static void stop(Utaha.Core.Id id) throws Error
    {
        try
        {
            var task = Utaha.Core.Storage.get_storage().get_task(id);
            task.stop();
        } catch (Utaha.Core.TaskError e) { throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.BackendError e) { throw new Error.RUNTIME_ERROR(e.message);
        }
    }
}
