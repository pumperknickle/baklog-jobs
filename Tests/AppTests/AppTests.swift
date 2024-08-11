@testable import App
import XCTVapor
import Fluent

final class AppTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }
    
    override func tearDown() async throws { 
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testHelloWorld() async throws {
        try await self.app.test(.GET, "hello", afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }
    
    func testTodoIndex() async throws {
        let sampleTodos = [BaklogJob(spec: "sample1"), BaklogJob(spec: "sample2")]
        try await sampleTodos.create(on: self.app.db)
        
        try await self.app.test(.GET, "jobs", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(
                try res.content.decode([BaklogJobDTO].self).sorted(by: { $0.spec ?? "" < $1.spec ?? "" }),
                sampleTodos.map { $0.toDTO() }.sorted(by: { $0.spec ?? "" < $1.spec ?? "" })
            )
        })
    }
    
    func testTodoGet() async throws {
        let sampleTodos = [BaklogJob(spec: "sample1"), BaklogJob(spec: "sample2")]
        try await sampleTodos.create(on: self.app.db)
        
        try await self.app.test(.GET, "jobs", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(
                try res.content.decode([BaklogJobDTO].self).sorted(by: { $0.spec ?? "" < $1.spec ?? "" }),
                sampleTodos.map { $0.toDTO() }.sorted(by: { $0.spec ?? "" < $1.spec ?? "" })
            )
        })
    }
    
    func testTodoCreate() async throws {
        let newDTO = BaklogJobDTO(id: nil, spec: "test")
        
        try await self.app.test(.POST, "jobs", beforeRequest: { req in
            try req.content.encode(newDTO)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let models = try await BaklogJob.query(on: self.app.db).all()
            XCTAssertEqual(models.map { $0.toDTO().spec }, [newDTO.spec])
        })
    }
    
    func testTodoDelete() async throws {
        let testTodos = [BaklogJob(spec: "jobs"), BaklogJob(spec: "test2")]
        try await testTodos.create(on: app.db)
        
        try await self.app.test(.DELETE, "jobs/\(testTodos[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .noContent)
            let model = try await BaklogJob.find(testTodos[0].id, on: self.app.db)
            XCTAssertNil(model)
        })
    }
}

extension BaklogJobDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.spec == rhs.spec
    }
}
