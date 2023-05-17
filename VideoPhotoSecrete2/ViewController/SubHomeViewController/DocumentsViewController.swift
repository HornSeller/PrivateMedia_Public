//
//  DocumentsViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataTable = userDefault.stringArray(forKey: "listDocumentsAlbum")
        return dataTable!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! DocumentsTableViewCell
        let dataTable = userDefault.stringArray(forKey: "listDocumentsAlbum")
        cell.titleLb.text = dataTable![indexPath.row]
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataTable = userDefault.stringArray(forKey: "listDocumentsAlbum")
        let name = dataTable![indexPath.row]
        self.navigationController?.pushViewController(SubDocumentsViewController.makeSelf(name: name), animated: true)
    }
    

    var defaultValue = ["listDocumentsAlbum": []]
    let userDefault = UserDefaults.standard
    let fileManager = FileManager.default
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefault.register(defaults: defaultValue)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        //UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ]
        
        tableView.register(UINib(nibName: "DocumentsTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 73
        
        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let documentsURL = documentURL.appendingPathComponent("Documents")
        
        if !self.fileManager.fileExists(atPath: documentsURL.path) {
            do {
                try self.fileManager.createDirectory(atPath: documentsURL.path, withIntermediateDirectories: true, attributes: nil)
                let documentPath = documentsURL.path
                print("Path to documents directory: \(documentPath)")
            } catch {
                print("Error creating directory: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func createAlbumBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Create album", message: "", preferredStyle: .alert)
        alert.addTextField(){ (textfield) in
            textfield.placeholder = "Enter album name here"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .cancel, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listDocumentsAlbum") else {
                return
            }
            
            for fileName in fileNames {
                if textField?.text == fileName {
                   let alert = UIAlertController(title: "Error", message: "Album has existed", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                   self.present(alert, animated: true)
                   return
                   }
            }
            
            var dataUserdefault = self.userDefault.stringArray(forKey: "listDocumentsAlbum")
            dataUserdefault?.append((textField?.text)!)
            self.userDefault.set(dataUserdefault, forKey: "listDocumentsAlbum")
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listDocumentsAlbum") else {
                return
            }
            
            guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let documentsURL = documentURL.appendingPathComponent("Documents")
            for fileName in fileNames {
                let fileURL = documentsURL.appendingPathComponent(fileName).path
                if !self.fileManager.fileExists(atPath: fileURL) {
                    do {
                        try self.fileManager.createDirectory(atPath: fileURL, withIntermediateDirectories: true, attributes: nil)
                        let documentPath = documentURL.path
                        print("Path to pictures directory: \(documentPath)")
                    } catch {
                        print("Error creating directory: \(error)")
                    }
                }
            }
            
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}
