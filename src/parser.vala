namespace Utaha.App
{
    class Parser
    {
        public bool load { get; private set; }
        public bool start { get; private set; }
        public bool list { get; private set; }
        public bool remove { get; private set; }
        public bool status { get; private set; }
        public bool stop { get; private set; }
        public List<Utaha.Core.Id?> ids { get; private owned set; }
        public List<string> files { get; private owned set; }

        public Parser(string[] args) throws Error
        {
            try
            {
                var ids = new List<Utaha.Core.Id?>();
                var files = new List<string>();

                load = args[1] == "load";
                start = args[1] == "start";
                list = args[1] == "list";
                status = args[1] == "status";
                remove = args[1] == "remove";
                stop = args[1] == "stop";

                if (start || status || remove || stop)
                    for (int i = 2; i < args.length; i++)
                        ids.append(Utaha.Core.Id.from_string(args[i]));
                if (load)
                    for (int i = 2; i < args.length; i++)
                        files.append(args[i]);
                this.ids = (owned) ids;
                this.files = (owned) files;
            } catch (Utaha.Core.IdError e) {
                throw new Error.RUNTIME_ERROR(e.message);
            }
        }
    }
}
