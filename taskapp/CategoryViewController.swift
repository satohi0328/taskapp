//
//  CategoryViewController.swift
//  taskapp
//
//  Created by Hiroki Sato on 2020/06/07.
//  Copyright © 2020 hiroki.sato. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var categoryTextField: UITextField!
    let realm = try! Realm()
    
    var categoryArray = try! Realm().objects(Category.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.category
        
        return cell
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let category = self.categoryArray[indexPath.row]
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(category)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        }
    }
    
    @IBAction func addCategory(_ sender: Any) {
        // 未入力の場合
        if categoryTextField.text == "" {
            showAlert(Title: "Error", Message: "未入力です")
            return
        }
        
        // 既に存在するカテゴリの場合
//        let results = realm.objects(Category.self).filter("category == '\(String(describing: categoryTextField.text))'")
        let wkText = categoryTextField.text
        let results = realm.objects(Category.self).filter("category == '\(wkText!)'")
        if results.count > 0 {
            showAlert(Title: "Error", Message: "登録済みです")
            self.categoryTextField.text = ""
            return
        }
        
        let category:Category = Category()
        // Realmにカテゴリの追加
        category.category = self.categoryTextField.text!
        
        let allCategorys = realm.objects(Category.self)
        if allCategorys.count != 0 {
            category.id = allCategorys.max(ofProperty: "id")! + 1
        }
        
        try! realm.write {
            self.realm.add(category, update: .modified)
        }

        // テーブル再読み込み
        categoryTableView.reloadData()
        
    }
    
    private func showAlert(Title argTitle:String ,Message argMessage:String){
        let alert: UIAlertController = UIAlertController(title: argTitle, message: argMessage, preferredStyle:  UIAlertController.Style.alert)
        
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(defaultAction)
        
        //アラート表示
        present(alert, animated: true, completion: nil)
    }
    
    
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


