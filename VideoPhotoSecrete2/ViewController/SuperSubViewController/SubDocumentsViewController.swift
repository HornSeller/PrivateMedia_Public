//
//  SubDocumentsViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 16/05/2023.
//

import UIKit
import QuickLook
import MobileCoreServices
import UniformTypeIdentifiers

class SubDocumentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, QLPreviewControllerDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        documentsName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! SubDocumentsTableViewCell
        
        let fileName = nameArray[indexPath.row]
        let components = fileName.components(separatedBy: ".")
        if components.count > 1 {
            let fileExtension = components[1]
            switch fileExtension {
            case "doc":
                cell.imgView.image = UIImage(named: "doc")
                break
            case "docx":
                cell.imgView.image = UIImage(named: "doc")
                break
            case "xls":
                cell.imgView.image = UIImage(named: "xls")
                break
            case "ppt":
                cell.imgView.image = UIImage(named: "ppt")
                break
            case "pdf":
                cell.imgView.image = UIImage(named: "pdf")
                break
            default:
                cell.imgView.image = UIImage(named: "Document")
                break
            }
            
        }
        cell.titleLb.text = fileName
        do {
            let path = albumUrl?.appendingPathComponent(documentsName[indexPath.row]).path
            let attrs = try fileManager.attributesOfItem(atPath: path!) as NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, yyyy"
            let formattedDate = formatter.string(from: attrs.fileCreationDate()!)
            cell.dateLb.text = formattedDate
            cell.sizeLb.text = fileSize(fromPath: path!)
        } catch {
            print(error.localizedDescription)
        }

        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let documentInteractionController = UIDocumentInteractionController()
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let tempFolder = documentsUrl!.appendingPathComponent("temp")
        
        do {
            try fileManager.createDirectory(atPath: tempFolder.path, withIntermediateDirectories: true)
            let fileName = documentsName[indexPath.row]
            fileUrlForQL = albumUrl!.appendingPathComponent(fileName)
            tempFile = tempFolder.appendingPathComponent(fileName)
            print(fileUrlForQL as Any)
            try fileManager.copyItem(at: fileUrlForQL!, to: tempFile!)
            
            let previewController = QLPreviewController()
            previewController.dataSource = self
            present(previewController, animated: true)
//            documentInteractionController.url = fileUrl
//            documentInteractionController.delegate = self
//            documentInteractionController.presentPreview(animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        tempFile! as any QLPreviewItem
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let documentsFileUrl = documentsUrl.appendingPathComponent("Documents")
        let folderUrl = documentsFileUrl.appendingPathComponent(title!)
        
        for url in urls {
            do {
                let fileName = url.lastPathComponent
                print(fileName)
                let components = fileName.components(separatedBy: ".")
                if components.count > 1 {
                    let nameWithoutExtension = components[0]
                    let fileExtension = components.last
                    let name = "\(formatter.string(from: Date()))'\(nameWithoutExtension).\(fileExtension ?? "doc")"
                    let fileUrl = folderUrl.appendingPathComponent(name)
                    try fileManager.moveItem(at: url, to: fileUrl)
                    updateDocumentsName()
                    nameArray.removeAll()
                    for documentName in documentsName {
                        nameArray.append(splitName(name: documentName)!)
                    }
                    tableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let fileManager = FileManager.default
    var fileUrlForQL: URL?
    var tempFile: URL?
    var documentsName: [String] = []
    var nameArray: [String] = []
    var albumUrl: URL?
    
    
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document", "com.microsoft.excel.xls", "org.openxmlformats.spreadsheetml.sheet", "com.microsoft.powerpoint.​ppt", "org.openxmlformats.presentationml.presentation",
        "com.adobe.pdf"], in: .import)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SubDocumentsTableViewCell", bundle: .main), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 80
        
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.systemFont(ofSize: 14)
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            let placeholderAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white, // Màu sắc mong muốn
                .font: UIFont.systemFont(ofSize: 14) // Font chữ mong muốn
            ]
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        }
        
        updateDocumentsName()
        for documentName in documentsName {
            nameArray.append(splitName(name: documentName)!)
        }
        print(nameArray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let documentsFileUrl = documentsUrl.appendingPathComponent("Documents")
        let tempFolder = documentsUrl.appendingPathComponent("temp")
        
        do {
            //let fileList = try fileManager.contentsOfDirectory(atPath: "\(documentsFileUrl.path)/\(self.title!)")
            
            let contents = try fileManager.contentsOfDirectory(atPath: tempFolder.path)
            //print(contents)
            //try fileManager.removeItem(at: tempFile ?? tempFolder)
            try fileManager.removeItem(at: tempFolder)
        } catch {
            print(error.localizedDescription)
        }
        updateDocumentsName()
        nameArray.removeAll()
        for documentName in documentsName {
            nameArray.append(splitName(name: documentName)!)
        }
        self.tableView.reloadData()
    }
    
    @objc func leftBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    func splitName(name: String) -> String? {
        let components = name.components(separatedBy: "'")
            if components.count > 1 {
                return components[1]
            }
            return nil
    }
    
    func updateDocumentsName() {
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let documentURL = documentsDirectory.appendingPathComponent("Documents")
        let folderURL = documentURL.appendingPathComponent(title!)
        albumUrl = folderURL
        do {
            self.documentsName = try fileManager.contentsOfDirectory(atPath: folderURL.path)
            self.documentsName.sort { (lhs: String, rhs: String) -> Bool in
                return lhs < rhs
            }
            // Lưu danh sách các tệp ảnh vào một mảng
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func fileSize(fromPath path: String) -> String? {
        guard let size = try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.size],
            let fileSize = size as? UInt64 else {
            return nil
        }

        // bytes
        if fileSize < 1023 {
            return String(format: "%lu bytes", CUnsignedLong(fileSize))
        }
        // KB
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }
        // MB
        floatSize = floatSize / 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }
        // GB
        floatSize = floatSize / 1024
        return String(format: "%.1f GB", floatSize)
    }

    static func makeSelf(name: String) -> SubDocumentsViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: SubDocumentsViewController = storyboard.instantiateViewController(withIdentifier: "SubDocumentsViewController") as! SubDocumentsViewController
        rootViewController.title = name
        
        return rootViewController
    }
}
