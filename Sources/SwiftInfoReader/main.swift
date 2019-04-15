import Foundation

guard let path = UserDefaults.standard.string(forKey: "path") else {
    fatalError()
}

let generator = Generator(jsonPath: path)
generator.generate()
