import Foundation

/// Field definition: field number, size, and base type
struct FITFieldDef {
    let fieldNum: UInt8
    let size: UInt8
    let baseType: FITBaseType
}

// MARK: - File ID Message (Global Message 0)

enum FITFileIdFields {
    static let type          = FITFieldDef(fieldNum: 0, size: 1, baseType: .enumType)     // file type: 4 = activity
    static let manufacturer  = FITFieldDef(fieldNum: 1, size: 2, baseType: .uint16)       // 1 = Garmin, 255 = dev
    static let product       = FITFieldDef(fieldNum: 2, size: 2, baseType: .uint16)
    static let serialNumber  = FITFieldDef(fieldNum: 3, size: 4, baseType: .uint32z)
    static let timeCreated   = FITFieldDef(fieldNum: 4, size: 4, baseType: .uint32)       // FIT timestamp
}

// MARK: - Event Message (Global Message 21)

enum FITEventFields {
    static let event         = FITFieldDef(fieldNum: 0, size: 1, baseType: .enumType)     // 0 = timer
    static let eventType     = FITFieldDef(fieldNum: 1, size: 1, baseType: .enumType)     // 0 = start, 4 = stop_all
    static let timestamp     = FITFieldDef(fieldNum: 253, size: 4, baseType: .uint32)
}

// MARK: - Record Message (Global Message 20)

enum FITRecordFields {
    static let timestamp     = FITFieldDef(fieldNum: 253, size: 4, baseType: .uint32)
    static let positionLat   = FITFieldDef(fieldNum: 0, size: 4, baseType: .sint32)       // semicircles
    static let positionLong  = FITFieldDef(fieldNum: 1, size: 4, baseType: .sint32)       // semicircles
    static let altitude      = FITFieldDef(fieldNum: 2, size: 2, baseType: .uint16)       // (m + 500) * 5
    static let heartRate     = FITFieldDef(fieldNum: 3, size: 1, baseType: .uint8)        // bpm
    static let cadence       = FITFieldDef(fieldNum: 4, size: 1, baseType: .uint8)        // rpm
    static let distance      = FITFieldDef(fieldNum: 5, size: 4, baseType: .uint32)       // m * 100
    static let speed         = FITFieldDef(fieldNum: 6, size: 2, baseType: .uint16)       // m/s * 1000
    static let power         = FITFieldDef(fieldNum: 7, size: 2, baseType: .uint16)       // watts
}

// MARK: - Lap Message (Global Message 19)

enum FITLapFields {
    static let timestamp         = FITFieldDef(fieldNum: 253, size: 4, baseType: .uint32)
    static let startTime         = FITFieldDef(fieldNum: 2, size: 4, baseType: .uint32)
    static let totalElapsedTime  = FITFieldDef(fieldNum: 7, size: 4, baseType: .uint32)   // s * 1000
    static let totalTimerTime    = FITFieldDef(fieldNum: 8, size: 4, baseType: .uint32)   // s * 1000
    static let totalDistance     = FITFieldDef(fieldNum: 9, size: 4, baseType: .uint32)   // m * 100
    static let totalCalories     = FITFieldDef(fieldNum: 11, size: 2, baseType: .uint16)
    static let avgHeartRate      = FITFieldDef(fieldNum: 15, size: 1, baseType: .uint8)
    static let maxHeartRate      = FITFieldDef(fieldNum: 16, size: 1, baseType: .uint8)
    static let event             = FITFieldDef(fieldNum: 0, size: 1, baseType: .enumType)  // 9 = lap
    static let eventType         = FITFieldDef(fieldNum: 1, size: 1, baseType: .enumType)  // 1 = stop
}

// MARK: - Session Message (Global Message 18)

enum FITSessionFields {
    static let timestamp         = FITFieldDef(fieldNum: 253, size: 4, baseType: .uint32)
    static let startTime         = FITFieldDef(fieldNum: 2, size: 4, baseType: .uint32)
    static let totalElapsedTime  = FITFieldDef(fieldNum: 7, size: 4, baseType: .uint32)
    static let totalTimerTime    = FITFieldDef(fieldNum: 8, size: 4, baseType: .uint32)
    static let totalDistance     = FITFieldDef(fieldNum: 9, size: 4, baseType: .uint32)
    static let totalCalories     = FITFieldDef(fieldNum: 11, size: 2, baseType: .uint16)
    static let sport             = FITFieldDef(fieldNum: 5, size: 1, baseType: .enumType)
    static let subSport          = FITFieldDef(fieldNum: 6, size: 1, baseType: .enumType)
    static let avgHeartRate      = FITFieldDef(fieldNum: 16, size: 1, baseType: .uint8)
    static let maxHeartRate      = FITFieldDef(fieldNum: 17, size: 1, baseType: .uint8)
    static let event             = FITFieldDef(fieldNum: 0, size: 1, baseType: .enumType)
    static let eventType         = FITFieldDef(fieldNum: 1, size: 1, baseType: .enumType)
}

// MARK: - Activity Message (Global Message 34)

enum FITActivityFields {
    static let timestamp         = FITFieldDef(fieldNum: 253, size: 4, baseType: .uint32)
    static let totalTimerTime    = FITFieldDef(fieldNum: 0, size: 4, baseType: .uint32)   // s * 1000
    static let numSessions       = FITFieldDef(fieldNum: 1, size: 2, baseType: .uint16)
    static let type              = FITFieldDef(fieldNum: 2, size: 1, baseType: .enumType)  // 0 = manual
    static let event             = FITFieldDef(fieldNum: 3, size: 1, baseType: .enumType)  // 26 = activity
    static let eventType         = FITFieldDef(fieldNum: 4, size: 1, baseType: .enumType)  // 1 = stop
}
