// Copyright © 2021 evan. All rights reserved.

extension FileManager {
    static var mainUrl: URL? { return Bundle.main.url(forResource: "Setting", withExtension: "json") }
    
    static func getSettings() -> [Setting] {
        guard let mainUrl = mainUrl, let appendingUrl = getAppendingUrl() else { return [] }
        return loadFile(mainPath: mainUrl, appendingPath: appendingUrl)
    }
    
    static func getAppendingUrl() -> URL? {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentDirectory.appendingPathComponent("Setting.json")
        } catch {
            print(error)
            return nil
        }
    }
    
    static private func loadFile(mainPath: URL, appendingPath: URL) -> [Setting] {
        if FileManager.default.fileExists(atPath: appendingPath.path) {
            do {
                let jsonData = try Data(contentsOf: appendingPath)
                let decoder = JSONDecoder()
                return try decoder.decode([Setting].self, from: jsonData)
            } catch {
                do {
                    let jsonData = try Data(contentsOf: mainPath)
                    let decoder = JSONDecoder()
                    return try decoder.decode([Setting].self, from: jsonData)
                } catch {
                    return []
                }
            }
        } else {
            do {
                let jsonData = try Data(contentsOf: mainPath)
                let decoder = JSONDecoder()
                return try decoder.decode([Setting].self, from: jsonData)
            } catch {
                return []
            }
        }
    }
}
