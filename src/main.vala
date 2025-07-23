static int main(string[] args)
{
    try
    {
        new Utaha.App.Application().start(args);
    } catch (Utaha.App.ApplicationError e)
    {
        printerr(e.message);
        return 1;
    }
    return 0;
}
