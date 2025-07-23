namespace Utaha.Core
{
    public sealed class TaskIterator
    {
        private Id[] ids;
        private int index;
        private Storage storage;

        internal TaskIterator(List<string> ids) throws IdError, StorageError
        {
            this.ids = new Id[ids.length()];
            int i = 0;
            foreach (unowned var id in ids)
                this.ids[i++] = Id.from_string(id);
            index = 0;
            storage = Storage.get_storage();
        }

        public Task? next() throws StorableError, StorageError
        {
            if (index < ids.length)
                return storage.get_task(ids[index++]);
            return null;
        }
    }
}
