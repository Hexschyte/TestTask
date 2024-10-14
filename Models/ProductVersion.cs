using System.Text.Json.Serialization;

namespace TZ2.Models
{
    public class ProductVersion
    {
        public Guid Id { get; set; }  // Используем тип Guid
        public Guid ProductId { get; set; }  // Внешний ключ к таблице Product
        public required string Name { get; set; }
        public string? Description { get; set; }
        public DateTime CreatingDate { get; set; }
        public int Width { get; set; }
        public int Height { get; set; }
        public int Length { get; set; }

        [JsonIgnore]
        public Product Product { get; set; }
    }
}
