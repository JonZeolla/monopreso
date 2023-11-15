# Secure Coding
## ASP.NET
### Future Ideas
Secrets management (https://nvisium.com/blog/2019/05/02/Dev-Secrets-and-the-ASP-NET-Core-Secret-Manager.html)
 - `using Microsoft.Extensions.Configuration;` and below to store secrets in a json (https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.configuration?view=aspnetcore-2.2)
 ```
   public class DonutShopController : Controller
  {
    public IConfiguration Configuration { get; }
  
    public DonutShopController(IConfiguration configuration)
    {
      Configuration = configuration;
    }
  
    public IActionResult Index()
    {
      if (env.IsDevelopment())
      {
        var secretIngredient = Configuration["DonutShop:SecretIngredient"];
      }
      // code snipped ....
    }
  }
 ```
 - JSON locations.  In the above file paths, the {UserSecretsId} corresponds to the UserSecretsId value specified in the application’s .csproj file. For example, the path on a MacOS would look like this ~/.microsoft/usersecrets/aspnet-DonutShop-F20820B3-818A-4BF4-9852-802E04B9A12E/secrets.json.
 ```
 OS	Location
 MacOS	~/.microsoft/usersecrets/{UserSecretsId}/secrets.json
 Windows	%APPDATA%\Microsoft\UserSecrets\{UserSecretsId}\secrets.json
 Linux	~/.microsoft/usersecrets/{UserSecretsId}/secrets.json
 ```

C# Validation
 - Example from SANS:
 ```NameAttribute.cs
   namespace SANS.AppSec
  {
      [AttributeUsage(AttributeTargets.Property, AllowMultiple = false, Inherited = true)]
      public class NameAttribute : ValidationAttribute
      {
          private const string _ERROR_MESSAGE = "{0} contains invalid characters.";
  
          public NameAttribute() : base(_ERROR_MESSAGE)
          {
          }
  
          protected override ValidationResult IsValid(object value, ValidationContext validationContext)
          {
              if (value != null)
              {
                  bool isValid = false;
  
                  isValid = Validator.IsValidNameBlackList(value.ToString());
  
                  if (!isValid)
                      return new ValidationResult(FormatErrorMessage(validationContext.DisplayName));
              }
  
              return ValidationResult.Success;
          }
  
          public override string FormatErrorMessage(string name)
          {
              return string.Format(_ERROR_MESSAGE, name);
          }
      }
  }
 ```
 ```Validator.cs
   namespace SANS.AppSec
  {
      public static class Validator
      {
          public static bool IsValidNameBlackList(string input)
          {
              return !input.Contains("<script>");
          }
  
          public static bool IsValidNameWhiteList(string input)
          {
              throw new NotImplementedException();
          }
      }
  }
 ```
 ```TheModel.cs
   namespace WidgetTown.Models
  {
      public class ContestEntryModel
      {
          [Required]
          [Display(Name = "Name")]
          [SANS.AppSec.Name] /* This is the key.  It adds the custom Name validation attribute to the Name property */
          public string Name { get; set; }
      }
  }
  ```
