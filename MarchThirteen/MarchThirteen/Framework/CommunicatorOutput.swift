//
//  CommunicatorOutput.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation

public protocol CommunicatorOutput {
    associatedtype PayloadType: CommunicatorPayload
    init(from: CommunicatorMessage<PayloadType>)
}
