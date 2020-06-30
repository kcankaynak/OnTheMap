//
//  String+Extension.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 30.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import Foundation

extension String {
    
    /// Purpose of this method
    /// Since UIApplication.shared.open method can't open the links which not contains http || https
    /// This method make url requestable
    mutating func checkHTTPControl() -> String {
        if !self.contains("http") {
            return "http://" + self
        }
        return self
    }
}
