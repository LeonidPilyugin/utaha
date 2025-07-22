namespace Utaha.App
{
    static int main(string[] args)
    {
        try
        {
            Utaha.Core.load_modules();
            Parser parser = new Parser(args);

            if (parser.load) load(parser.file);
            if (parser.remove) remove(parser.id);
            if (parser.start) start(parser.id);
            if (parser.status) status(parser.id);
            if (parser.stop) stop(parser.id);
            if (parser.list) list();

        } catch (Error e)
        {
            critical(e.message);
            return 1;
        }
        return 0;
    }
}
