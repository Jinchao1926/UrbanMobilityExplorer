//
//  CityBikesV2StationMapper.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

/// Adapter for mapping CityBikes API V2 data structures to the app's standardized model format.
enum CityBikesV2StationMapper {
    static func mapNetworks(from data: Data) throws -> [Network] {
        let response = try JSONDecoder().decode(NetworksResponse.self, from: data)

        return response.networks
            .map {
                Network(
                    id: $0.id,
                    name: $0.name,
                    city: $0.location.city,
                    country: $0.location.country,
                    latitude: $0.location.latitude,
                    longitude: $0.location.longitude
                )
            }
            .sorted { lhs, rhs in
                if lhs.country != rhs.country {
                    return lhs.country.localizedCaseInsensitiveCompare(rhs.country) == .orderedAscending
                }

                return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
            }
    }

    static func mapStations(from data: Data) throws -> [Station] {
        let response = try JSONDecoder().decode(NetworkResponse.self, from: data)
        let network = response.network

        return network.stations.map { station in
            Station(
                id: "\(network.id)-\(station.id)",
                name: station.name,
                neighborhood: station.extra?.address ?? network.location.city,
                availableBikes: station.freeBikes ?? 0,
                openDocks: station.emptySlots ?? 0,
                latitude: station.latitude,
                longitude: station.longitude,
                lastUpdated: station.timestamp ?? "Latest update unavailable"
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

// MARK: - V2 Data Struct
private struct NetworksResponse: Decodable {
    let networks: [CityBikesNetworkPayload]
}

private struct NetworkResponse: Decodable {
    let network: CityBikesNetworkPayload
}

/**
 {
   "id": "xian-public-bicycle",
   "name": "Xi'an Public Bicycle",
   "location": {
     "latitude": 34.2688,
     "longitude": 108.9458,
     "city": "西安 (Xi'an)",
     "country": "CN"
   },
   "href": "/v2/networks/xian-public-bicycle",
   "company": [
     "西安城市公共自行车服务管理有"
   ]
 },
 */
private struct CityBikesNetworkPayload: Decodable {
    let id: String
    let name: String
    let location: CityBikesLocationPayload
    let stations: [CityBikesStationPayload]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case stations
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(CityBikesLocationPayload.self, forKey: .location)
        stations = try container.decodeIfPresent([CityBikesStationPayload].self, forKey: .stations) ?? []
    }
}

private struct CityBikesLocationPayload: Decodable {
    let latitude: Double
    let longitude: Double
    let city: String
    let country: String
}

private struct CityBikesStationPayload: Decodable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let timestamp: String?
    let freeBikes: Int?
    let emptySlots: Int?
    let extra: CityBikesStationExtraPayload?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case timestamp
        case freeBikes = "free_bikes"
        case emptySlots = "empty_slots"
        case extra
    }
}

private struct CityBikesStationExtraPayload: Decodable {
    let address: String?
}
