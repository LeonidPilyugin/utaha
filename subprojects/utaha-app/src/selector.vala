namespace Utaha.App
{
    public class Selector : Object
    {
        [CCode (has_target = false)]
        public delegate bool Filter (Utaha.Core.Task task);

        private Filter filter;

        public Selector(Filter filter)
        {
            this.filter = filter;
        }

        public bool is_selected(Utaha.Core.Task task)
        {
            return this.filter(task);
        }

        public static bool all(Utaha.Core.Task task, Array<Selector> selectors)
        {
            bool selected = true;
            foreach (Selector s in selectors)
                if (!(selected &= s.is_selected(task))) return false;
            return selected;
        }
    }
}
