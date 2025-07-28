namespace Utaha.App
{
    public class SelectorIteratorBuilder
    {
        private List<Selector> selectors;

        public SelectorIteratorBuilder()
        {
            selectors = new List<Selector>();
        }

        public void add_selector(Selector selector)
        {
            selectors.append(selector);
        }

        public SelectorIterator build(Utaha.Core.TaskIterator iterator)
        {
            return new SelectorIterator(iterator, selectors);
        }
    }
}
