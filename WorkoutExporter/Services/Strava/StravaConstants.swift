import Foundation

enum StravaConstants {
    /// Register your app at https://www.strava.com/settings/api
    /// Set the "Authorization Callback Domain" to: workoutexporter
    /// Then replace these values with your own credentials.
    static let clientID = "YOUR_STRAVA_CLIENT_ID"
    static let clientSecret = "YOUR_STRAVA_CLIENT_SECRET"

    static var isConfigured: Bool {
        clientID != "YOUR_STRAVA_CLIENT_ID" && clientSecret != "YOUR_STRAVA_CLIENT_SECRET"
    }

    static let authorizeURL = "https://www.strava.com/oauth/mobile/authorize"
    static let tokenURL = "https://www.strava.com/oauth/token"
    static let uploadURL = "https://www.strava.com/api/v3/uploads"
    static let athleteURL = "https://www.strava.com/api/v3/athlete"
    static let deauthorizeURL = "https://www.strava.com/oauth/deauthorize"

    static let callbackScheme = "workoutexporter"
    static let redirectURI = "workoutexporter://strava/callback"
    static let scope = "activity:write,activity:read"
}
