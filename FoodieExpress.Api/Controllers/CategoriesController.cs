
using Microsoft.AspNetCore.Mvc;
using FoodieExpress.Api.Models;

namespace FoodieExpress.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriesController : ControllerBase
{
    [HttpGet]
    public IActionResult GetCategories()
    {
        var categories = new List<Category>
        {
            new() { Id = 1, Name = "Burger" },
            new() { Id = 2, Name = "Pizza" },
            new() { Id = 3, Name = "Gà rán" },
            new() { Id = 4, Name = "Đồ uống" }
        };

        return Ok(categories);
    }
}
