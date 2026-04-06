import Foundation

enum ExportFormat: String, CaseIterable, Identifiable {
    case gpx
    case tcx
    case fit
    case csv
    case json
    case xml

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gpx: "GPX"
        case .tcx: "TCX"
        case .fit: "FIT"
        case .csv: "CSV"
        case .json: "JSON"
        case .xml: "XML"
        }
    }

    var fileExtension: String {
        rawValue
    }

    var mimeType: String {
        switch self {
        case .gpx: "application/gpx+xml"
        case .tcx: "application/vnd.garmin.tcx+xml"
        case .fit: "application/vnd.ant.fit"
        case .csv: "text/csv"
        case .json: "application/json"
        case .xml: "application/xml"
        }
    }

    var description: String {
        switch self {
        case .gpx: "GPS Exchange Format — tracé + FC, compatible Strava/Garmin"
        case .tcx: "Training Center XML — données physiologiques détaillées"
        case .fit: "Flexible & Interoperable Data Transfer — format binaire Garmin"
        case .csv: "Tableau — exploitable dans Excel/Google Sheets"
        case .json: "JSON — export brut complet de toutes les données"
        case .xml: "XML — format Apple Health Export"
        }
    }

    var iconName: String {
        switch self {
        case .gpx: "map"
        case .tcx: "heart.text.clipboard"
        case .fit: "waveform.path.ecg"
        case .csv: "tablecells"
        case .json: "curlybraces"
        case .xml: "doc.text"
        }
    }

    var supportsRoute: Bool {
        switch self {
        case .gpx, .tcx, .fit: true
        case .csv, .json, .xml: true // included in data, just not primary purpose
        }
    }
}
