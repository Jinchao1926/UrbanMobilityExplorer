//
//  HTTPClient.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

protocol HTTPClient {
    func data(from url: URL) async throws -> Data
}
