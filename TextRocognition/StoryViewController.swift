//
//  StoryViewController.swift
//  TextRocognition
//  Класс контроллер-представление истории запросов
//  Created by User on 21/05/2019.
//  Copyright © 2019 User. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {
    @IBOutlet weak var historyList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyList.tableFooterView = UIView()
    }
    // Возвращение на первый экран
    @IBAction func onBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
// Расширение класса для обработки таблицы
extension StoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TranslationData.delegate.historyLenght
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = historyList.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as? TableViewCell {
            let translationEnry = TranslationData.delegate.history[indexPath.row]
            cell.fromString.text = translationEnry.value(forKeyPath: "fromString") as? String
            cell.toString.text = translationEnry.value(forKey: "toString") as? String
            cell.translateMode.text = translationEnry.value(forKey: "translationMode") as? String
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = historyList.cellForRow(at: indexPath) as? TableViewCell {
            cell.tintColor = #colorLiteral(red: 0, green: 0.5087351833, blue: 1, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = historyList.cellForRow(at: indexPath) as? TableViewCell {
            cell.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
}
