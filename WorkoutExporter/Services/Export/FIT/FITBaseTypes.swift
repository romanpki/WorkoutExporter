import Foundation

/// FIT base type definitions
enum FITBaseType: UInt8 {
    case enumType   = 0x00  // 1 byte
    case sint8      = 0x01  // 1 byte
    case uint8      = 0x02  // 1 byte
    case sint16     = 0x83  // 2 bytes
    case uint16     = 0x84  // 2 bytes
    case sint32     = 0x85  // 4 bytes
    case uint32     = 0x86  // 4 bytes
    case string     = 0x07  // variable
    case float32    = 0x88  // 4 bytes
    case float64    = 0x89  // 8 bytes
    case uint8z     = 0x0A  // 1 byte
    case uint16z    = 0x8B  // 2 bytes
    case uint32z    = 0x8C  // 4 bytes
    case sint64     = 0x8E  // 8 bytes
    case uint64     = 0x8F  // 8 bytes
    case uint64z    = 0x90  // 8 bytes

    var size: UInt8 {
        switch self {
        case .enumType, .sint8, .uint8, .uint8z: 1
        case .sint16, .uint16, .uint16z: 2
        case .sint32, .uint32, .uint32z, .float32: 4
        case .float64, .sint64, .uint64, .uint64z: 8
        case .string: 1 // per character
        }
    }

    /// Invalid/null value for this type
    var invalidValue: UInt64 {
        switch self {
        case .enumType: 0xFF
        case .sint8: 0x7F
        case .uint8: 0xFF
        case .sint16: 0x7FFF
        case .uint16: 0xFFFF
        case .sint32: 0x7FFFFFFF
        case .uint32: 0xFFFFFFFF
        case .string: 0x00
        case .float32: 0xFFFFFFFF
        case .float64: 0xFFFFFFFFFFFFFFFF
        case .uint8z: 0x00
        case .uint16z: 0x0000
        case .uint32z: 0x00000000
        case .sint64: 0x7FFFFFFFFFFFFFFF
        case .uint64: 0xFFFFFFFFFFFFFFFF
        case .uint64z: 0x0000000000000000
        }
    }
}

/// FIT epoch: December 31, 1989 00:00:00 UTC
let fitEpoch: Date = {
    var components = DateComponents()
    components.year = 1989
    components.month = 12
    components.day = 31
    components.hour = 0
    components.minute = 0
    components.second = 0
    components.timeZone = TimeZone(secondsFromGMT: 0)
    return Calendar(identifier: .gregorian).date(from: components)!
}()

/// Convert a Date to FIT timestamp (seconds since FIT epoch)
func fitTimestamp(from date: Date) -> UInt32 {
    UInt32(date.timeIntervalSince(fitEpoch))
}

/// Convert degrees to FIT semicircles
func fitSemicircles(from degrees: Double) -> Int32 {
    Int32(degrees * (Double(Int32.max) / 180.0))
}

/// Encode altitude for FIT: (meters + 500) * 5, stored as uint16
func fitAltitude(from meters: Double) -> UInt16 {
    UInt16(max(0, (meters + 500.0) * 5.0))
}

/// Encode speed for FIT: m/s * 1000, stored as uint16
func fitSpeed(from metersPerSecond: Double) -> UInt16 {
    UInt16(max(0, metersPerSecond * 1000.0))
}

/// Encode distance for FIT: meters * 100, stored as uint32
func fitDistance(from meters: Double) -> UInt32 {
    UInt32(max(0, meters * 100.0))
}
