namespace Utaha.App
{
    public class CountOperation : Operation
    {
        private uint counter = 0;

        public override void perform(Utaha.Core.Task task) throws OperationError
        {
            counter++;
        }

        class Result : Operation.Result
        {
            private uint counter;

            public Result(uint counter)
            {
                this.counter = counter;
            }

            protected override void format()
            {
                assert(null != formatter);
                formatter.put<string>(counter.to_string());
                formatter.put<Formatter.Symbol>(Formatter.Symbol.NEW_LINE);
            }
        }

        public override Operation.Result result
        {
            owned get
            {
                return new Result(counter);
            }
        }
    }
}
