import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    // Add middleware to parse JSON requests
        app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory)) // Serves files from `Public/` directory
        app.middleware.use(ErrorMiddleware.default(environment: app.environment)) // Catches errors and converts to HTTP response
    
    app.databases.use(.postgres(
        configuration: SQLPostgresConfiguration(
            hostname: "localhost",
            username: "postgres",
            password: "admin123",
            database: "car_repair_shop",
            tls: .prefer(try .init(configuration: .clientDefault)) // Add this line to specify TLS preference
        ),
        maxConnectionsPerEventLoop: 10
    ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateNewCarRepairShop())
    app.migrations.add(AddNameAndPhoneNumberToUsers())
    app.migrations.add(AddEmergencyPhoneNumberToUsers())

    try routes(app)
    
    app.http.server.configuration.port = 8081
    app.http.server.configuration.hostname = "172.20.10.2"
}
