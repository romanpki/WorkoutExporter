import Foundation
import HealthKit

struct StravaUploadResponse: Codable {
    let id: Int
    let status: String
    let error: String?
}

struct StravaUploadStatus: Codable {
    let id: Int
    let status: String
    let activity_id: Int?
    let error: String?
}

@Observable
@MainActor
final class StravaUploader {
    var isUploading = false
    var uploadProgress: String?
    var errorMessage: String?
    var uploadedActivityID: Int?

    private let authManager: StravaAuthManager
    private let healthKitManager: HealthKitManager

    init(authManager: StravaAuthManager, healthKitManager: HealthKitManager) {
        self.authManager = authManager
        self.healthKitManager = healthKitManager
    }

    /// Upload a workout to Strava as a FIT file
    func upload(workout: HKWorkout) async {
        guard authManager.isConnected else {
            errorMessage = String(localized: "strava.error.notConnected")
            return
        }

        isUploading = true
        errorMessage = nil
        uploadedActivityID = nil
        uploadProgress = String(localized: "strava.upload.preparing")

        do {
            // 1. Export workout as FIT
            let coordinator = ExportCoordinator(healthKitManager: healthKitManager)
            let (fitData, fileName) = try await coordinator.export(workout: workout, format: .fit)

            // 2. Get valid access token
            uploadProgress = String(localized: "strava.upload.uploading")
            let accessToken = try await authManager.validAccessToken()

            // 3. Upload via multipart/form-data
            let uploadResponse = try await performUpload(
                fitData: fitData,
                fileName: fileName,
                activityName: WorkoutTypeMapping.name(for: workout.workoutActivityType),
                accessToken: accessToken
            )

            // 4. Poll for processing status
            uploadProgress = String(localized: "strava.upload.processing")
            let status = try await pollUploadStatus(uploadID: uploadResponse.id, accessToken: accessToken)

            if let activityID = status.activity_id {
                uploadedActivityID = activityID
                uploadProgress = nil
            } else if let error = status.error {
                errorMessage = error
            }

        } catch {
            errorMessage = error.localizedDescription
        }

        isUploading = false
    }

    // MARK: - Multipart Upload

    private func performUpload(
        fitData: Data,
        fileName: String,
        activityName: String,
        accessToken: String
    ) async throws -> StravaUploadResponse {
        let boundary = UUID().uuidString
        let url = URL(string: StravaConstants.uploadURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // data_type field
        body.appendMultipart(boundary: boundary, name: "data_type", value: "fit")

        // activity name
        body.appendMultipart(boundary: boundary, name: "name", value: activityName)

        // file field
        body.appendMultipartFile(boundary: boundary, name: "file", filename: fileName, mimeType: "application/vnd.ant.fit", data: fitData)

        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StravaError.uploadFailed("Invalid response")
        }

        if httpResponse.statusCode == 201 {
            return try JSONDecoder().decode(StravaUploadResponse.self, from: data)
        } else if httpResponse.statusCode == 401 {
            throw StravaError.tokenRefreshFailed
        } else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw StravaError.uploadFailed("HTTP \(httpResponse.statusCode): \(errorBody)")
        }
    }

    // MARK: - Poll Upload Status

    private func pollUploadStatus(uploadID: Int, accessToken: String, maxAttempts: Int = 10) async throws -> StravaUploadStatus {
        let url = URL(string: "\(StravaConstants.uploadURL)/\(uploadID)")!

        for attempt in 0..<maxAttempts {
            // Wait before polling (exponential backoff: 2s, 3s, 4s, ...)
            try await Task.sleep(for: .seconds(2 + attempt))

            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                continue
            }

            let status = try JSONDecoder().decode(StravaUploadStatus.self, from: data)

            if status.activity_id != nil || status.error != nil {
                return status
            }
        }

        // Timeout — return last known status
        return StravaUploadStatus(id: uploadID, status: "processing", activity_id: nil, error: nil)
    }
}

// MARK: - Data multipart helpers

private extension Data {
    mutating func appendMultipart(boundary: String, name: String, value: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }

    mutating func appendMultipartFile(boundary: String, name: String, filename: String, mimeType: String, data: Data) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(data)
        append("\r\n".data(using: .utf8)!)
    }
}
