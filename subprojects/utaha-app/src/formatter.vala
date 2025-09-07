namespace Utaha.App
{
    public abstract class Formatter
    {
        [Flags]
        public enum Style
        {
            BOLD,
            ITALIC,
            UNDERLINE,
            STRIKETHROUGH,
        }

        public enum Color
        {
            DEFAULT,
            BLACK,
            RED,
            GREEN,
            YELLOW,
            BLUE,
            MAGENTA,
            CYAN,
            WHITE,
        }

        public struct FormatOptions
        {
            public Style style;
            public Color fg_color;
            public Color bg_color;
        }

        public enum Symbol
        {
            RIGHT_ARROW,
            LEFT_ARROW,
            NEW_LINE,
            SPACE,
            LEFT_BRACKET,
            RIGHT_BRACKET,
        }

        public void put<T>(T item, FormatOptions? o = null)
        {
            if (typeof(T) == typeof(Symbol))
                put_symbol((Symbol) item, o);
            else if (typeof(T) == typeof(DateTime))
                put_datetime((DateTime) item, o);
            else if (typeof(T) == typeof(TimeSpan))
                put_timespan((TimeSpan) item, o);
            else if (typeof(T) == typeof(string))
                put_string((string) item, o);
            else
                assert_not_reached();
        }

        protected abstract void put_symbol(Symbol item, FormatOptions? o);

        protected abstract void put_datetime(DateTime item, FormatOptions? o);

        protected abstract void put_timespan(TimeSpan item, FormatOptions? o);

        protected abstract void put_string(string item, FormatOptions? o);

        public uint indent { get; set; }

        public abstract string compile();
    }
}
