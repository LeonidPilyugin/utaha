namespace Utaha.Core
{
    private class Module : TypeModule
    {
        [CCode (has_target = false)]
        private delegate void PluginInitFunc (TypeModule module);
        private GLib.Module module = null;
        private string name = null;
        public string? error { get; private set; }

        public Module(string name)
        {
            this.name = name;
            error = null;
        }

        public override bool load()
        {
            module = GLib.Module.open(name, GLib.ModuleFlags.LAZY);
            if (null == module)
            {
                error = @"Module $name not found or invalid file";
                return true;
            }

            void * plugin_init = null;
            if (!module.symbol("plugin_init", out plugin_init))
            {
                error = @"Module $name does not have init function";
                return true;
            }

            ((PluginInitFunc) plugin_init)(this);

            return true;
        }

        public override void unload() {
            module = null;
        }
    }
}
