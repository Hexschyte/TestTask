using Microsoft.EntityFrameworkCore;
using TZ2.Models;

namespace TZ2
{
    public class DataContext : DbContext
    {
        public DataContext(DbContextOptions<DataContext> options) : base(options) { }

        public DbSet<Product> Product { get; set; }
        public DbSet<ProductVersion> ProductVersion { get; set; }
        public DbSet<EventLog> EventLog { get; set; }
    }
}
