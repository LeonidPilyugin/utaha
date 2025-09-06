namespace Utaha.App
{
    public class ListOperation : Operation
    {
        private List<Utaha.Core.Task> tasks = new List<Utaha.Core.Task>();

        public override void perform(Utaha.Core.Task task) throws OperationError
        {
            tasks.append(task);
        }

        public override string print()
        {
            string result = "";

            foreach (var t in tasks)
                result = @"$result$(t.taskdata.id.uuid)\n";

            return result;
        }
    }
}
