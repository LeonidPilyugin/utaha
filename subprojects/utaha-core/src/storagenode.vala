namespace Utaha.Core
{
    public sealed class StorageNode
    {
        public string path { get; private set; }
        private File file { get; set; }

        public StorageNode(string path) throws StorageNodeError
        {
            this.path = path;
            file = File.new_for_path(path);
            if (!exists()) init();
        }

        public bool exists()
        {
            return file.query_exists();
        }

        public void remove_file(string name) throws StorageNodeError
        {
            try
            {
                File.new_for_path(build(name)).delete();
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(e.message);
            }
        }

        public string build(string name)
        {
            return Path.build_filename(path, name);
        }

        private void init() throws StorageNodeError
        {
            try
            {
                file.make_directory_with_parents();
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(e.message);
            }
        }

        public List<string> list_children()
        {
            var result = new List<string>();
            var enumerator = file.enumerate_children("*", FileQueryInfoFlags.NONE);
            FileInfo? info = null;
            while (null != (info = enumerator.next_file()))
                result.append(info.get_name());
            return result;
        }

        private void remove_recursively(File file)
        {
            var enumerator = file.enumerate_children("*", FileQueryInfoFlags.NONE);
            FileInfo? info = null;

            while (null != (info = enumerator.next_file()))
            {
                if (info.get_file_type() == FileType.REGULAR) {
                    file.get_child(info.get_name()).delete();
                } else if (info.get_file_type() == FileType.DIRECTORY) {
                    var subfolder = file.get_child(info.get_name());
                    remove_recursively(subfolder);
                    subfolder.delete();
                }
            }

            file.delete();
        }

        public void remove() throws StorageNodeError
        {
            try
            {
                remove_recursively(file);
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(e.message);
            }
        }

        public StorageNode subnode(string name) throws StorageNodeError
        {
            return new StorageNode(build(name));
        }

        public bool file_exists(string name)
        {
            return File.new_for_path(build(name)).query_exists();
        }

        public void touch_file(string name) throws StorageNodeError
        {
            try
            {
                if (!file_exists(name))
                    File.new_for_path(build(name)).create(FileCreateFlags.NONE);
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(e.message);
            }
        }

        public string read_file(string name) throws StorageNodeError
        {
            try
            {
                var input = new DataInputStream(File.new_for_path(build(name)).read());
                string result = input.read_line();
                string? str = input.read_line();

                while (str != null)
                {
                    result = @"$result\n$str";
                    str = input.read_line();
                }

                return result;
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(
                    @"Could not read file \"$(build(name))\": $(e.message)"
                );
            }
        }

        public void write_file(string name, string content) throws StorageNodeError
        {
            touch_file(name);
            try
            {
                var output = File.new_for_path(build(name)).open_readwrite().output_stream as FileOutputStream;
                ssize_t written = 0;
                while (written < content.data.length)
                    written += output.write(content.data[written:]);
            } catch (Error e)
            {
                throw new StorageNodeError.FS_ERROR(
                    @"Could not write to file \"$(build(name))\": $(e.message)"
                );
            }
        }
    }


}
