//
//  AppContainer.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

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
