namespace Utaha.App
{
    public class Selection : Object, Gee.Traversable<Utaha.Core.Task>, Gee.Iterable<Utaha.Core.Task>
    {
        private List<Selector> selectors;
        private Gee.Iterator<Utaha.Core.Task> _iterator;

        public Selection(Gee.Iterator<Utaha.Core.Task> iterator)
        {
            selectors = new List<Selector>();
            _iterator = iterator;
        }

        public void append(Selector selector)
        {
            selectors.append(selector);
        }

        class Iterator : Object, Gee.Traversable<Utaha.Core.Task>, Gee.Iterator<Utaha.Core.Task>
        {
            private Utaha.Core.Task task = null;
            private Utaha.Core.Task next_task = null;
            private unowned List<Selector> selectors;
            private Gee.Iterator<Utaha.Core.Task> iterator;

            public Iterator(List<Selector> selectors, Gee.Iterator<Utaha.Core.Task> iterator)
            {
                this.selectors = selectors;
                this.iterator = iterator;
            }

            public bool read_only { get { return iterator.read_only; } }

            public bool valid { get { return task != null; } }

            public new Utaha.Core.Task get()
            {
                return task;
            }

            public bool has_next()
            {
                return null != next_task;
            }

            public bool next()
            {
                do
                {
                    iterator.foreach((task) => {
                        return !Selector.all(task, selectors);
                    });
                    task = next_task;
                    next_task = iterator.valid ? iterator.get() : null;
                } while (null == task && !(null == task == next_task));

                return valid;
            }

            public void remove() { }

            public bool @foreach(Gee.ForallFunc<Utaha.Core.Task> f)
            {
                bool result = true;
                while (next())
                    if (!(result &= f(get()))) break;
                return result;
            }
        }

        public Gee.Iterator<Utaha.Core.Task> iterator()
        {
            return new Iterator(selectors, _iterator);
        }

        public bool @foreach(Gee.ForallFunc<Utaha.Core.Task> f)
        {
            return iterator().@foreach(f);
        }
    }
}
