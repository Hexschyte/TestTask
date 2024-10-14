using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Diagnostics;
using System.Net.Http;
using TZ2.Models;

namespace TZ2.Controllers
{
    public class ProductController : Controller
    {
        private readonly DataContext _context;

        public ProductController(DataContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index(string searchString)
        {
            var products = await FilterProductsInternal(searchString);
            return View(products);
        }

        [HttpGet]
        public async Task<IActionResult> FilterProducts(string searchString)
        {
            var products = await FilterProductsInternal(searchString);
            return PartialView("ProductTablePartial", products);
        }

        private async Task<List<Product>> FilterProductsInternal(string searchString)
        {
            var products = _context.Product.AsQueryable();

            if (!string.IsNullOrEmpty(searchString))
            {
                products = products.Where(p => p.Name.Contains(searchString));
            }

            return await products.ToListAsync();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

    }
}
