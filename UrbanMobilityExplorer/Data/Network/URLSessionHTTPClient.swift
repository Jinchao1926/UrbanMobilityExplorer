//
//  URLSessionHTTPClient.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

/// Native URLSession implementation conforming to `HTTPClient`.
/// The CityBikes API requires no authentication tokens or custom request interceptors.
/// Therefore, Alamofire is not adopted to avoid unnecessary third-party dependencies.
struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    nonisolated func data(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
