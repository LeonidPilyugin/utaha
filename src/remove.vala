namespace Utaha.App
{
    static void remove_one(Utaha.Core.Id? id) throws Error
    {
        try
        {
            var task = Utaha.Core.Storage.get_storage().get_task(id);
            task.destroy();
        } catch (Utaha.Core.TaskError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.BackendError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.StorageNodeError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.StorableError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        }
    }

    static void remove(List<Utaha.Core.Id?> ids) throws Error
    {
        foreach (unowned var id in ids)
            remove_one(id);
    }
}
