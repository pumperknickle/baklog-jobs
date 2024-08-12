import Fluent

struct CreateBaklogJob: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("baklog_jobs")
            .id()
            .field("spec", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("baklog_jobs").delete()
    }
}
