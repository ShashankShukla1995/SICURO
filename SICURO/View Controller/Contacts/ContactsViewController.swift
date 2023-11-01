//
//  ContactsViewController.swift
//  SICURO
//
//  Created by Shashank Shukla on 27/10/23.
//

import UIKit
import FirebaseDatabase
import CoreMedia

class ContactsViewController: UIViewController {
    
    let contactsTableView :UITableView = {
        let table = UITableView()
        table.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactsTableViewCell")
        return table
    }()
    
    private let database = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        self.view.addSubview(contactsTableView)
        contactsTableView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-20)
        // Do any additional setup after loading the view.
    }
}


extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = contactsTableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as? ContactsTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel?.text = "First"
        cell.subTitleLabel.text = "First"
        return cell
    }
    
    
}
