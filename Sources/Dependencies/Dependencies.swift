import Foundation

public protocol DependencyKey {
    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var liveValue: Value { get }
    static var mockValue: Value { get }
    
}

public extension DependencyKey {
    static var mockValue: Value { Self.liveValue }
}

public enum DependencyMode: Sendable {
    case live
    case mock
}
    

private final class DependencyStorage: @unchecked Sendable {
    private var values = DependencyValues()
    private let lock = NSLock()
    var mode: DependencyMode = .live
    
    var live: [ObjectIdentifier: Any] = [:]
    var mock: [ObjectIdentifier: Any] = [:]

    func get() -> DependencyValues {
        lock.lock()
        defer { lock.unlock() }
        
        return values
    }
    
    func getValue<K: DependencyKey>(_ key: K.Type) -> K.Value {
        lock.lock()
        defer { lock.unlock() }
        
        let id =  ObjectIdentifier(key)
        let store = mode == .live ? storage.live : storage.mock
        
        if let cached = store[id] as? K.Value {
            return cached
        }
        
        let value = mode == .live ? K.liveValue : K.mockValue
        if mode == .live {
            storage.live[id] = value
        } else {
            storage.mock[id] = value
        }
        
        return value
        
    }

}

private let storage = DependencyStorage()

/// Provides access to injected dependencies.
public struct DependencyValues: Sendable {
    
    public static func setMode(_ mode: DependencyMode) {
        storage.mode = mode
    }
    
    /// A static subscript for updating the `currentValue` of `DependencyKey` instances.
    public static subscript<K>(key: K.Type) -> K.Value where K : DependencyKey {
        get {
            return storage.getValue(key)
        }
    }
    
    /// A static subscript accessor for updating and references dependencies directly.
    public static subscript<T>(_ keyPath: KeyPath<DependencyValues, T>) -> T {
        get {
            return storage.get()[keyPath: keyPath]
        }
    }
}


@propertyWrapper
public struct Dependency<T>: @unchecked Sendable {
    private let keyPath: KeyPath<DependencyValues, T>
    
    @MainActor
    public var wrappedValue: T {
        get { DependencyValues[keyPath] }
    }
    
    public init(_ keyPath: KeyPath<DependencyValues, T>) {
        self.keyPath = keyPath
    }
}

