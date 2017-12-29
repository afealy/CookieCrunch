//
//  Swap.swift
//  CookieCrunch
//
//  Created by Anthony Fealy on 12/28/17.
//  Copyright © 2017 Anthony Fealy. All rights reserved.
//

struct Swap: CustomStringConvertible {
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}
