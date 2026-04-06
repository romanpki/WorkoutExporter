import Foundation

/// CRC-16 implementation for the FIT protocol (polynomial 0xA001)
enum FITCRC {
    private static let table: [UInt16] = {
        var table = [UInt16](repeating: 0, count: 256)
        for i in 0..<256 {
            var crc = UInt16(i)
            for _ in 0..<8 {
                if crc & 1 != 0 {
                    crc = (crc >> 1) ^ 0xA001
                } else {
                    crc >>= 1
                }
            }
            table[i] = crc
        }
        return table
    }()

    static func calculate(_ data: Data) -> UInt16 {
        var crc: UInt16 = 0
        for byte in data {
            let index = Int((crc ^ UInt16(byte)) & 0xFF)
            crc = (crc >> 8) ^ table[index]
        }
        return crc
    }

    static func update(_ crc: UInt16, with byte: UInt8) -> UInt16 {
        let index = Int((crc ^ UInt16(byte)) & 0xFF)
        return (crc >> 8) ^ table[index]
    }

    static func update(_ crc: UInt16, with data: Data) -> UInt16 {
        var result = crc
        for byte in data {
            result = update(result, with: byte)
        }
        return result
    }
}
