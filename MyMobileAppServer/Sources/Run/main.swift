//
//  File.swift
//  
//
//  Created by Arthur Foo Che Jit on 21/07/2024.
//
import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.autoMigrate().wait() // This line will apply the migrations
try app.run()
