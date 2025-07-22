namespace Utaha.App
{
    static void remove(Utaha.Core.Id id)
    {
        Utaha.Core.Task task = Utaha.Core.Storage.get_storage().get_task(id);
        task.remove();
    }
}
