//
//  AppDependency.swift
//  CoreServices
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

import Swinject

public final class AppDependency {
    public static let shared = AppDependency()
    
    public let container: Container
    public let assembler: Assembler
    
    private init() {
        container = Container()
        assembler = Assembler(container: container)
    }
    
    func assemble(_ assemblies: [Assembly]) {
        assembler.apply(assemblies: assemblies)
    }
}

@propertyWrapper
struct Injected<T> {
    private let container: Container
    
    init() {
        self.container = AppDependency.shared.container
    }
    
    var wrappedValue: T {
        get {
            guard let resolved = container.resolve(T.self) else {
                fatalError("Could not resolve dependency: \(T.self)")
            }
            return resolved
        }
    }
}
