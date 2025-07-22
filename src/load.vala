namespace Utaha.App
{
    static void load_file(string file) throws Error
    {
        try
        {
            var parser = new Json.Parser();
            parser.load_from_file(file);

            var task = Utaha.Core.IJsonable.load_json<Utaha.Core.Task>(parser.get_root().get_object());

            task.node = Utaha.Core.Storage.get_storage().create_node(task.taskdata.id);
            task.init();
            task.dump();
        } catch (GLib.Error e)
        {
            throw new Error.RUNTIME_ERROR(e.message);
        }
    }

    static void load(List<string> files) throws Error
    {
        foreach (unowned string file in files)
            load_file(file);
    }
}
