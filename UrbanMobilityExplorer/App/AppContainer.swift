//
//  AppContainer.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

/// Lightweight composition root for app dependencies.
///
/// The project is small enough to wire dependencies manually here. For a larger
/// app, consider introducing a dedicated DI container to manage registrations,
/// scopes, and environment-specific dependency graphs.
final class AppContainer {
    private let stationRepository: StationRepository
    private let favoritesRepository: FavoritesRepository

    init() {
        let httpClient = URLSessionHTTPClient()
        let remoteDataSource = CityBikesV2StationService(httpClient: httpClient)
        let stationCache = StationCacheStore()
        let favoritesCache = FavoritesCacheStore()

        stationRepository = DefaultStationRepository(
            remote: remoteDataSource,
            cache: stationCache
        )
        favoritesRepository = DefaultFavoritesRepository(cache: favoritesCache)
    }

    func makeStationListViewModel() -> StationListViewModel {
        StationListViewModel(
            loadNetworks: LoadNetworksUseCase(repository: stationRepository),
            loadStations: LoadStationsUseCase(repository: stationRepository)
        )
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            loadFavorites: LoadFavoritesUseCase(repository: favoritesRepository),
            toggleFavorite: ToggleFavoriteUseCase(repository: favoritesRepository)
        )
    }
}
