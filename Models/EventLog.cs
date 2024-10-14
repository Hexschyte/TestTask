namespace TZ2.Models
{
    public class EventLog
    {
        public Guid Id { get; set; }
        public DateTime EventDate { get; set; }
        public string? Description { get; set; }
    }
}
