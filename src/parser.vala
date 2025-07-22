namespace Utaha.App
{
    /**
     * start uuid or stdin
     *
     * stop uuid or stdin
     *
     * status uuid or stdin
     *
     * load toml or stdin
     *
     * remove uuid or stdin
     *
     * list / table
     * no args -- list all tasks
     * --uuid -- list obly with uuids
     * --regex -- use regex
     * --alias -- use alias
     * --comment -- use comment
     * --last= -- show only last files
     */
    class Parser
    {
        public bool load { get; private set; }
        public bool start { get; private set; }
        public bool list { get; private set; }
        public bool remove { get; private set; }
        public bool status { get; private set; }
        public Utaha.Core.Id? id { get; private set; }
        public string? file { get; private set; }

        public Parser(string[] args)
        {
            load = args[1] == "load";
            start = args[1] == "start";
            list = args[1] == "list";
            status = args[1] == "status";
            remove = args[1] == "remove";

            if (start || status || remove) id = Utaha.Core.Id.from_string(args[2]);
            else id = null;
            file = load ? args[2] : null;
        }
    }
}
