namespace Utaha.App
{
    public class StopOperation : Operation
    {
        public override void perform(Utaha.Core.Task task) throws OperationError
        {
            try
            {
                task.stop();
            } catch (Utaha.Core.TaskError e)
            {
                throw new OperationError.ERROR(e.message);
            } catch (Utaha.Core.BackendError e)
            {
                throw new OperationError.ERROR(e.message);
            }
        }
    }
}
