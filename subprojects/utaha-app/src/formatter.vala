namespace Utaha.App
{
    public class Formatter
    {
        private unowned FileStream stream;
        private string date_format;

        public Formatter()
        {
            stream = stdout;
            date_format = "%H:%M:%S %d.%m.%y";
        }

        public void print_status(Utaha.Core.TaskStatus status)
        {
            stream.printf(@"$(status.taskdata.id.uuid) ($(status.taskdata.alias))\n");
            stream.printf(@"$(status.taskdata.comment)\n");

            stream.printf("\n");

            stream.printf(@"Loaded: ");
            stream.printf(status.taskdata.birth_date.format(date_format));
            stream.printf("\n");

            stream.printf("Active: ");
            stream.printf(status.backend_status.active ? "\x1b[32mactive\x1b[0m" : "\x1b[31minactive\x1b[0m");
            stream.printf("\n");
        }
    }
}
