//
//  Promise+ResolveOn.swift
//  then
//
//  Created by Mads Kleemann on 26/02/2019.
//  Copyright © 2019 s4cha. All rights reserved.
//

import Foundation

extension Promise {
    public func resolveOn(_ queue: DispatchQueue) -> Promise<T> {
        let p = newLinkedPromise()
        syncStateWithCallBacks(
            success: { t in
                queue.async {
                    p.fulfill(t)
                }
            }, failure: { error in
                queue.async {
                    p.reject(error)
                }
            }, progress: { (progress) in
                p.setProgress(progress)
            })
        return p
    }
}
