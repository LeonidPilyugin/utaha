namespace Utaha.App
{
    static void stop_one(Utaha.Core.Id id) throws Error
    {
        try
        {
            var task = Utaha.Core.Storage.get_storage().get_task(id);
            task.stop();
        } catch (Utaha.Core.TaskError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.BackendError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.StorageError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.StorableError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        }
    }

    static void stop(List<Utaha.Core.Id?> ids) throws Error
    {
        foreach (unowned var id in ids)
            stop_one(id);
    }
}
