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
            perform_operation();
        }

        public void perform_operation() throws ApplicationError
        {
            if (options.start)
                @foreach(new Operation.start());
            else if (options.stop)
                @foreach(new Operation.stop());
            else if (options.remove)
                @foreach(new Operation.remove());
            else if (options.status)
                @foreach(new Operation.status(formatter));
            else if (options.list)
                @foreach(new Operation.list());
            else if (options.count)
            {
                uint count = 0;
                @foreach(new Operation.count(&count));
                stdout.printf(@"$count\n");
            }
        }

        public void set_selectors()
        {
            if (options.active)
                selectors.append(new Selector.active());
            if (options.inactive)
                selectors.append(new Selector.inactive());
            if (options.ids != null)
                selectors.append(new Selector.id(options.ids));
            if (options.aliases != null)
                selectors.append(new Selector.alias(options.aliases));
            if (options.alias_regex != null)
                selectors.append(new Selector.alias_regex(options.alias_regex));
        }

        public void @foreach(Operation operation) throws ApplicationError
        {
            try
            {
                var iter = new SelectorIterator(Utaha.Core.Storage.get_storage().iterator(), selectors);
                Utaha.Core.Task? task;

                while (null != (task = iter.next()))
                    operation.try_perform(task);
            } catch (Utaha.Core.StorageError e)
            {
                throw new ApplicationError.ERROR(e.message);
            } catch (Utaha.Core.StorableError e)
            {
                throw new ApplicationError.ERROR(e.message);
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
