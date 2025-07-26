namespace Utaha.App
{
    public class Operation : Object
    {
        private delegate void OperationFunc (Utaha.Core.Task task) throws OperationError;

        private OperationFunc operation;

        private Operation() { }

        public Operation.start()
        {
            this.operation = (task) => {
                try
                {
                    task.start();
                } catch (Utaha.Core.BackendError e)
                {
                    throw new OperationError.ERROR(e.message);
                }
            };
        }

        public Operation.stop()
        {
            this.operation = (task) => {
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
            };
        }

        public Operation.remove()
        {
            this.operation = (task) => {
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
            };
        }

        public Operation.status(Formatter formatter)
        {
            this.operation = (task) => {
                try
                {
                    formatter.print_status(task.status());
                } catch (Utaha.Core.BackendError e)
                {
                    throw new OperationError.ERROR(e.message);
                }
            };
        }

        public Operation.list()
        {
            this.operation = (task) => {
                stdout.printf(@"$(task.taskdata.id.uuid)\n");
            };
        }

        public Operation.count(uint * count)
        {
            *count = 0;
            this.operation = (task) => {
                *count += 1;
            };
        }

        public void perform(Utaha.Core.Task task) throws OperationError
        {
            this.operation(task);
        }

        public void try_perform(Utaha.Core.Task task)
        {
            try { perform(task); }
            catch (OperationError e) { printerr(e.message); }
        }
    }
}
