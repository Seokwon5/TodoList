//
//  ViewController.swift
//  TodoList
//
//  Created by 이석원 on 2022/04/05.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var tasks = [Task](){
        didSet {
            self.saveTasks() //추가될때마다 userDefualts에 저장됨.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTasks() //저장된 데이터들 불러오기.
        
    }

    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
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
