
using Microsoft.AspNetCore.Mvc;
using FoodieExpress.Api.Models;

namespace FoodieExpress.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        var products = new List<Product>
        {
            new() { Id = 1, Name = "Burger Bò Phô Mai", Description = "Burger bò phô mai thơm ngon", Price = 59000, Icon = "🍔", CategoryId = 1 },
            new() { Id = 2, Name = "Pizza Hải Sản", Description = "Pizza hải sản phô mai", Price = 129000, Icon = "🍕", CategoryId = 2 },
            new() { Id = 3, Name = "Gà Rán Giòn Cay", Description = "Gà rán giòn với sốt cay", Price = 75000, Icon = "🍗", CategoryId = 3 },
            new() { Id = 4, Name = "Trà Sữa Trân Châu", Description = "Trà sữa trân châu đường đen", Price = 35000, Icon = "🧋", CategoryId = 4 }
        };

        return Ok(products);
    }
}
