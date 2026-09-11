import Foundation

enum SharedConfig {
    static let appGroup = "group.schooldistrict203.connect"
    static let relayURLKey = "relayURL"
    static let pairingCodeKey = "pairingCode"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }

    static var relayURL: String {
        get { defaults?.string(forKey: relayURLKey) ?? "" }
        set { defaults?.set(newValue, forKey: relayURLKey) }
    }

    static var pairingCode: String {
        get { defaults?.string(forKey: pairingCodeKey) ?? "" }
        set { defaults?.set(newValue, forKey: pairingCodeKey) }
    }

    static func makePairingCode() -> String {
        String(Int.random(in: 100000...999999))
    }
}