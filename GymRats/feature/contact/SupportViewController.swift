//
//  SupportViewController.swift
//  GymRats
//
//  Created by mack on 11/19/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class SupportViewController: UIViewController {
  private enum Constant {
    static let id = "SupoprtCellId"
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.delegate = self
      tableView.dataSource = self
      tableView.backgroundColor = .background
      tableView.tableHeaderView = UIView()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.largeTitleDisplayMode = .always
    view.backgroundColor = .background
    title = "Support"
  }
}

extension SupportViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DevLog.enabled ? 4 : 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.id) ?? UITableViewCell(style: .subtitle, reuseIdentifier: Constant.id)

    switch indexPath.row {
    case 0:
      cell.imageView?.image = .messenger
      cell.textLabel?.text = "Connect on Messenger"
      cell.detailTextLabel?.text = "Talk to a human now."
    case 1:
      cell.imageView?.image = .mailTemplate
      cell.textLabel?.text = "Send an email"
      cell.detailTextLabel?.text = "For issues that can wait."
    case 2:
      cell.imageView?.image = .help
      cell.textLabel?.text = "Read the FAQ"
      cell.detailTextLabel?.text = "See if your question has already been answered."
    case 3:
      cell.imageView?.image = .activity
      cell.textLabel?.text = "Share developer's log"
      cell.detailTextLabel?.text = "For health app auto sync issues."
    default:
      break
    }
    
    cell.imageView?.tintColor = .primaryText
    cell.backgroundColor = .foreground
    cell.textLabel?.font = .body
    cell.textLabel?.textColor = .primaryText
    cell.detailTextLabel?.textColor = .secondaryText
    cell.detailTextLabel?.font = .details
    cell.accessoryType = .disclosureIndicator
    
    return cell
  }
}

extension SupportViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch indexPath.row {
    case 0:
      UIApplication.shared.open(URL(string: "https://m.me/102576851674190")!, options: [:], completionHandler: nil)
    case 1:
      UIApplication.shared.open(URL(string: "mailto:support@gymrats.app")!, options: [:], completionHandler: nil)
    case 2:
      let webView = WebViewController(url: URL(string: "https://www.gymrats.app/faq")!)
      
      self.present(webView.inNav(), animated: true, completion: nil)
    case 3:
      DevLog.shareLog()
    default:
      break
    }
  }
}
