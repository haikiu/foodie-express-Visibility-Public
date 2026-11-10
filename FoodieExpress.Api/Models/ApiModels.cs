
using System.ComponentModel.DataAnnotations;

namespace FoodieExpress.Api.Models;

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
}

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public int Price { get; set; }
    public string Icon { get; set; } = "";
    public int CategoryId { get; set; }
}

public class OrderItemRequest
{
    [Required]
    public string Name { get; set; } = "";

    public int Price { get; set; }
    public string Icon { get; set; } = "";
    public string Size { get; set; } = "M";
    public List<string> Toppings { get; set; } = new();
    public string Sugar { get; set; } = "100%";
    public string Ice { get; set; } = "100%";
    public int Quantity { get; set; }
}

public class CreateOrderRequest
{
    [Required]
    public string CustomerName { get; set; } = "";

    [Required]
    public string Phone { get; set; } = "";

    [Required]
    public string Address { get; set; } = "";

    public string Note { get; set; } = "";
    public string PaymentMethod { get; set; } = "";

    [Required]
    [MinLength(1)]
    public List<OrderItemRequest> Items { get; set; } = new();
}

public class Order
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string CustomerName { get; set; } = "";
    public string Phone { get; set; } = "";
    public string Address { get; set; } = "";
    public string Note { get; set; } = "";
    public string PaymentMethod { get; set; } = "";
    public List<OrderItemRequest> Items { get; set; } = new();
    public int TotalPrice { get; set; }
    public string Status { get; set; } = "Chờ xác nhận";
    public DateTime CreatedAt { get; set; } = DateTime.Now;
}
