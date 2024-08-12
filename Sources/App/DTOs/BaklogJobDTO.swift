import Fluent
import Vapor

struct BaklogJobDTO: Content {
    var id: UUID?
    var spec: String?
    
    func toModel() -> BaklogJob {
        let model = BaklogJob()
        
        model.id = self.id
        if let spec = self.spec {
            model.spec = spec
        }
        return model
    }
}
