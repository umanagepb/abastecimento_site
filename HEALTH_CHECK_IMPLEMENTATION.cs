// Adicione este código ao Program.cs ou Startup.cs da API
// Para implementar health checks

/*
// No Program.cs da API (abastecimento_api)
builder.Services.AddHealthChecks()
    .AddNpgSql(builder.Configuration.GetConnectionString("ConnectionString"))
    .AddCheck("self", () => HealthCheckResult.Healthy());

// No pipeline de middleware
app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var response = new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(x => new
            {
                name = x.Key,
                status = x.Value.Status.ToString(),
                description = x.Value.Description,
                duration = x.Value.Duration.ToString()
            }),
            duration = report.TotalDuration.ToString()
        };
        await context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
});
*/

/*
// No Program.cs da aplicação Web (abastecaonline)
builder.Services.AddHealthChecks()
    .AddNpgSql(builder.Configuration.GetConnectionString("ConnectionString"))
    .AddCheck("self", () => HealthCheckResult.Healthy())
    .AddUrlGroup(new Uri($"{builder.Configuration["ApiUrl"]}/health"), "api");

// No pipeline de middleware
app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var response = new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(x => new
            {
                name = x.Key,
                status = x.Value.Status.ToString(),
                description = x.Value.Description,
                duration = x.Value.Duration.ToString()
            }),
            duration = report.TotalDuration.ToString()
        };
        await context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
});
*/