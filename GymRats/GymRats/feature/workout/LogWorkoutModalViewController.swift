//
//  LogWorkoutModalViewController.swift
//  GymRats
//
//  Created by mack on 1/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import PanModal

class LogWorkoutModalViewController: UITableViewController {

    let onPickImage: (UIImage) -> Void
    
    init(onPickImage: @escaping (UIImage) -> Void) {
        self.onPickImage = onPickImage
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "LogWorkoutCell", bundle: nil), forCellReuseIdentifier: "log")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "log") as! LogWorkoutCell
        
        cell.onTakePicture = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                UINavigationBar.appearance().isTranslucent = false
                UINavigationBar.appearance().barTintColor = .background
                UINavigationBar.appearance().tintColor = .primaryText
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }

        cell.onChooseFromLibrary = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                UINavigationBar.appearance().isTranslucent = false
                UINavigationBar.appearance().barTintColor = .background
                UINavigationBar.appearance().tintColor = .primaryText

                self.present(imagePicker, animated: true, completion: nil)
            }
        }

        return cell
    }

}

extension LogWorkoutModalViewController: UINavigationControllerDelegate {

}

extension LogWorkoutModalViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            self.dismiss(animated: true) {
                if let img = info[.originalImage] as? UIImage {
                    self.onPickImage(img)
                }
            }
        }
    }
    
}

extension LogWorkoutModalViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    
}
