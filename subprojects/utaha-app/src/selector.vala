namespace Utaha.App
{
    public class Selector : Object
    {
        private delegate bool Filter (Utaha.Core.Task task);

        private Filter filter;

        private Selector() { }

        public Selector.active()
        {
            this.filter = (task) => {
                try
                {
                    return task.status().backend_status.active;
                } catch (Utaha.Core.BackendError e)
                {
                    printerr(@"$(e.message)\n");
                }
                return false;
            };
        }

        public Selector.inactive()
        {
            this.filter = (task) => {
                try
                {
                    return !task.status().backend_status.active;
                } catch (Utaha.Core.BackendError e)
                {
                    printerr(@"$(e.message)\n");
                }
                return false;
            };
        }

        public Selector.id(Utaha.Core.Id[] ids)
        {
            this.filter = (task) => {
                bool selected = false;
                foreach (unowned var id in ids)
                    if (selected |= Utaha.Core.Id.equal(id, task.taskdata.id))
                        return true;
                return false;
            };
        }

        public Selector.alias(string[] aliases)
        {
            this.filter = (task) => {
                bool selected = false;
                foreach (var alias in aliases)
                    if (selected |= alias == task.taskdata.alias)
                        return true;
                return false;
            };
        }

        public Selector.alias_regex(Regex regex)
        {
            this.filter = (task) => {
                return regex.match(task.taskdata.alias);
            };
        }

        public bool is_selected(Utaha.Core.Task task)
        {
            return this.filter(task);
        }

        public static bool all(Utaha.Core.Task task, List<Selector> selectors)
        {
            bool selected = true;
            foreach (Selector s in selectors)
                if (!(selected &= s.is_selected(task))) return false;
            return selected;
        }
    }
}
