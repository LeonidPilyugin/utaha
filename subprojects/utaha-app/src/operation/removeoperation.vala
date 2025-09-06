namespace Utaha.App
{
    public class RemoveOperation : Operation
    {
        public override void perform(Utaha.Core.Task task) throws OperationError
        {
            try
            {
                task.destroy();
            } catch (Utaha.Core.StorableError e)
            {
                throw new OperationError.ERROR(e.message);
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
