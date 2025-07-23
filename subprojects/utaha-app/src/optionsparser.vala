namespace Utaha.App
{
    public struct Options
    {
        bool version;
        bool active;
        bool inactive;
        bool start;
        bool stop;
        bool status;
        bool remove;
        bool list;
        [CCode (array_length = false, array_null_terminated = true)]
        string[]? descriptors;

        public bool load { get { return descriptors != null; } }
    }

    public class OptionsParser
    {
        private OptionsParser() { }

        private const OptionEntry[] main_options =
        {
            { "version", '\0', OptionFlags.NONE, OptionArg.NONE, ref version, "Display version number", null },
            { null }
        };

        private const OptionEntry[] selection_options =
        {
            { "active", '\0', OptionFlags.NONE, OptionArg.NONE, ref active, "Select only active tasks", null },
            { "inactive", '\0', OptionFlags.NONE, OptionArg.NONE, ref inactive, "Select only inactive tasks", null },
            { null }
        };

        private const OptionEntry[] operation_options =
        {
            { "start", '\0', OptionFlags.NONE, OptionArg.NONE, ref start, "Start selected tasks", null },
            { "stop", '\0', OptionFlags.NONE, OptionArg.NONE, ref stop, "Stop selected tasks", null },
            { "status", '\0', OptionFlags.NONE, OptionArg.NONE, ref status, "Show status of selected tasks", null },
            { "remove", '\0', OptionFlags.NONE, OptionArg.NONE, ref remove, "Remove selected tasks", null },
            { "list", '\0', OptionFlags.NONE, OptionArg.NONE, ref list, "List tasks IDs", null },
            { null }
        };

        private const OptionEntry[] load_options =
        {
            { "load", '\0', OptionFlags.NONE, OptionArg.FILENAME_ARRAY, ref descriptors, "Task descriptor file", "FILE" },
            { null }
        };

        private static bool version = false;
        private static bool active = false;
        private static bool inactive = false;
        private static bool start = false;
        private static bool stop = false;
        private static bool status = false;
        private static bool remove = false;
        private static bool list = false;
        [CCode (array_length = false, array_null_terminated = true)]
        private static string[]? descriptors = null;

        private static Options get_options()
        {
            return Options()
            {
                version = version,
                active = active,
                inactive = inactive,
                start = start,
                stop = stop,
                status = status,
                remove = remove,
                descriptors = descriptors,
                list = list
            };
        }

        private static OptionContext context;

        private const string description_string = """TODO: put description here""";
        private const string summary_string = """Utility for Task Handling""";

        public static void init()
        {
            context = new OptionContext();
            context.set_help_enabled(true);

            // context.set_description(description_string);
            context.set_summary(summary_string);

			context.add_main_entries(main_options, null);

            var selection_group = new OptionGroup(
                "selection",
                "Selection Options:",
                "Show selection options"
            );
            selection_group.add_entries(selection_options);
            context.add_group(selection_group);

            var operation_group = new OptionGroup(
                "operation",
                "Operation Options:",
                "Show operation options"
            );
            operation_group.add_entries(operation_options);
            context.add_group(operation_group);

            var load_group = new OptionGroup(
                "load",
                "Load Options:",
                "Show load options"
            );
            load_group.add_entries(load_options);
            context.add_group(load_group);
        }

        public static Options parse(ref unowned string[] args) throws OptionError
        {
			context.parse(ref args);
            return get_options();
        }

    }
}
