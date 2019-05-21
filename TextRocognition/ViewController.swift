//
//  ViewController.swift
//  TextRocognition
//
//  Created by User on 18/05/2019.
//  Copyright © 2019 User. All rights reserved.
//

import UIKit
import LanguageTranslator

class ViewController: UIViewController {
    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var outputTextField: UITextView!
    @IBOutlet weak var fromToLabel: UILabel!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let translator = LanguageTranslator(version: "2018-05-01", username: "6987a48d-342e-4a69-8adc-e65b1cc0b9da", password: "MxYSIi6nQP2Y")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        translator.serviceURL = "https://gateway.watsonplatform.net/language-translator/api"
        
        languagePicker.isHidden = true
        setSpinnerActive(isActive: false)
        inputTextField.layer.borderWidth = 1
        inputTextField.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        outputTextField.layer.borderWidth = 1
        outputTextField.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        setLanguages()
    }
    @IBAction func onLanguageSelect(_ sender: Any) {
        view.endEditing(true)
        languagePicker.isHidden = false
    }
    @IBAction func onTranslate(_ sender: Any) {
        languagePicker.isHidden = true
        setSpinnerActive(isActive: true)
        
        translator.identify(text: inputTextField.text) {
            response, error in
            
            guard let languages = response?.result else {
                self.chekErrors(error: error)
                return
            }
            
            TranslationData.delegate.setFromLanguage(id: (languages.languages[0].language))
            self.setLanguagesString()
            self.translateText()
        }
    }
    
    func translateText() {
        var finalText = ""
        
        if !checkLanguages() {
            return
        }
        
        DispatchQueue.main.async {
            self.translator.translate(text: [self.inputTextField?.text ?? "Empty Text"], modelID: TranslationData.delegate.translateMode.id) {
                response, error in
                
                guard let result = response?.result else {
                    self.chekErrors(error: error)
                    return
                }
                
                result.translations.forEach({finalText += $0.translationOutput})
                
                DispatchQueue.main.async {
                    self.outputTextField.text = finalText
                    self.setSpinnerActive(isActive: false)
                    if let error = TranslationData.delegate.addHistory(entry: (TranslationData.delegate.historyLenght, self.inputTextField.text, self.outputTextField.text, TranslationData.delegate.translateMode.name)) {
                        AlertPopup.delegate.alert(view: self, message: error, type: .Error)
                    }
                }
            }
        }
    }
    
    func setLanguagesString() {
        DispatchQueue.main.async {
            self.fromToLabel.text = TranslationData.delegate.translateMode.name
        }
    }
    
    // Запись возможных для перевода языков в модель
    func setLanguages() {
        translator.listIdentifiableLanguages() {
            response, error in
            guard let languagesList = response?.result else {
                self.chekErrors(error: error)
                return
            }
            
            for i in 0...languagesList.languages.count - 1 {
                TranslationData.delegate.addLanguage(language: (languagesList.languages[i].language, languagesList.languages[i].name))
            }
            DispatchQueue.main.async {
                self.languagePicker.reloadAllComponents()
            }
        }
    }
}
// Расширение класса - обработка ошибок
extension ViewController {
    // Функция обработки ошибок запросов в Watson
    private func chekErrors(error: WatsonError?) {
        var errorString = ""
        if let error = error {
            switch error {
            case let .http(statusCode, message, _):
                switch statusCode {
                case .some(404):
                        errorString = "Can't translate word"
                case .some(413):
                        errorString = "Input text is too long"
                    return
                default:
                    if let statusCode = statusCode {
                            errorString = "Error - code: \(statusCode), \(message ?? "")"
                    }
                }
            default:
                errorString = error.localizedDescription
            }
            
            DispatchQueue.main.async {
                self.outputTextField.text = ""
                self.setSpinnerActive(isActive: false)
                AlertPopup.delegate.alert(view: self, message: errorString, type: .Error)
            }
        }
    }
    // Проверка на наличие языков перевода "с" и "на"
    private func checkLanguages() -> Bool {
        if TranslationData.delegate.fromLanguage.id.isEmpty {
            DispatchQueue.main.async {
                self.outputTextField.text = ""
                self.setSpinnerActive(isActive: false)
                AlertPopup.delegate.alert(view: self, message: "Can't recognize language", type: .Error)
            }
            return false
        }
        
        if TranslationData.delegate.toLanguage.id.isEmpty {
            DispatchQueue.main.async {
                self.outputTextField.text = ""
                self.setSpinnerActive(isActive: false)
                AlertPopup.delegate.alert(view: self, message: "Specify language you want to translate to", type: .Error)
            }
            return false
        }
        return true
    }
}

// расширение ViewController для обработки элементов ввода
extension ViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    // Функция обработки поля ввода и скрытия клавиатуры
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touches.first as UITouch?) != nil {
            view.endEditing(true)
            languagePicker.isHidden = true
        }
        super.touchesBegan(touches, with: event)
    }
    // Функции для обработки PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TranslationData.delegate.languages.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TranslationData.delegate.languages[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        TranslationData.delegate.setToLanguage(id: TranslationData.delegate.languages[row].id)
        setLanguagesString()
    }
    
    // Активация/деактивация крутилки ожидания перевода
    private func setSpinnerActive(isActive: Bool) {
        if isActive {
            spinner.isHidden = false
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            spinner.isHidden = true
        }
    }
}
