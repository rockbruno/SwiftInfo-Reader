import Foundation

final class Generator {

    let jsonPath: String

    init(jsonPath: String) {
        self.jsonPath = jsonPath
    }

    func generate() {
        let json = getJson()
        let info = getInfo(fromJson: json)
        let html = Chart().generate(info: info)
        save(html: html)
    }

    func getJson() -> [String: Any] {
        let jsonUrl = URL(fileURLWithPath: jsonPath)
        let jsonData = try! Data(contentsOf: jsonUrl)
        return try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
    }

    func getInfo(fromJson json: [String: Any]) -> [ProviderInfo] {
        guard let data = json["data"] as? [[String: Any]] else {
            fatalError()
        }
        let rawInfo = data.flatMap { data -> [ProviderInfo] in
            let hardcodedKey = "swiftinfo_run_description_key"
            let runKey = data[hardcodedKey] as! String
            return data.compactMap { dict -> ProviderInfo? in
                let key = dict.key
                guard key != hardcodedKey else {
                    return nil
                }
                let valueDict = dict.value as! [String: Any]
                let summary = valueDict["summary"] as! [String: Any]
                let color = summary["color"] as! String
                let tooltip = summary["text"] as! String
                let data = valueDict["data"] as! [String: Any]
                let description = data["description"] as! String
                let run = Run(runDescription: runKey,
                              value: 10,
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
       print(html)
        //page/public/index.html
    }
}
