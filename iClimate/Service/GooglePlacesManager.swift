//
//  GooglePlacesManager.swift
//  iClimate
//
//  Created by Sagar Modi on 22/01/2024.
//

import Foundation
import GooglePlaces
import Observation
import SwiftUI

@Observable
final class GooglePlacesManager {
    
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    var searchResults: [PlaceResult] = []
    
    private init(){
        
    }
    
    func findPlaces(query: String, completion: @escaping ([(PlaceResult)]) -> Void) {
        let filter = GMSAutocompleteFilter()
        filter.types = ["locality", "administrative_area_level_3", "administrative_area_level_1", "country"]
        
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { predictions, error in
            guard let predictions = predictions, error == nil else {
                print("Autocomplete predictions error: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            let dispatchGroup = DispatchGroup()
            var places: [PlaceResult] = []
            
            for prediction in predictions {
                dispatchGroup.enter()
                
                self.client.lookUpPlaceID(prediction.placeID) { place, error in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let error = error {
                        print("Look-up place error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let place = place else {
                        print("Look-up place returned nil")
                        return
                    }

                    let placeResult = PlaceResult(city: place.formattedAddress ?? "", lat: place.coordinate.latitude, long: place.coordinate.longitude)
                    places.append(placeResult)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(places)
            }
        }
    }
}
