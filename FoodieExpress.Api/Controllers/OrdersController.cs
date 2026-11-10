
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using FoodieExpress.Api.Models;

namespace FoodieExpress.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private static readonly object FileLock = new();

    private static readonly string DataDirectory =
        Path.Combine(Directory.GetCurrentDirectory(), "Data");

    private static readonly string FilePath =
        Path.Combine(DataDirectory, "orders.json");

    [HttpPost]
    public IActionResult CreateOrder([FromBody] CreateOrderRequest request)
    {
        if (request.Items.Any(item => item.Price < 0 || item.Quantity <= 0))
        {
            return BadRequest(new { message = "Sản phẩm không hợp lệ." });
        }

        var order = new Order
        {
            CustomerName = request.CustomerName,
            Phone = request.Phone,
            Address = request.Address,
            Note = request.Note,
            PaymentMethod = request.PaymentMethod,
            Items = request.Items,
            TotalPrice = request.Items.Sum(item => item.Price * item.Quantity),
            Status = "Chờ xác nhận"
        };

        lock (FileLock)
        {
            Directory.CreateDirectory(DataDirectory);

            List<Order> orders = System.IO.File.Exists(FilePath)
                ? JsonSerializer.Deserialize<List<Order>>(
                    System.IO.File.ReadAllText(FilePath)) ?? new()
                : new();

            orders.Add(order);

            System.IO.File.WriteAllText(
                FilePath,
                JsonSerializer.Serialize(orders,
                    new JsonSerializerOptions { WriteIndented = true }));
        }

        return Ok(new
        {
            message = "Đặt hàng thành công!",
            order
        });
    }

    [HttpGet]
    public IActionResult GetOrders()
    {
        lock (FileLock)
        {
            if (!System.IO.File.Exists(FilePath))
                return Ok(new List<Order>());

            var orders = JsonSerializer.Deserialize<List<Order>>(
                System.IO.File.ReadAllText(FilePath)) ?? new();

            return Ok(orders);
        }
    }
}
