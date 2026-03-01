//
//  LocationSearchService.swift
//  SmartPack
//
//  城市搜索服务 - MKLocalSearchCompleter 封装
//

import Foundation
import MapKit

/// 城市搜索建议（用于 ForEach 稳定标识）
struct CityCompletion: Identifiable {
    let id: String
    let completion: MKLocalSearchCompletion

    init(_ completion: MKLocalSearchCompletion) {
        self.id = "\(completion.title)|\(completion.subtitle)"
        self.completion = completion
    }
}

/// 城市搜索服务
class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var suggestions: [CityCompletion] = []

    private let completer = MKLocalSearchCompleter()
    private var debounceTask: Task<Void, Never>?

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        completer.pointOfInterestFilter = .excludingAll
    }

    /// 更新搜索关键词（300ms 防抖）
    func updateQuery(_ query: String) {
        debounceTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            suggestions = []
            return
        }

        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            completer.queryFragment = query
        }
    }

    /// 解析搜索建议的坐标
    func resolveCoordinates(for completion: MKLocalSearchCompletion) async -> (latitude: Double, longitude: Double)? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            guard let item = response.mapItems.first else { return nil }
            let coord = item.placemark.coordinate
            return (coord.latitude, coord.longitude)
        } catch {
            print("⚠️ 坐标解析失败: \(error.localizedDescription)")
            return nil
        }
    }

    /// 清除搜索状态
    func clear() {
        debounceTask?.cancel()
        suggestions = []
    }

    // MARK: - MKLocalSearchCompleterDelegate

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results.prefix(5).map { CityCompletion($0) }
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("⚠️ 城市搜索失败: \(error.localizedDescription)")
    }
}
