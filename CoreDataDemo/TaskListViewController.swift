//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 10.05.2021.
//

import UIKit

protocol TaskViewControllereDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        taskList = StorageManager.shared.fetchData()
    }

    @objc private func addNewTask() {
        showAlert("New Task", "Do you want to add new task?", .add)
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func insertNewTask() {
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            taskList.remove(at: indexPath.row)
            StorageManager.shared.deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert("Rename", "Do you want to rename task?", .edit, indexPath.row)
    }
}

// MARK: - TaskViewControllereDelegate
extension TaskListViewController: TaskViewControllereDelegate {
    func reloadData() {
        taskList = StorageManager.shared.fetchData()
        tableView.reloadData()
    }
}

// MARK: - Configure Alert Controller
extension TaskListViewController {
    
    private enum TypesForAlert {
        case add
        case edit
    }
    
    private func showAlert(_ title: String, _ message: String, _ type: TypesForAlert, _ index: Int? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        switch type {
        case .add:
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                StorageManager.shared.saveTask(task) { newTask in
                    self.taskList.append(newTask)
                    self.insertNewTask()
                }
            }
            alert.addAction(saveAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        case .edit:
            guard let index = index else { return }
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
                StorageManager.shared.editTask(title, index: index)
                self.taskList = StorageManager.shared.fetchData()
                self.tableView.reloadData()
            }
            alert.addAction(saveAction)
            alert.addTextField { textField in
                textField.text = self.taskList[index].title
            }
        }
        
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
}
