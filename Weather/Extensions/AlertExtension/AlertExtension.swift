//
//  AlertExtension.swift
//  Weather
//
//  Created by Mohamed Hadwa on 13/09/2023.
//

import Foundation
import UIKit
extension UIViewController {
    func showAlert (msg : String ,type :String) {
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        alert.addAction(UIAlertAction(title: "Setting", style: .default ,handler: { action in
            if type == "locationService"{
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            else if type == "authSettings"{
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)

            }
        } ))
        present(alert, animated: true)
    }

}
