//
//  ViewController.swift
//  taskapp
//
//  Created by Hiroki Sato on 2020/05/31.
//  Copyright © 2020 hiroki.sato. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource , UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    // Reamインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    var pickerView: UIPickerView = UIPickerView()
    var categoryArray = try! Realm().objects(Category.self)
    
    @IBOutlet weak var categoryTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        tableView.delegate = self
        tableView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        self.categoryTextField.inputView = pickerView
        
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        switch segue.identifier {
        case "cellSegue": //テーブルビューのセルを選択したときの遷移
            let inputViewController:InputViewController = segue.destination as! InputViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
            break
        default: // 上記以外、タスク追加する場合の遷移
            let inputViewController:InputViewController = segue.destination as! InputViewController
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
            break
            
        }
        
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func searchCategory(_ sender: Any) {
        //検索バーに文字列が存在しない場合
        if categoryTextField.text! == "" {
            taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        } else{
            let predicate = NSPredicate(format: "category.category == %@",categoryTextField.text!)
            taskArray = realm.objects(Task.self).filter(predicate)
        }
        tableView.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    // 内容の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return categoryArray[row].category
    }
    // Pickerで選択されたとき
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text! =  categoryArray[row].category
    }
    
    @IBAction func SearchCancelButton(_ sender: Any) {
        taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        categoryTextField.text! = ""
        tableView.reloadData()
        
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    //    // 検索バーによる検索処理
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //        taskArray = try! Realm().objects(Task.self).filter("category == %@",searchBar.text!)
    //        tableView.reloadData()
    //        showTasks()
    //    }
    //
    //    // 検索バーのCancel押下時
    //    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    //        print("検索Cancel")
    //        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    //        tableView.reloadData()
    //    }
    //    //検索バーの状態が変わった場合
    //    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //        searchCategory(searchBar.text!)
    //    }
    //
    //    func searchCategory(_ searchText: String) {
    //        //検索バーに文字列が存在する場合
    //        if searchText != "" {
    //            taskArray = try! Realm().objects(Task.self).filter("category == %@",searchText)
    //
    //            // 検索バーがからの場合
    //        } else {
    //            // 全表示
    //            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    //        }
    //        //tableViewを再読み込みする
    //        tableView.reloadData()
    //    }
}

