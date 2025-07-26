namespace Utaha.App
{
    public class SelectorIterator
    {
        private Utaha.Core.TaskIterator iterator;
        private unowned List<Selector> selectors;

        public SelectorIterator(Utaha.Core.TaskIterator iterator, List<Selector> selectors)
        {
            this.iterator = iterator;
            this.selectors = selectors;
        }

        public Utaha.Core.Task? next() throws Utaha.Core.StorableError, Utaha.Core.StorageError
        {
            Utaha.Core.Task? task;
            while (null != (task = iterator.next()) && !Selector.all(task, selectors));
            return task;
        }
    }
}
