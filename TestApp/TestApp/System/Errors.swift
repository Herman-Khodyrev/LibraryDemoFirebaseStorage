//
//  Error.swift
//  TestApp
//
//  Created by Герман on 16.01.22.
//

import Foundation
import UIKit


class Errors{
    
    private init(){}
    
    static let shared = Errors()
    
    func getError(stringOfError: String) -> UIAlertController{
        let alert = UIAlertController(title: "Error", message: stringOfError, preferredStyle: .alert)
        let buttonOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(buttonOk)
        return alert
    }
    
}
