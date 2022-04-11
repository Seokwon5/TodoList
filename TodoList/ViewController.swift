//
//  ViewController.swift
//  TodoList
//
//  Created by 이석원 on 2022/04/05.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var doneButton : UIBarButtonItem?
    var tasks = [Task](){
        didSet {
            self.saveTasks() //추가될때마다 userDefualts에 저장됨.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTasks() //저장된 데이터들 불러오기.
        
    }
    
    //doneButton이 선택되었을때 호출되는 메소드 정의
    @objc func doneButtonTap() {   //selector타입으로 메소드를 가져올경우 @objc를 붙여줘야함.
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true) //doneButton클릭시 편집기능에서 빠져나오도록.
    }

    @IBAction func tapEditButton(_ sender: UIBarButtonItem) { //edit버튼 클릭 시 목록들이 편집모드로 바뀌도록.
        guard !self.tasks.isEmpty else { return } //할 일 목록이 비어있지 않다면,
        self.navigationItem.leftBarButtonItem = self.doneButton //doneButton으로 변경
        self.tableView.setEditing(true, animated: true ) //편집기능을 true로.
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 추가", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
            guard let title = alert.textFields?[0].text else {return}
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "할 일을 입력해주세요."
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func saveTasks() { //저장 메소드
        let data = self.tasks.map{
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        let userDefaults = UserDefaults.standard //userDefaults에 접근
        userDefaults.set(data, forKey: "tasks")
    }
    
    func loadTasks() { //데이터 로드 메소드
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String : Any]] else {return} //obj ect메소드는 anytype으로 리턴되므로 dictionary배열 형태로 저장되었으므로 dictionary배열 형태로 typecasting해줌. typecasting 실패시 nil이 될 수 있으므로 가드문으로 옵셔널 바인딩을 해준다.
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else {return nil}
            guard let done = $0["done"] as? Bool else {return nil}
            return Task(title: title, done: done)
        }
    }
    
    
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if task.done { //task.done이 트루이면 체크마크, 아니면 none
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { //편집모드에서 선택된 셀이 어떤것인지 알려주는 메소드.
        self.tasks.remove(at: indexPath.row) //할일 삭제
        tableView.deleteRows(at: [indexPath], with: .automatic) //tableView에서의 줄도 삭제.
        
        if self.tasks.isEmpty {
            self.doneButtonTap() //비어있으면 편집모드에서 자동으로 빠져나오기.
        }
    }
    //셀 재정렬
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row] //배열의 요소에 접근
        tasks.remove(at: sourceIndexPath.row) //원래 위치에 있던 할 일을 삭제
        tasks.insert(task, at: destinationIndexPath.row) //task에서 정의한 할일을 넘겨주고 이동한 위치를 넘겨줌
        self.tasks = tasks //tasks배열에 재정렬한 tasks를 대입시켜줌.
    }
}

 //따로 빼서 uitableviewDelegate 채택하기(체크마크 만들기 위해)
extension ViewController : UITableViewDelegate {
    //어떤 셀이 선택되었는지 알려주는 메소드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row] //배열의 요소에 접근
        task.done = !task.done //반대가 되도록
        self.tasks[indexPath.row] = task //원래의 배열의 요소에 덮어씌우기
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
