import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    // Add middleware to parse JSON requests
        app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory)) // Serves files from `Public/` directory
        app.middleware.use(ErrorMiddleware.default(environment: app.environment)) // Catches errors and converts to HTTP response
    
    app.databases.use(.postgres(
        configuration: SQLPostgresConfiguration(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: try configuredPort("DATABASE_PORT", default: 5432),
            username: try requiredEnvironment("DATABASE_USERNAME"),
            password: try requiredEnvironment("DATABASE_PASSWORD"),
            database: try requiredEnvironment("DATABASE_NAME"),
            tls: .prefer(try .init(configuration: .clientDefault)) // Add this line to specify TLS preference
        ),
        maxConnectionsPerEventLoop: 10
    ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateNewCarRepairShop())
    app.migrations.add(AddNameAndPhoneNumberToUsers())
    app.migrations.add(AddEmergencyPhoneNumberToUsers())

    try routes(app)
    
    app.http.server.configuration.port = try configuredPort("SERVER_PORT", default: 8081)
    app.http.server.configuration.hostname = Environment.get("SERVER_HOST") ?? "127.0.0.1"
}


// Never fall back to a committed credential. Error messages contain variable names only.
func requiredEnvironment(_ name: String) throws -> String {
    guard let value = Environment.get(name),
          !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        throw Abort(.internalServerError, reason: "Missing required environment variable: \(name)")
    }
    return value
}

func configuredPort(_ name: String, default defaultPort: Int) throws -> Int {
    guard let value = Environment.get(name) else { return defaultPort }
    guard let port = Int(value), (1...65535).contains(port) else {
        throw Abort(.internalServerError, reason: "Invalid port in environment variable: \(name)")
    }
    return port
}
