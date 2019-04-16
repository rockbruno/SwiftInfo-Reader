import Foundation

func fail(_ message: String) -> Never {
    fatalError(message + " Are you using the right reader version for your SwiftInfo output?")
}
