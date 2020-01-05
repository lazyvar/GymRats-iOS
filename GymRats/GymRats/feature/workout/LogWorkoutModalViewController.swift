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

    let tappedPhotoLibrary: () -> Void
    let tappedTakePicture: () -> Void

    init(tappedPhotoLibrary: @escaping () -> Void, tappedTakePicture: @escaping () -> Void) {
        self.tappedPhotoLibrary = tappedPhotoLibrary
        self.tappedTakePicture = tappedTakePicture
        
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
        
        return cell
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
