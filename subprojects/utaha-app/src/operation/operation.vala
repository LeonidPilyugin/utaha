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

        public virtual string print()
        {
            return "";
        }
    }
}
