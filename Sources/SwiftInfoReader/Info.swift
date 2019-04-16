import Foundation

struct ProviderInfo: Hashable {
    let key: String
    let description: String
    let runs: [Run]
}

struct Run: Hashable {
    let runDescription: String
    let value: Double
    let tooltip: String
    let color: String
}
