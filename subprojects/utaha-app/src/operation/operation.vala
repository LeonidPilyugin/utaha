namespace Utaha.App
{
    public abstract class Operation
    {
        public abstract void perform(Utaha.Core.Task task) throws OperationError;

        public void try_perform(Utaha.Core.Task task)
        {
            try { perform(task); }
            catch (OperationError e) { printerr(e.message); }
        }

        public abstract class Result
        {
            public Formatter formatter;

            protected abstract void format();

            public string to_string()
            {
                if (null != formatter)
                    format();
                return null == formatter ? "" : formatter.compile();
            }
        }

        public class EmptyResult : Result
        {
            protected override void format() { }
        }

        public virtual Result result
        {
            owned get
            {
                return new EmptyResult();
            }
        }
    }
}
