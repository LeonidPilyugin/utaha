namespace Utaha.ScreenBackend
{
    public errordomain ScreenError
    {
        PARSE_ERROR,
        SPAWN_ERROR,
        SCREEN_ERROR
    }

    [Immutable]
    public class Session : Object
    {
        private int? pid;

        public int? get_pid()
        {
            return pid;
        }

        public string? id { get; private set; }

        public Session(int? pid, string? id)
        {
            this.pid = pid;
            this.id = id;
        }
    }

    public class Screen : Object
    {
        private Regex session_regex;

        public Screen()
        {
            try
            {
                session_regex = new Regex("""^\s*(\d+)\.(.+)\s\(\w+\)$""");
            } catch (RegexError e)
            {
                error(@"Unexpected error $(e.message)");
            }
        }

        private Session get_session(MatchInfo match) throws ScreenError
        {
            string? first = match.fetch(1);
            string? second = match.fetch(2);
            if (first == null || second == null)
                throw new ScreenError.PARSE_ERROR(@"Cannot parse \"$(match.fetch(0))\"");

            return new Session(
                int.parse(first),
                second
            );
        }

        public List<Session> list_sessions() throws ScreenError
        {
            var result = new List<Session>();

            string sout, serr;
            int status;

            try
            {
                Process.spawn_command_line_sync(
                    "screen -list", out sout, out serr, out status
                );
            } catch (SpawnError e)
            {
                throw new ScreenError.SPAWN_ERROR("Cannot spawn screen process");
            }

            MatchInfo match_info;
            foreach (unowned string str in sout.split("\n"))
                if (session_regex.match(str, 0, out match_info))
                    result.append(get_session(match_info));

            return result;
        }

        public Session? find_session(string id) throws ScreenError
        {
            string sout, serr;
            int status;

            try
            {
                Process.spawn_command_line_sync(
                    "screen -list", out sout, out serr, out status
                );
            } catch (SpawnError e)
            {
                throw new ScreenError.SPAWN_ERROR("Cannot spawn screen process");
            }

            MatchInfo match_info;
            foreach (unowned string str in sout.split("\n"))
                if (id in str)
                    if (session_regex.match(str, 0, out match_info))
                        return get_session(match_info);

            return new Session(null, null);
        }

        public void submit(string id, string[] command) throws ScreenError
        {
            string sout, serr;
            int status;

            string cmd = "screen -dmS " + Shell.quote(id);
            foreach (unowned string str in command)
                cmd += " " + Shell.quote(str);

            try {
                Process.spawn_command_line_sync(cmd, out sout, out serr, out status);
            } catch (SpawnError e)
            {
                throw new ScreenError.SPAWN_ERROR("Cannot spawn screen process");
            }

            if (status != 0)
                throw new ScreenError.SCREEN_ERROR("Screen failed");
        }

        public void cancel(string id) throws ScreenError
        {
            string sout, serr;
            int status;

            try {
                Process.spawn_command_line_sync(
                    @"screen -x $(Shell.quote(id)) -X quit",
                    out sout, out serr, out status
                );
            } catch (SpawnError e)
            {
                throw new ScreenError.SPAWN_ERROR("Cannot spawn screen process");
            }

            if (status != 0)
                throw new ScreenError.SCREEN_ERROR("Screen failed");
        }
    }
}
