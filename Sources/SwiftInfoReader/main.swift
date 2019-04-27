import Foundation

guard let path = UserDefaults.standard.string(forKey: "json") else {
    fatalError("No JSON specified. Example: swiftinfo-reader -json {path to json}.")
}

print("SwiftInfo-Reader 0.1.0")

let generator = Generator(jsonPath: path)
generator.generate()
