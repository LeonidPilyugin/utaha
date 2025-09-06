namespace Utaha.App
{
    public class Application : Object
    {
        private Options options;
        private Formatter formatter;
        private Selection selection;

        public Application()
        {
            selection = new Selection(Utaha.Core.Storage.get_storage().iterator());
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
            perform_operation();
        }

        public void perform_operation() throws ApplicationError
        {
            Operation op;
            if (options.start)
                op = new StartOperation();
            else if (options.stop)
                op = new StopOperation();
            else if (options.remove)
                op = new RemoveOperation();
            else if (options.status)
                op = new StatusOperation();
            else if (options.list)
                op = new ListOperation();
            else if (options.count)
                op = new CountOperation();
            else
                assert_not_reached();

            @foreach(op);

            stdout.printf(op.print());
        }

        public void set_selectors()
        {
            if (options.active)
                selection.append(new Selector.active());
            if (options.inactive)
                selection.append(new Selector.inactive());
            if (options.ids != null)
                selection.append(new Selector.id(options.ids));
            if (options.aliases != null)
                selection.append(new Selector.alias(options.aliases));
            if (options.alias_regex != null)
                selection.append(new Selector.alias_regex(options.alias_regex));
        }

        public void @foreach(Operation operation) throws ApplicationError
        {
            foreach (var task in selection)
                operation.try_perform(task);
        }

        public void version()
        {
            stdout.printf(@"utaha version $VERSION\n");
        }

        public void load_file(string path)
        {
            try
            {
                var task = Utaha.Core.Serialization.Initializable.initialize<Utaha.Core.Task>(
                    new Utaha.Core.Serialization.JsonReader().read_file(path)
                );

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
