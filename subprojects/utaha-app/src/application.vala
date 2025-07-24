namespace Utaha.App
{
    public class Application : Object
    {
        private Options options;
        private List<Selector> selectors;
        private Formatter formatter;

        public Application()
        {
            selectors = new List<Selector>();
            formatter = new Formatter();
        }

        public void load_modules() throws ApplicationError
        {
            try
            {
                Utaha.Core.load_modules();
            } catch (Utaha.Core.ModuleError e)
            {
                throw new ApplicationError.ERROR(e.message);
            }
        }

        public void start(string[] args) throws ApplicationError
        {
            load_modules();
            try
            {
                OptionsParser.init();
                options = OptionsParser.parse(ref args);
            } catch (OptionError e)
            {
                throw new ApplicationError.OPTION_ERROR(e.message);
            }

            if (options.version)
            {
                version();
                return;
            }

            if (options.load)
            {
                load();
                return;
            }

            set_selectors();

            if (options.start)
            {
                @foreach((task) => {
                    try
                    {
                        task.start();
                    } catch (Utaha.Core.BackendError e)
                    {
                        throw new ApplicationError.ERROR(e.message);
                    }
                });
                return;
            }

            if (options.stop)
            {
                @foreach((task) => {
                    try
                    {
                        task.stop();
                    } catch (Utaha.Core.BackendError e)
                    {
                        throw new ApplicationError.ERROR(e.message);
                    } catch (Utaha.Core.TaskError e)
                    {
                        throw new ApplicationError.ERROR(e.message);
                    }
                });
                return;
            }

            if (options.remove)
            {
                @foreach((task) => {
                    try
                    {
                        task.destroy();
                    } catch (Utaha.Core.BackendError e)
                    {
                        throw new ApplicationError.ERROR(e.message);
                    } catch (Utaha.Core.TaskError e)
                    {
                        throw new ApplicationError.ERROR(e.message);
                    } catch (Utaha.Core.StorableError e)
                    {
                        throw new ApplicationError.ERROR(e.message);
                    }
                });
                return;
            }

            if (options.status)
            {
                @foreach((task) => {
                    try
                    {
                        formatter.print_status(task.status());
                    } catch (Utaha.Core.BackendError e)
                    {
                        throw new ApplicationError.ERROR(e.message);
                    }
                });
                return;
            }

            if (options.list)
            {
                @foreach((task) => {
                    stdout.printf(@"$(task.taskdata.id.uuid)\n");
                });
            }
        }

        public void set_selectors()
        {
            if (options.active)
            {
                selectors.append(new Selector((task) => {
                    try
                    {
                        return task.status().backend_status.active;
                    } catch (Utaha.Core.BackendError e)
                    {
                        printerr(@"$(e.message)\n");
                    }
                    return false;
                }));
            }

            if (options.inactive)
            {
                selectors.append(new Selector((task) => {
                    try
                    {
                        return !task.status().backend_status.active;
                    } catch (Utaha.Core.BackendError e)
                    {
                        printerr(@"$(e.message)\n");
                    }
                    return false;
                }));
            }
        }

        public delegate void TaskOperation (Utaha.Core.Task task) throws ApplicationError;

        public void @foreach(TaskOperation operation)
        {
            try
            {
                var iter = Utaha.Core.Storage.get_storage().iterator();
                Utaha.Core.Task? task;

                while (null != (task = iter.next()))
                {
                    if (Selector.all(task, selectors))
                    {
                        try
                        {
                            operation(task);
                        } catch (ApplicationError e)
                        {
                            printerr(e.message + "\n");
                        }
                    }
                }
            } catch (Utaha.Core.StorageError e)
            {
                printerr(e.message + "\n");
            } catch (Utaha.Core.StorableError e)
            {
                printerr(e.message + "\n");
            }
        }

        public void version()
        {
            stdout.printf(@"utaha version $VERSION\n");
        }

        public void load_file(string path)
        {
            try
            {
                var parser = new Json.Parser();
                parser.load_from_file(path);
                var task = Utaha.Core.IJsonable.load_json<Utaha.Core.Task>(parser.get_root().get_object());

                task.node = Utaha.Core.Storage.get_storage().create_node(task.taskdata.id);
                task.init();
                task.dump();
            } catch (Error e)
            {
                printerr(@"$(e.message)\n");
            }
        }

        public void load()
        {
            foreach (unowned string file in options.descriptors)
            {
                load_file(file);
            }
        }
    }
}
