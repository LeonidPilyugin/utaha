namespace Utaha.App
{
    static void status(Utaha.Core.Id id)
    {
        Utaha.Core.Task task = Utaha.Core.Storage.get_storage().get_task(id);
        var ht = task.status().as_hash_table();

        foreach (unowned string key in ht.get_keys())
            stdout.printf(@"$key: $(ht.get(key))\n");
    }
}
