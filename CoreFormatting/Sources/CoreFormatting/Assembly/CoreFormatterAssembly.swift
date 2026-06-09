//
//  CoreFormatterAssembly.swift
//  CoreFormatting
//
//  Created by Giorgi Romelashvili on 09.06.26.
//

import Foundation
import Swinject

public struct CoreFormatterAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(DateFormatterProviderProtocol.self) { _ in
            DateFormatterProvider()
        }
        .inObjectScope(.container)
    }
}
