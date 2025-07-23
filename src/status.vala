namespace Utaha.App
{
    static void status_one(Utaha.Core.Id id) throws Error
    {
        try
        {
            var task = Utaha.Core.Storage.get_storage().get_task(id);
            var ht = task.status().as_hash_table();

            foreach (unowned string key in ht.get_keys())
                stdout.printf(@"$key: $(ht.get(key))\n");
        } catch (Utaha.Core.StorageError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.StorableError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        } catch (Utaha.Core.BackendError e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        }
    }

    static void status(List<Utaha.Core.Id?> ids) throws Error
    {
        foreach (unowned var id in ids)
            status_one(id);
    }
}
