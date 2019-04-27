import Foundation

struct ProviderInfo: Hashable {
    let key: String
    let description: String
    let runs: [Run]
}

struct Run: Hashable {
    let project: Xcodeproj
    let value: Float
    let stringValue: String
    let tooltip: String
    let color: String
}

struct Xcodeproj: Hashable {
    let target: String
    let versionString: String
    let buildNumber: String
    let description: String
    let timestamp: TimeInterval?
}
