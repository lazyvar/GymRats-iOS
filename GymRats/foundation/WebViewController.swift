//
//  WebViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 3/3/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
  private let url: URL
    
  init(url: URL) {
    self.url = url
    
    super.init(nibName: nil, bundle: nil)
  }
    
  convenience init(string: String) {
    self.init(url: URL(string: string)!)
  }
    
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let webView = WKWebView()
    
    view.addSubview(webView)
    
    view.addConstraintsWithFormat(format: "H:|[v0]|", views: webView)
    view.addConstraintsWithFormat(format: "V:|[v0]|", views: webView)

    webView.load(URLRequest(url: url))
    
    navigationItem.leftBarButtonItem = UIBarButtonItem (
      barButtonSystemItem: .done,
      target: self,
      action: #selector(dismissSelf)
    )
  }
}
