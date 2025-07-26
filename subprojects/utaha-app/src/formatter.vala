namespace Utaha.App
{
    public class Formatter
    {
        private unowned FileStream stream = stdout;
        private string date_format = "%H:%M:%S %d.%m.%y";
        private uint offset = 4;
        private uint tail_lines = 5;

        private void print(string str, uint offset=0)
        {
            foreach (unowned var s in str.split("\n"))
            {
                for (uint i = 0; i < offset; i++) stream.puts(" ");
                stream.puts(s);
                stream.puts("\n");
            }
        }

        private void print_header(Utaha.Core.TaskStatus status)
        {
            print(@"Task \"$(status.taskdata.alias)\" ($(status.taskdata.id.uuid))");
            print(@"$(status.taskdata.comment)", offset);
        }

        private void print_loaded(Utaha.Core.TaskStatus status)
        {
            var load_date = status.taskdata.load_date;
            string line;
            line = "Loaded: ";
            line += load_date.format(date_format);
            line += @" ($(difference(load_date)) ago)";
            print(line, offset);
        }

        private void print_active(Utaha.Core.TaskStatus status)
        {
            string line = "Active: ";
            if (status.backend_status.active)
            {
                line += "\x1b[32mactive\x1b[0m";
                if (status.taskdata.start_date != null)
                {
                    var d = status.taskdata.start_date;
                    line += @" since $(d.format(date_format)) (";
                    line += @"$(difference(d)) ago)";
                }
            } else
            {
                line += "\x1b[31minactive\x1b[0m";
                if (status.wrapper_status.last_active != null)
                {
                    var d = status.wrapper_status.last_active;
                    line += @" since $(d.format(date_format)) (";
                    line += @"$(difference(d)) ago)";
                }
            }
            print(line, offset);
        }

        private string tail_file(uint lines, string path) throws FormatterError
        {
            try
            {
                string sout, serr;
                int status;
                Process.spawn_command_line_sync(
                    @"tail -$lines $path", out sout, out serr, out status
                );

                if (status != 0) throw new FormatterError.ERROR("Tail failed");

                return sout;
            } catch (SpawnError e)
            {
                throw new FormatterError.ERROR(e.message);
            }
        }

        private void print_stdout(Utaha.Core.TaskStatus status) throws FormatterError
        {
            print("stdout:", offset);
            print(tail_file(tail_lines, status.stdout_path), 2 * offset);
        }

        private void print_stderr(Utaha.Core.TaskStatus status) throws FormatterError
        {
            print("stderr:", offset);
            print(tail_file(tail_lines, status.stderr_path), 2 * offset);
        }

        private void print_backend_status(Utaha.Core.TaskStatus status)
        {
            print(status.backend_status.backend_type.name() + " backend:", offset);
            var ht = status.backend_status.as_hash_table();
            foreach (unowned var key in ht.get_keys())
                print(key + ": " + ht.get(key), 2 * offset);
        }

        private void print_wrapper_status(Utaha.Core.TaskStatus status)
        {
            print(status.wrapper_status.wrapper_type.name() + " wrapper:", offset);
            var ht = status.wrapper_status.as_hash_table();
            foreach (unowned var key in ht.get_keys())
                print(key + ": " + ht.get(key), 2 * offset);
        }

        public void print_status(Utaha.Core.TaskStatus status) throws FormatterError
        {
            print_header(status);
            print_loaded(status);
            print_active(status);
            print_backend_status(status);
            print_wrapper_status(status);
            print_stdout(status);
            print_stderr(status);
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
