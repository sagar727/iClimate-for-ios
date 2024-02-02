//
//  ApiError.swift
//  iClimate
//
//  Created by Sagar Modi on 08/01/2024.
//

import Foundation

enum ApiError: Error {
    case invalidRequest(String)
    case invalidResponse(String)
    case sessionTimeout
    case unauthorized
}
