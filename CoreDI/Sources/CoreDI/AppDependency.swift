//
//  AppDependency.swift
//  CoreServices
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

import Swinject

public final class AppDependency: @unchecked Sendable {
    public static let shared = AppDependency()
    
    public let container: Container
    public let assembler: Assembler
    
    private init() {
        container = Container()
        assembler = Assembler(container: container)
    }
    
    public func assemble(_ assemblies: [Assembly]) {
        assembler.apply(assemblies: assemblies)
    }
    
    public func resolve<T>(_ type: T.Type = T.self) -> T {
        guard let dependency = container.resolve(T.self) else {
            fatalError("Could not resolve dependency: \(T.self)")
        }
        return dependency
    }
}

@propertyWrapper
public struct Injected<T>: @unchecked Sendable {
    private let container: Container
    
    public init() {
        self.container = AppDependency.shared.container
    }
    
    public var wrappedValue: T {
        get {
            guard let resolved = container.resolve(T.self) else {
                fatalError("Could not resolve dependency: \(T.self)")
            }
            return resolved
        }
    }
}
