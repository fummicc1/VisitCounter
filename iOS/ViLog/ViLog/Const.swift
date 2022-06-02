import Foundation

struct Const {
    static var groupID: String {
        var id = "group.fummicc1.vilog"
        #if DEBUG
        id += "-debug"
        #endif
        return id
    }
    static var appName: String {
        let appName: String
        #if DEBUG
        appName = "ViLog"
        #else
        appName = "D_ViLog"
        #endif
        return appName
    }
}
