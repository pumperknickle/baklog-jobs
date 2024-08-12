import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class BaklogJob: Model, @unchecked Sendable {
    static let schema = "baklog_jobs"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "spec")
    var spec: String

    init() { }

    init(id: UUID? = nil, spec: String) {
        self.id = id
        self.spec = spec
    }
    
    func toDTO() -> BaklogJobDTO {
        .init(
            id: self.id,
            spec: self.$spec.value
        )
    }
}
