namespace Utaha.App
{
    static void list() throws Error
    {
        try
        {
            var tasks = Utaha.Core.Storage.get_storage().list_tasks();
            foreach (Utaha.Core.Task task in tasks)
                stdout.printf(@"$(task.taskdata.id.uuid)\n");
        } catch (Utaha.Core.StorageError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.StorableError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        }
    }
}
