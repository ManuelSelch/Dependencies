import Foundation
import Dependencies

protocol StorageService: Sendable {
    func get() async -> String
    func set(_ data: String) async
}

final actor InMemoryService: StorageService {
    private var data = ""
    
    public func get() -> String {
        return data
    }
    
    public func set(_ data: String) {
        self.data = data
    }
}

struct StorageServiceKey: DependencyKey {
    public static var liveValue: StorageService { InMemoryService() }
    public static var mockValue: StorageService { InMemoryService() }
}


extension DependencyValues {
    var storage: StorageService {
        get { Self[StorageServiceKey.self] }
    }
}
