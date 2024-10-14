using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TZ2.Models;

namespace TZ2.Controllers
{
    [ApiController]
    [Route("api/product")]
    public class ApiController : Controller
    {
        private readonly DataContext _context;
        public ApiController(DataContext context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<IActionResult> AddProduct([FromBody] Product item)
        {
            if (item == null || string.IsNullOrEmpty(item.Name))
            {
                return BadRequest("Name was not set");
            }

            var existingProductWithSameName = await _context.Product
                .Where(p => p.Name == item.Name && p.Id != item.Id)  // Проверяем другие продукты с таким же именем
                .FirstOrDefaultAsync();

            if (existingProductWithSameName != null)
            {
                return BadRequest("Product with the same name already exists.");
            }

            item.Id = Guid.NewGuid();

            _context.Product.Add(item);
            await _context.SaveChangesAsync();

            return Ok("Product added successfully with Id: " + item.Id);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> RemoveProduct(Guid id)
        {
            var target = _context.Product
                            .Where(p => p.Id == id)
                            .FirstOrDefault();
            if (target == null)
            {
                return BadRequest("No product with such id in database");
            }

            _context.Product.Remove(target);
            await _context.SaveChangesAsync();
            return NoContent();
        }


        [HttpPut]
        public async Task<IActionResult> ChangeProduct([FromBody] Product item)
        {
            if (item == null || string.IsNullOrEmpty(item.Name))
            {
                return BadRequest("Invalid product data.");
            }

            var target = await _context.Product
                .Where(p => p.Id == item.Id)
                .FirstOrDefaultAsync();

            if (target == null)
            {
                return BadRequest("No product found. Try create instead of edit");
            }

            var existingProductWithSameName = await _context.Product
                .Where(p => p.Name == item.Name && p.Id != item.Id)  // Проверяем другие продукты с таким же именем
                .FirstOrDefaultAsync();

            if (existingProductWithSameName != null)
            {
                return BadRequest("Product with the same name already exists.");
            }

            // Обновляем только изменённые поля
            target.Name = item.Name;
            target.Description = item.Description;

            _context.Product.Update(target);  // Обновляем только найденный продукт
            await _context.SaveChangesAsync();

            return Ok("Product updated successfully.");
        }
    }
}
