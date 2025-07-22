namespace Utaha.App
{
    static int main(string[] args)
    {
        try
        {
            Utaha.Core.load_modules();
            Parser parser = new Parser(args);

            if (parser.load) load(parser.files);
            if (parser.remove) remove(parser.ids);
            if (parser.start) start(parser.ids);
            if (parser.status) status(parser.ids);
            if (parser.stop) stop(parser.ids);
            if (parser.list) list();

        } catch (Error e)
        {
            critical(e.message);
            return 1;
        } catch (Utaha.Core.ModuleError e)
        {
            critical(e.message);
            return 1;
        }
        return 0;
    }
}
