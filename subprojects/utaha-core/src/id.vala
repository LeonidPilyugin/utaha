namespace Utaha.Core
{
    [Immutable]
    public struct Id
    {
        public string uuid { get; private set; }

        private Id(string uuid)
        {
            this.uuid = uuid;
        }

        public static Id from_string(string uuid) throws IdError
        {
            if (!Uuid.string_is_valid(uuid))
                throw new IdError.PARSE_ERROR(@"Could not parse UUID $uuid");
            return Id(uuid);
        }

        public static Id generate()
        {
            return Id(Uuid.string_random());
        }

        public static bool equal(Id id1, Id id2)
        {
            return str_equal(id1.uuid, id2.uuid);
        }
    }
}
