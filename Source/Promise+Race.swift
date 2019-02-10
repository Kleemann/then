//
//  Promise+Race.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

extension Promises {
    
    /// `Promise.race(p1, p2, p3, p4...)`Takes the state of the fastest returning promise.
    /// If the first fails, it fails. If the first resolves, it resolves.
    public static func race<T>(_ promises: Promise<T>...) -> Promise<T> {
        return Promise { resolve, reject in
            for p in promises {
                p.then { t in
                    resolve(t)
                }.onError { e in
                    reject(e)
                }
            }
        }
    }
    
    public static func relayRace<T>(_ promises: Promise<T>...) -> Promise<T> {
        return Promise { resolve, reject in
            var promises = promises // Mutable copy
          
            func startNext(promise: Promise<T> ) {
                promise.then { t in
                    resolve(t)
                }.onError { error in
                    guard promises.count > 0 else {
                        reject(error)
                        return
                    }
                    startNext(promise: promises.removeFirst())
                }

            }
            
            startNext(promise: promises.removeFirst())
        }
    }
}
