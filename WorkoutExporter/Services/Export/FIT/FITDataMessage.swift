import Foundation

/// Builder for FIT Data Messages
struct FITDataMessage {
    let localMessageType: UInt8
    private var fieldData = Data()

    init(localMessageType: UInt8) {
        self.localMessageType = localMessageType
    }

    /// Append a UInt8 field value
    mutating func appendUInt8(_ value: UInt8) {
        fieldData.append(value)
    }

    /// Append a UInt16 field value (little-endian)
    mutating func appendUInt16(_ value: UInt16) {
        fieldData.appendUInt16(value)
    }

    /// Append a UInt32 field value (little-endian)
    mutating func appendUInt32(_ value: UInt32) {
        fieldData.appendUInt32(value)
    }

    /// Append a SInt32 field value (little-endian)
    mutating func appendSInt32(_ value: Int32) {
        fieldData.appendSInt32(value)
    }

    /// Encode to binary data
    func encode() -> Data {
        var data = Data()

        // Record header: bit 6 = 0 (data), bits 0-3 = local message type
        let header: UInt8 = localMessageType & 0x0F
        data.append(header)

        // Field values
        data.append(fieldData)

        return data
    }
}

// MARK: - Data extensions for binary writing

extension Data {
    mutating func appendUInt16(_ value: UInt16) {
        var le = value.littleEndian
        append(Data(bytes: &le, count: 2))
    }

    mutating func appendUInt32(_ value: UInt32) {
        var le = value.littleEndian
        append(Data(bytes: &le, count: 4))
    }

    mutating func appendSInt32(_ value: Int32) {
        var le = value.littleEndian
        append(Data(bytes: &le, count: 4))
    }
}
