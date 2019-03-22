//
//  ObservingPromise.swift
//  then
//
//  Created by Mads Kleemann on 10/02/2019.
//  Copyright © 2019 s4cha. All rights reserved.
//

import Foundation

/// A promise that keeps the fulfilment and rejection blocks around after either or both is called.
public class ObservingPromise<T>: Promise<T> {
    
    private var _keepBlocks = true
    public override var keepBlocks: Bool {
        get {
            return _keepBlocks
        } set {
            _keepBlocks = newValue
        }
    }
}
