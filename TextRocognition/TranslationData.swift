//
//  TranslationData.swift
//  Класс-модель хранящая данные о переводах
//
//  Created by User on 18/05/2019.
//  Copyright © 2019 User. All rights reserved.
//

import UIKit
import CoreData

class TranslationData: NSObject {
    static let delegate = TranslationData()
    
    // Возможные языки для перевода
    private var _languages = [(id: String, name: String)]()
    var languages: [(id: String, name: String)] {
        get {
            return _languages
        }
    }
    // Язык, с которого совершается перевод
    private var _fromLanguage: (id: String, name: String)
    var fromLanguage: (id: String, name: String) {
        get {
            return _fromLanguage
        }
    }
    // Язык, на который совершается перевод
    private var _toLanguage: (id: String, name: String)
    var toLanguage: (id: String, name: String) {
        get {
            return _toLanguage
        }
    }
    // Модель перевода, напр. ru-en, Russian -> English
    private var _transleteMode: (id: String, name: String)
    var translateMode: (id: String, name: String) {
        get {
            return _transleteMode
        }
    }
    // Массив запросов (история)
    private var _history = [NSManagedObject]()
    var history: [NSManagedObject] {
        get {
            return _history
        }
    }
    
    var historyLenght: Int {
        get {
            return _history.count
        }
    }
    
    private override init() {
        _fromLanguage = ("", "")
        _toLanguage = ("", "")
        _transleteMode = ("", "")
    }
    
    func loadHistory() -> String? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return "Internal error"
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RequestData")
        
        do {
            _history = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            return "Could not fetch. \(error), \(error.userInfo)"
        }
        
        return nil
    }
    
    func addHistory(entry: (id: Int, input: String, output: String, translateMode: String)) -> String? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return "Internal error"
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "RequestData", in: managedContext)
        let requestData = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        requestData.setValue(entry.id, forKey: "id")
        requestData.setValue(entry.input, forKey: "fromString")
        requestData.setValue(entry.output, forKey: "toString")
        requestData.setValue(entry.translateMode, forKey: "translationMode")
        
        do {
            try managedContext.save()
            _history.append(requestData)
        } catch let error as NSError {
            return "Could not save. \(error), \(error.userInfo)"
        }
        
        return nil
    }
    
    func addLanguage(language: (id: String, name: String)) {
        _languages.append(language)
    }
    func setFromLanguage(id: String) {
        guard let language = getlanguage(id: id) else {
            return
        }
        _fromLanguage = language
        formString()
    }
    func setToLanguage(id: String) {
        guard let language = getlanguage(id: id) else {
            return
        }
        _toLanguage = language
        formString()
    }
    // Возврашает кореж языка по идентификатору языка
    func getlanguage(id: String) -> (id: String, name: String)? {
        var retValue: (id: String, name: String)? = nil
        languages.forEach({ if $0.id == id {
            retValue = ($0.id, $0.name)
            }
        })
        
        return retValue
    }
    // Функция формирует модель перевода
    private func formString() {
        _transleteMode.id = _fromLanguage.id + "-" + _toLanguage.id
        _transleteMode.name = _fromLanguage.name + " -> " + _toLanguage.name
    }
}
