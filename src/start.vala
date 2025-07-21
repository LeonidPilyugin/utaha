namespace Utaha.App
{
    static void start(Utaha.Core.Id id)
    {
        Utaha.Core.Task task = Utaha.Core.Storage.get_storage().get_task(id);
        task.start();
    }
}
