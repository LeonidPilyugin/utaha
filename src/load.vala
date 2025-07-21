namespace Utaha.App
{
    static void load(string file)
    {
        var parser = new Json.Parser();
        parser.load_from_file(file);

        Utaha.Core.Task task = Utaha.Core.IJsonable.load_json<Utaha.Core.Task>(parser.get_root().get_object());

        task.node = Utaha.Core.Storage.get_storage().get_node(task.taskdata.id);
        task.init();
        task.dump();
    }
}
