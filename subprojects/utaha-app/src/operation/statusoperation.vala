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

        class Result : Operation.Result
        {
            private unowned List<Utaha.Core.TaskStatus> statuses;

            public Result(List<Utaha.Core.TaskStatus> statuses)
            {
                this.statuses = statuses;
            }

            private void put_status(Utaha.Core.TaskStatus s)
            {
                var t = s.taskdata;
                var bs = s.backend_status;
                var js = s.job_status;


                formatter.put<string>("Task");
                formatter.put<Formatter.Symbol>(Formatter.Symbol.SPACE);
                formatter.put<string>(t.alias);
                formatter.put<Formatter.Symbol>(Formatter.Symbol.SPACE);
                formatter.put<Formatter.Symbol>(Formatter.Symbol.LEFT_BRACKET);
                formatter.put<string>(t.id.uuid);
                formatter.put<Formatter.Symbol>(Formatter.Symbol.RIGHT_BRACKET);
                formatter.put<Formatter.Symbol>(Formatter.Symbol.NEW_LINE);

                formatter.indent += 4;
                formatter.put<string>("Loaded:");
                formatter.put<Formatter.Symbol>(Formatter.Symbol.SPACE);
                formatter.put<DateTime>(t.load_date);
                formatter.put<Formatter.Symbol>(Formatter.Symbol.NEW_LINE);

                formatter.put<string>("Active:");
                formatter.put<Formatter.Symbol>(Formatter.Symbol.SPACE);
                if (bs.active)
                {
                    formatter.put<string>(
                        "active",
                        Formatter.FormatOptions() {
                            style = Formatter.Style.BOLD,
                            fg_color = Formatter.Color.GREEN,
                            bg_color = Formatter.Color.DEFAULT
                        }
                    );
                    formatter.put<Formatter.Symbol>(Formatter.Symbol.SPACE);
                    formatter.put<string>("since");
                    formatter.put<Formatter.Symbol>(Formatter.Symbol.SPACE);
                    formatter.put<DateTime>(t.start_date);
                } else
                {
                    formatter.put<string>(
                        "inactive",
                        Formatter.FormatOptions() {
                            style = Formatter.Style.BOLD,
                            fg_color = Formatter.Color.RED,
                            bg_color = Formatter.Color.DEFAULT
                        }
                    );
                }
                formatter.put<Formatter.Symbol>(Formatter.Symbol.NEW_LINE);
            }

            protected override void format()
            {
                assert(null != formatter);
                foreach (var s in statuses)
                    put_status(s);
            }
        }

        public override Operation.Result result
        {
            owned get
            {
                return new Result(statuses);
            }
        }
    }
}
