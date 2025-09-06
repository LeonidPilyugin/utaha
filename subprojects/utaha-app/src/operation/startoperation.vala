namespace Utaha.App
{
    public class StartOperation : Operation
    {
        public override void perform(Utaha.Core.Task task) throws OperationError
        {
            try
            {
                task.start();
            } catch (Utaha.Core.BackendError e)
            {
                throw new OperationError.ERROR(e.message);
            }
        }
    }
}
