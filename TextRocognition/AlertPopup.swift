//
//  AlertPopup.swift
//  TextRocognition
//  Класс показа окна ошибки
//  Created by User on 20/05/2019.
//  Copyright © 2019 User. All rights reserved.
//

import UIKit

class AlertPopup: NSObject {
    enum WindowType: String {
        case Error
        case Nitification
    }
    
    static let delegate = AlertPopup()
    
    //Show alert
    func alert(view: UIViewController, message: String, type: WindowType) {
        let alert = UIAlertController(title: type.rawValue, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: (type == WindowType.Error) ? .destructive : .default, handler: nil))
        
        DispatchQueue.main.async(execute: {
            view.present(alert, animated: true, completion: nil)
        })
    }
    
    private override init() {
    }
}
