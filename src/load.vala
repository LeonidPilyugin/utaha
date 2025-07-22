namespace Utaha.App
{
    static void load(string file) throws Error
    {
        var parser = new Json.Parser();
        parser.load_from_file(file);

        var task = Utaha.Core.IJsonable.load_json<Utaha.Core.Task>(parser.get_root().get_object());

        task.node = Utaha.Core.Storage.get_storage().create_node(task.taskdata.id);
        task.init();
        task.dump();
    }
}
