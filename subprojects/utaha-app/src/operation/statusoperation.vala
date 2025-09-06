namespace Utaha.App
{
    public class StatusOperation : Operation
    {
        private List<Utaha.Core.TaskStatus> statuses = new List<Utaha.Core.TaskStatus>();

        public override void perform(Utaha.Core.Task task) throws OperationError
        {
            try
            {
                statuses.append(task.status());
            } catch (Utaha.Core.BackendError e)
            {
                throw new OperationError.ERROR(e.message);
            }
        }

        public override string print()
        {
            string result = "";

            foreach (var t in statuses)
                result = @"$result$(t.taskdata.id.uuid)\n";

            return result;
        }
    }
}
