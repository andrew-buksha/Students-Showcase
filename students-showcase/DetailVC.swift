//
//  DetailVC.swift
//  students-showcase
//
//  Created by Андрей Букша on 25.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCellWithIdentifier("DetailCell") as! DetailCell
        } else if indexPath.row == 1 {
            return tableView.dequeueReusableCellWithIdentifier("CommentsCountCell") as! CommentsCountCell
        } else {
            return tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
        }
}
    
}
