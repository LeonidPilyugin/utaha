namespace Utaha.App
{
    public class CountOperation : Operation
    {
        private uint counter = 0;

        public override void perform(Utaha.Core.Task task) throws OperationError
        {
            counter++;
        }

        public override string print()
        {
            return @"$counter\n";
        }
    }
}
