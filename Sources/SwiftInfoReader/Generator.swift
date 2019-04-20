import Foundation

final class Generator {

    let chart: Chart
    let jsonPath: String

    init(jsonPath: String) {
        self.chart = Chart()
        self.jsonPath = jsonPath
    }

    func generate() {
        let json = getJson()
        let info = getInfo(fromJson: json)
        let html = chart.generate(info: info)
        save(html: html)
    }

    func getJson() -> [String: Any] {
        let jsonUrl = URL(fileURLWithPath: jsonPath)
        do {
            let jsonData = try Data(contentsOf: jsonUrl)
            let object = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let json = object as? [String: Any] else {
                fail("Failed to cast \(object) to a Dictionary.")
            }
            return json
        } catch {
            fail(error.localizedDescription)
        }
    }

    func getInfo(fromJson json: [String: Any]) -> [ProviderInfo] {
        guard let data = json["data"] as? [[String: Any]] else {
            fail("Failed to get `data`: It looks like the JSON isn't in the right format.")
        }
        let rawInfo = data.flatMap { data -> [ProviderInfo] in
            let hardcodedKey = "swiftinfo_run_description_key"
            let hardcodedInfoKey = "swiftinfo_run_project_info"
            let runKey = data[hardcodedKey] as? String ?? "Unknown key"
            return data.compactMap { dict -> ProviderInfo? in
                let key = dict.key
                guard key != hardcodedKey else {
                    return nil
                }
                guard key != hardcodedInfoKey else {
                    return nil
                }
                guard let valueDict = dict.value as? [String: Any] else {
                    fail("Data output value isn't a dictionary!")
                }
                let summary = valueDict["summary"] as? [String: Any] ?? [:]
                let color = summary["color"] as? String ?? "#000000"
                let tooltip = summary["text"] as? String ?? "No summary."
                let data = valueDict["data"] as? [String: Any] ?? [:]
                let description = data["description"] as? String ?? "No description."
                guard let value = data.compactMap({ $0.value as? Double }).first else {
                    fail("Can't plot \(key) as it has no numeric properties.")
                }
                let run = Run(runDescription: runKey,
                              value: value,
                              tooltip: tooltip,
                              color: color)
                return ProviderInfo(key: key, description: description, runs: [run])
            }
        }
        var mergedInfo = [String: ProviderInfo]()
        rawInfo.forEach {
            let current = mergedInfo[$0.key]
            mergedInfo[$0.key] = ProviderInfo(key: $0.key,
                                              description: $0.description,
                                              runs: $0.runs + (current?.runs ?? []))
        }
        return mergedInfo.map { $0.value }
    }

    func save(html: String) {
        let url = URL(fileURLWithPath: jsonPath)
        let folderToSave = url.deletingLastPathComponent()
                              .appendingPathComponent("page")
                              .appendingPathComponent("public")
        do {
            try FileManager.default.createDirectory(atPath: folderToSave.relativePath,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            let indexUrl = folderToSave.appendingPathComponent("index.html")
            try html.write(to: indexUrl, atomically: true, encoding: .utf8)
            print("Page generated succesfully at \(folderToSave.relativePath)!")
        } catch {
            fail(error.localizedDescription)
        }
    }
}
