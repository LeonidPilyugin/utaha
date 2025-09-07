namespace Utaha.App
{
    public class DefaultFormatter : Formatter
    {
        private StringBuilder builder = new StringBuilder();
        private const string DATE_FORMAT = "%H:%M:%S %d.%m.%y";
        private bool should_indent = true;

        private void put_indent()
        {
            if (should_indent) for (uint i = 0; i < indent; i++) builder.append(" ");
            should_indent = false;
        }

        protected override void put_symbol(Symbol item, FormatOptions? o)
        {
            switch (item)
            {
                case Formatter.Symbol.RIGHT_ARROW:
                    put_string("->", o); break;
                case Formatter.Symbol.LEFT_ARROW:
                    put_string("<-", o); break;
                case Formatter.Symbol.SPACE:
                    put_string(" ", o); break;
                case Formatter.Symbol.NEW_LINE:
                    put_string("\n", o); should_indent = true; break;
                case Formatter.Symbol.RIGHT_BRACKET:
                    put_string(")", o); break;
                case Formatter.Symbol.LEFT_BRACKET:
                    put_string("(", o); break;
                default: assert_not_reached();
            }
        }

        protected override void put_datetime(DateTime item, FormatOptions? o)
        {
            put_string(item.format(DefaultFormatter.DATE_FORMAT), o);
            put_string(" (", o);
            put_timespan(new DateTime.now().difference(item), o);
            put_string(" ago)", o);
        }

        private void put_color(Formatter.Color c)
        {
            switch (c)
            {
                case Formatter.Color.DEFAULT:
                    builder.append("9"); break;
                case Formatter.Color.BLACK:
                    builder.append("0"); break;
                case Formatter.Color.RED:
                    builder.append("1"); break;
                case Formatter.Color.GREEN:
                    builder.append("2"); break;
                case Formatter.Color.YELLOW:
                    builder.append("3"); break;
                case Formatter.Color.BLUE:
                    builder.append("4"); break;
                case Formatter.Color.MAGENTA:
                    builder.append("5"); break;
                case Formatter.Color.CYAN:
                    builder.append("6"); break;
                case Formatter.Color.WHITE:
                    builder.append("7"); break;
                default: assert_not_reached();
            }
        }

        private void put_format_option(FormatOptions o)
        {
            builder.append("\x1b[3");
            put_color(o.fg_color);
            builder.append(";4");
            put_color(o.bg_color);
            if (0 != (o.style & Formatter.Style.BOLD))
                builder.append(";1");
            if (0 != (o.style & Formatter.Style.ITALIC))
                builder.append(";3");
            if (0 != (o.style & Formatter.Style.UNDERLINE))
                builder.append(";4");
            if (0 != (o.style & Formatter.Style.STRIKETHROUGH))
                builder.append(";9");
            builder.append("m");
        }

        private void reset_format_option()
        {
            builder.append("\x1b[0m");
        }

        protected override void put_timespan(TimeSpan diff, FormatOptions? o)
        {
            var days = diff / TimeSpan.DAY;
            diff %= TimeSpan.DAY;
            var hours = diff / TimeSpan.HOUR;
            diff %= TimeSpan.HOUR;
            var minutes = diff / TimeSpan.MINUTE;
            diff %= TimeSpan.MINUTE;
            var seconds = diff / TimeSpan.SECOND;
            diff %= TimeSpan.SECOND;

            string res = "";
            if (days > 0) res += @"$(days)d ";
            if (hours > 0) res += @"$(hours)h ";
            if (minutes > 0) res += @"$(minutes)m ";
            res += @"$(seconds)s";

            put_string(res, o);
        }

        protected override void put_string(string item, FormatOptions? o)
        {
            put_indent();
            if (null != o) put_format_option(o);
            builder.append(item);
            if (null != o) reset_format_option();
        }

        public override string compile()
        {
            return builder.str;
        }
    }
}
