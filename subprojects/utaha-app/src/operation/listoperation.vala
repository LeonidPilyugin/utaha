namespace Utaha.App
{
    public class ListOperation : Operation
    {
        private List<Utaha.Core.Task> tasks = new List<Utaha.Core.Task>();

        public override void perform(Utaha.Core.Task task) throws OperationError
        {
            tasks.append(task);
        }

        class Result : Operation.Result
        {
            private unowned List<Utaha.Core.Task> tasks;

            public Result(List<Utaha.Core.Task> tasks)
            {
                this.tasks = tasks;
            }

            protected override void format()
            {
                assert(null != formatter);
                foreach (var t in tasks)
                {
                    formatter.put<string>(t.taskdata.id.uuid);
                    formatter.put<Formatter.Symbol>(Formatter.Symbol.SPACE);
                    formatter.put<Formatter.Symbol>(Formatter.Symbol.LEFT_ARROW);
                    formatter.put<Formatter.Symbol>(Formatter.Symbol.SPACE);
                    formatter.put<string>(t.taskdata.alias);
                    formatter.put<Formatter.Symbol>(Formatter.Symbol.NEW_LINE);
                }
            }
        }

        public override Operation.Result result
        {
            owned get
            {
                return new Result(tasks);
            }
        }
    }
}
