import Foundation

/// Represents a FIT Definition Message
struct FITDefinitionMessage {
    let localMessageType: UInt8    // 0-15
    let globalMessageNumber: UInt16
    let fields: [FITFieldDef]

    /// Encode to binary data
    func encode() -> Data {
        var data = Data()

        // Record header: bit 6 = 1 (definition), bits 0-3 = local message type
        let header: UInt8 = 0x40 | (localMessageType & 0x0F)
        data.append(header)

        // Reserved byte
        data.append(0x00)

        // Architecture: 0 = little-endian
        data.append(0x00)

        // Global message number (2 bytes, little-endian)
        data.appendUInt16(globalMessageNumber)

        // Number of fields
        data.append(UInt8(fields.count))

        // Field definitions
        for field in fields {
            data.append(field.fieldNum)
            data.append(field.size)
            data.append(field.baseType.rawValue)
        }

        return data
    }
}
