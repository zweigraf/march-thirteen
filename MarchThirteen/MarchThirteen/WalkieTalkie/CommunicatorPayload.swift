//
//  CommunicatorPayload.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation

public protocol CommunicatorPayload {
    /// Initializes a new object from the given dictionary. Should return nil
    /// if the dictionary cannot be decoded.
    ///
    /// - Parameters:
    ///   - from: A dictionary representation retrieved via `dictionaryRepresentation`
    ///     of the same type.
    init?(from dictionary: [String: Any])
    
    /// Encodes this object as a dictionary. Dictionary layout can vary, but 
    /// this type should be able to decode that dictionary via `init?(from:)` 
    /// into an instance of itself. The values & keys in the dictionary must be 
    /// NSCoding compliant.
    var dictionaryRepresentation: [String: Any] { get }
}
