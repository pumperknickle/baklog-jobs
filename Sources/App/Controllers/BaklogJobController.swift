import Fluent
import Vapor

struct BaklogJobController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("jobs")

        todos.get(use: index)
        todos.post(use: create)
        todos.group(":jobID") { todo in
            todo.get(use: show)
            todo.put(use: update)
            todo.delete(use: delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [BaklogJobDTO] {
        try await BaklogJob.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func show(req: Request) async throws -> BaklogJobDTO {
        guard let todo = try await BaklogJob.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return todo.toDTO()
    }

    @Sendable
    func update(req: Request) async throws -> BaklogJobDTO {
        guard let todo = try await BaklogJob.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedTodo = try req.content.decode(BaklogJob.self)
        todo.spec = updatedTodo.spec
        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    @Sendable
    func create(req: Request) async throws -> BaklogJobDTO {
        let todo = try req.content.decode(BaklogJobDTO.self).toModel()

        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await BaklogJob.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
        return .noContent
    }
}
