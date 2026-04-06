import Foundation

/// Core FIT binary file encoder
final class FITEncoder {
    private var data = Data()
    private var crc: UInt16 = 0
    private let headerSize: UInt8 = 14
    private let protocolVersion: UInt8 = 0x20  // v2.0
    private let profileVersion: UInt16 = 2140  // v21.40

    /// Write the file header (14 bytes). Data size will be patched in finalize().
    func writeFileHeader() {
        var header = Data()

        // Byte 0: header size
        header.append(headerSize)

        // Byte 1: protocol version
        header.append(protocolVersion)

        // Bytes 2-3: profile version
        header.appendUInt16(profileVersion)

        // Bytes 4-7: data size (placeholder, patched in finalize)
        header.appendUInt32(0)

        // Bytes 8-11: ".FIT" ASCII
        header.append(contentsOf: [0x2E, 0x46, 0x49, 0x54])

        // Bytes 12-13: CRC of header bytes 0-11
        let headerCRC = FITCRC.calculate(Data(header[0..<12]))
        header.appendUInt16(headerCRC)

        data.append(header)
        crc = FITCRC.update(0, with: header)
    }

    /// Write a definition message
    func writeDefinitionMessage(_ definition: FITDefinitionMessage) {
        let encoded = definition.encode()
        data.append(encoded)
        crc = FITCRC.update(crc, with: encoded)
    }

    /// Write a data message
    func writeDataMessage(_ message: FITDataMessage) {
        let encoded = message.encode()
        data.append(encoded)
        crc = FITCRC.update(crc, with: encoded)
    }

    /// Finalize the file: patch header data size, append file CRC
    func finalize() -> Data {
        // Calculate data size (everything after header, before file CRC)
        let dataSize = UInt32(data.count - Int(headerSize))

        // Patch data size in header (bytes 4-7)
        var le = dataSize.littleEndian
        let sizeBytes = Data(bytes: &le, count: 4)
        data.replaceSubrange(4..<8, with: sizeBytes)

        // Recalculate CRC over all data (header included with patched size)
        let fileCRC = FITCRC.calculate(data)

        // Append file CRC (2 bytes, little-endian)
        data.appendUInt16(fileCRC)

        return data
    }
}
