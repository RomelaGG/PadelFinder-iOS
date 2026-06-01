//
//  Navigator.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import Combine

@MainActor
public final class Navigator<Destination: NavigatorDestination>: ObservableObject {
    @Published var stack: [Destination] = []
    @Published var fullScreen: Destination?
    
    public init() { }

    var numberOfItems: Int {
        stack.count
    }

    var isPresentedFullScreen: Bool {
        get { fullScreen != nil }
        set {
            guard !newValue else { return }
            fullScreen = nil
        }
    }

    func push(_ destination: Destination) {
        stack.append(destination)
    }

    func pop() {
        guard !stack.isEmpty else { return }
        stack.removeLast()
    }

    func pop(to destination: Destination) {
        guard let index = stack.firstIndex(of: destination) else { return }
        stack = Array(stack.prefix(through: index))
    }

    func popToRoot() {
        stack.removeAll()
    }

    func replaceStack(with destination: Destination) {
        stack = [destination]
    }

    func presentFullScreen(_ destination: Destination) {
        fullScreen = destination
    }

    func dismissFullScreen() {
        fullScreen = nil
    }
}
