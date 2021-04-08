//
//  ChattingViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/07.
//

import UIKit
import SwiftyJSON
class ChattingViewController: MainActionViewController {
    @IBOutlet var haderView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var keyboardAccoryView: UIView!
    @IBOutlet weak var tvChatting: CTextView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnAlbum: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnJim: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    
    @IBOutlet weak var heightKeyboard: NSLayoutConstraint!
    
    var passData:JSON!
    var listData:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "", #selector(actionNaviBack))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func onClickedBtnActions(_ sender: UIButton) {
    }
    
}

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChattingCell.identifier) as? ChattingCell else {
            return UITableViewCell()
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
