namespace Utaha.Core
{
    public static void load_modules() throws ModuleError
    {
        string path = string.join(":",
            Path.build_filename("usr", "share", "utaha", "modules"),
            Path.build_filename(Environment.get_home_dir(), ".local", "share", "utaha", "modules")
        );
        string? user_path = Environment.get_variable("UTAHA_MODULE_PATH");
        if (user_path != null)
            path = string.join(":", path, user_path);
        ModuleLoader.load_dirs(path.split(":"));
    }
}
