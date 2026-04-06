import Foundation

/// FIT Global Message Numbers
enum FITMessageType: UInt16 {
    case fileId       = 0
    case deviceInfo   = 23
    case event        = 21
    case record       = 20
    case lap          = 19
    case session      = 18
    case activity     = 34
}
