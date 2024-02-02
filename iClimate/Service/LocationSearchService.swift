//
//  LocationSearchService.swift
//  iClimate
//
//  Created by Sagar Modi on 21/01/2024.
//

import Foundation
import CoreLocation
import Observation
import MapKit
import Combine


class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var query: String = ""
    @Published var searchResults: [CityResult] = []
    private var searchCompleter: MKLocalSearchCompleter!
    
    override init(){
        super.init()
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let prefixResults = Array(completer.results.prefix(10))
        getCityList(results: prefixResults) { cityResults in
            DispatchQueue.main.async {
                self.searchResults = cityResults
            }
        }
    }
    
    func performSearch() {
        searchResults.removeAll()
        searchCompleter.queryFragment = query
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    private func getCityList(results: [MKLocalSearchCompletion], completion: @escaping ([CityResult]) -> Void) {
        var searchResults: [CityResult] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            
            let request = MKLocalSearch.Request(completion: result)
            let search = MKLocalSearch(request: request)
            
            search.start { (response,error) in
                defer {
                    dispatchGroup.leave()
                }
                
                guard let response = response else { return }
                
                for item in response.mapItems {
                    if let location = item.placemark.location {
                        let city = item.placemark.locality ?? ""
                        var country = item.placemark.country ?? ""
                        if country.isEmpty {
                            country = item.placemark.countryCode ?? ""
                        }
                        
                        if !city.isEmpty {
                            let cityResult = CityResult(city: city, country: country, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                            searchResults.append(cityResult)
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(searchResults)
        }
    }
    
}
