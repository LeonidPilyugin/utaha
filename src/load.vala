using Toml;

namespace Utaha.App
{
    static void load(string file)
    {
        Element doc = new Toml.Parser.from_path(file).parse();
        Utaha.Core.Task task = Utaha.Core.ITomlable.load_toml<Utaha.Core.Task>(doc);

        task.node = Utaha.Core.Storage.get_storage().get_node(task.taskdata.id);
        task.init();
        task.dump();
    }
}
