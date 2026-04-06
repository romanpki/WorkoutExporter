import Foundation

/// Lightweight XML string builder for iOS (XMLDocument is macOS-only)
final class XMLBuilder {
    private var content = ""
    private var indentLevel = 0
    private let indentString = "  "

    var result: String { content }

    func xmlDeclaration() {
        content += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    }

    func openTag(_ name: String, attributes: [(String, String)] = [], selfClosing: Bool = false) {
        let indent = String(repeating: indentString, count: indentLevel)
        var tag = "\(indent)<\(name)"
        for (key, value) in attributes {
            tag += " \(key)=\"\(escapeXML(value))\""
        }
        if selfClosing {
            tag += "/>\n"
        } else {
            tag += ">\n"
            indentLevel += 1
        }
        content += tag
    }

    func closeTag(_ name: String) {
        indentLevel = max(0, indentLevel - 1)
        let indent = String(repeating: indentString, count: indentLevel)
        content += "\(indent)</\(name)>\n"
    }

    func element(_ name: String, value: String, attributes: [(String, String)] = []) {
        let indent = String(repeating: indentString, count: indentLevel)
        var tag = "\(indent)<\(name)"
        for (key, val) in attributes {
            tag += " \(key)=\"\(escapeXML(val))\""
        }
        tag += ">\(escapeXML(value))</\(name)>\n"
        content += tag
    }

    func selfClosingElement(_ name: String, attributes: [(String, String)]) {
        let indent = String(repeating: indentString, count: indentLevel)
        var tag = "\(indent)<\(name)"
        for (key, value) in attributes {
            tag += " \(key)=\"\(escapeXML(value))\""
        }
        tag += "/>\n"
        content += tag
    }

    func raw(_ text: String) {
        content += text
    }

    static func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    private func escapeXML(_ string: String) -> String {
        Self.escapeXML(string)
    }
}
