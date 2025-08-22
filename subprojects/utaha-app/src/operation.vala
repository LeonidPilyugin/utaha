namespace Utaha.App
{
    public class Operation
    {
        private struct Data
        {
            uint * count;
            Formatter formatter;
        }

        private Data data;

        [CCode (has_target = false)] // Memory leak otherwise (T_T)
        private delegate void OperationFunc (Utaha.Core.Task task, Data data) throws OperationError;

        private OperationFunc operation;

        private Operation(OperationFunc f)
        {
            operation = f;
        }

        public Operation.start()
        {
            operation = (task, data) => {
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
            operation = (task, data) => {
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
            operation = (task, data) => {
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
            data.formatter = formatter;
            operation = (task, data) => {
                try
                {
                    data.formatter.print_status(task.status());
                } catch (Utaha.Core.BackendError e)
                {
                    throw new OperationError.ERROR(e.message);
                }
            };
        }

        public Operation.list()
        {
            operation = (task, data) => {
                stdout.printf(@"$(task.taskdata.id.uuid): $(task.taskdata.alias)\n");
            };
        }

        public Operation.count(uint * count)
        {
            data.count = count;
            *count = 0;
            operation = (task, data) => {
                *data.count += 1;
            };
        }

        public void perform(Utaha.Core.Task task) throws OperationError
        {
            operation(task, data);
        }

        public void try_perform(Utaha.Core.Task task)
        {
            try { perform(task); }
            catch (OperationError e) { printerr(e.message); }
        }
    }
}
