namespace Utaha.App
{
    static void list()
    {
        var tasks = Utaha.Core.Storage.get_storage().list_tasks();
        foreach (Utaha.Core.Task task in tasks)
            stdout.printf(@"$(task.taskdata.id.uuid)\n");
    }
}
