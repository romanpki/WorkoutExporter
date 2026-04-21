import Foundation
import AuthenticationServices

struct StravaTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Int

    var isExpired: Bool {
        Date().timeIntervalSince1970 >= Double(expiresAt)
    }
}

struct StravaAthlete: Codable {
    let id: Int
    let firstname: String
    let lastname: String
    let profile: String? // avatar URL

    var fullName: String { "\(firstname) \(lastname)" }
}

@Observable
@MainActor
final class StravaAuthManager {
    private(set) var isConnected = false
    private(set) var athlete: StravaAthlete?
    private(set) var tokens: StravaTokens?
    var errorMessage: String?

    private static let tokensKey = "strava_tokens"
    private static let athleteKey = "strava_athlete"

    init() {
        // Restore from Keychain
        tokens = KeychainHelper.load(key: Self.tokensKey, as: StravaTokens.self)
        athlete = KeychainHelper.load(key: Self.athleteKey, as: StravaAthlete.self)
        isConnected = tokens != nil
    }

    // MARK: - OAuth2 Authorization

    func authorize() async {
        errorMessage = nil

        guard StravaConstants.isConfigured else {
            errorMessage = String(localized: "strava.error.notConfigured")
            return
        }

        var components = URLComponents(string: StravaConstants.authorizeURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: StravaConstants.clientID),
            URLQueryItem(name: "redirect_uri", value: StravaConstants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: StravaConstants.scope),
            URLQueryItem(name: "approval_prompt", value: "auto"),
        ]

        guard let authURL = components.url else {
            errorMessage = "Invalid authorization URL"
            return
        }

        do {
            let callbackURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
                let session = ASWebAuthenticationSession(
                    url: authURL,
                    callbackURLScheme: StravaConstants.callbackScheme
                ) { url, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let url {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: StravaError.authFailed)
                    }
                }
                session.prefersEphemeralWebBrowserSession = false
                session.presentationContextProvider = WebAuthContextProvider.shared
                session.start()
            }

            // Extract code from callback URL
            guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "code" })?.value else {
                errorMessage = String(localized: "strava.error.noCode")
                return
            }

            // Exchange code for tokens
            try await exchangeCodeForTokens(code)

        } catch is CancellationError {
            // User cancelled — do nothing
        } catch let error as ASWebAuthenticationSessionError where error.code == .canceledLogin {
            // User cancelled — do nothing
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Token Exchange

    private func exchangeCodeForTokens(_ code: String) async throws {
        let url = URL(string: StravaConstants.tokenURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "client_id": StravaConstants.clientID,
            "client_secret": StravaConstants.clientSecret,
            "code": code,
            "grant_type": "authorization_code",
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StravaError.tokenExchangeFailed
        }

        let tokenResponse = try JSONDecoder().decode(StravaTokenResponse.self, from: data)
        let newTokens = StravaTokens(
            accessToken: tokenResponse.access_token,
            refreshToken: tokenResponse.refresh_token,
            expiresAt: tokenResponse.expires_at
        )

        tokens = newTokens
        athlete = tokenResponse.athlete
        isConnected = true

        KeychainHelper.save(key: Self.tokensKey, value: newTokens)
        if let athlete = tokenResponse.athlete {
            KeychainHelper.save(key: Self.athleteKey, value: athlete)
        }
    }

    // MARK: - Token Refresh

    func validAccessToken() async throws -> String {
        guard var currentTokens = tokens else {
            throw StravaError.notConnected
        }

        if currentTokens.isExpired {
            currentTokens = try await refreshTokens(currentTokens)
        }

        return currentTokens.accessToken
    }

    private func refreshTokens(_ expired: StravaTokens) async throws -> StravaTokens {
        let url = URL(string: StravaConstants.tokenURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "client_id": StravaConstants.clientID,
            "client_secret": StravaConstants.clientSecret,
            "refresh_token": expired.refreshToken,
            "grant_type": "refresh_token",
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StravaError.tokenRefreshFailed
        }

        let refreshResponse = try JSONDecoder().decode(StravaRefreshResponse.self, from: data)
        let newTokens = StravaTokens(
            accessToken: refreshResponse.access_token,
            refreshToken: refreshResponse.refresh_token,
            expiresAt: refreshResponse.expires_at
        )

        tokens = newTokens
        isConnected = true
        KeychainHelper.save(key: Self.tokensKey, value: newTokens)

        return newTokens
    }

    // MARK: - Disconnect

    func disconnect() async {
        if let accessToken = tokens?.accessToken {
            // Revoke token on Strava
            var request = URLRequest(url: URL(string: StravaConstants.deauthorizeURL)!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            _ = try? await URLSession.shared.data(for: request)
        }

        tokens = nil
        athlete = nil
        isConnected = false
        errorMessage = nil

        KeychainHelper.delete(key: Self.tokensKey)
        KeychainHelper.delete(key: Self.athleteKey)
    }
}

// MARK: - API Response models

private struct StravaTokenResponse: Codable {
    let access_token: String
    let refresh_token: String
    let expires_at: Int
    let athlete: StravaAthlete?
}

private struct StravaRefreshResponse: Codable {
    let access_token: String
    let refresh_token: String
    let expires_at: Int
}

// MARK: - Web Auth Presentation Context

private final class WebAuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = WebAuthContextProvider()

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

// MARK: - Errors

enum StravaError: LocalizedError {
    case authFailed
    case tokenExchangeFailed
    case tokenRefreshFailed
    case notConnected
    case uploadFailed(String)

    var errorDescription: String? {
        switch self {
        case .authFailed: String(localized: "strava.error.auth")
        case .tokenExchangeFailed: String(localized: "strava.error.token")
        case .tokenRefreshFailed: String(localized: "strava.error.refresh")
        case .notConnected: String(localized: "strava.error.notConnected")
        case .uploadFailed(let msg): msg
        }
    }
}
