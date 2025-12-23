## Dependencies
- lightweight dependency management pattern

## Concept
- Define your service
- Provide `live` and `mock` implementations
- Register it using `DependencyKey`
- Inject it using `@Dependency(\.name)`

## 1. Define your service
```swift
struct MyService {}
```

## 2. Provide Live & Mock implementations
```swift
sruct MyServiceKey: DependencyKey {
  static var liveValue = MyService()
  static var mockValue = MyService()
}
```

## 3. Register Dependency
```swift
public extension DependencyValues {
    var myService: MyService {
        get { Self[MyServiceKey.self] }
        set { Self[MyServiceKey.self] = newValue }
    }
}
```

## 4. Inject Dependency
```swift
@Dependency(\.myService) var myService
```
