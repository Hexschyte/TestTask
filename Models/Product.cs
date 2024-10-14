using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace TZ2.Models
{
    public class Product
    {
        public Guid Id { get; set; } 
        public required string Name { get; set; }
        public string? Description { get; set; }
        public ICollection<ProductVersion>? ProductVersions { get; set; }
    }
}
