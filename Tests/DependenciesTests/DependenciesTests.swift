import Testing
@testable import Dependencies

@Suite(.serialized)
actor DependenciesTests {
    @Dependency(\.storage) var storage
    
    @Test
    func dependency_isAccessible() async {
        await storage.set("hello world")
        let data = await storage.get()
        #expect(data == "hello world")
    }
    
    @Test
    func dependency_changeModeAtRuntime() async {
        // set live value
        DependencyValues.setMode(.live)
        await storage.set("live")
        
        // set mock value
        DependencyValues.setMode(.mock)
        await storage.set("mock")
        
        // get live value
        DependencyValues.setMode(.live)
        let live = await storage.get()
        #expect(live == "live")
        
        // get mock value
        DependencyValues.setMode(.mock)
        let mock = await storage.get()
        #expect(mock == "mock")
    }
    
}

