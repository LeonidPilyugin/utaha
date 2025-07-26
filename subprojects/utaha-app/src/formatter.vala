namespace Utaha.App
{
    public class Formatter
    {
        private unowned FileStream stream = stdout;
        private string date_format = "%H:%M:%S %d.%m.%y";

        public void print_status(Utaha.Core.TaskStatus status)
        {
            stream.printf(@"Task \"$(status.taskdata.alias)\" ($(status.taskdata.id.uuid))\n");
            stream.printf(@"$(status.taskdata.comment)\n");

            stream.printf("\n");

            stream.printf(@"Loaded: ");
            var load_date = status.taskdata.load_date;
            stream.printf(@"$(load_date.format(date_format)) ($(difference(load_date)) ago)");
            stream.printf("\n");

            stream.printf("Active: ");

            if (status.backend_status.active)
            {
                stream.printf("\x1b[32mactive\x1b[0m");
                if (status.taskdata.start_date != null)
                {
                    var d = status.taskdata.start_date;
                    stream.printf(@" since $(d.format(date_format)) (");
                    stream.printf(@"$(difference(d)) ago)");
                }
                stream.printf("\n");
            }
            else
            {
                stream.printf("\x1b[31minactive\x1b[0m");
                if (status.wrapper_status.last_active != null)
                {
                    var d = status.wrapper_status.last_active;
                    stream.printf(@" since $(d.format(date_format)) (");
                    stream.printf(@"$(difference(d)) ago)");
                }
                stream.printf("\n");
            }

            stream.printf("\n");

            string sout, serr;
            int rv;

            try
            {
                Process.spawn_command_line_sync(
                    @"tail -5 $(status.stdout_path)", out sout, out serr, out rv
                );
            } catch (SpawnError e)
            {
                error("Cannot spawn tail process");
            }

            if (rv != 0)
                error("Tail failed");

            stream.printf("stdout:\n");
            stream.printf(sout);

            try
            {
                Process.spawn_command_line_sync(
                    @"tail -5 $(status.stderr_path)", out sout, out serr, out rv
                );
            } catch (SpawnError e)
            {
                error("Cannot spawn tail process");
            }

            if (rv != 0)
                error("Tail failed");

            stream.printf("stderr:\n");
            stream.printf(sout);

        }

        private string difference(DateTime d)
        {
            var diff = new DateTime.now().difference(d);
            diff /= 1000000;
            var seconds = diff % 60;
            diff /= 60;
            var minutes = diff % 60;
            diff /= 60;
            var hours = diff % 60;
            var days = diff / 24;

            string result = "";
            if (days > 0) result += @"$(days)d ";
            if (hours > 0) result += @"$(hours)h ";
            if (minutes > 0) result += @"$(minutes)m ";
            result += @"$(seconds)s";
            return result;
        }
    }
}
