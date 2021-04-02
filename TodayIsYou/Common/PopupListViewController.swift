//
//  PopupListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/25.
//

import UIKit
import PanModal

enum PopupType {
    case normal
}

class PopupListCell: UITableViewCell {
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class PopupListViewController: BaseViewController {
    
    @IBOutlet weak var svTitle: UIStackView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    
    var listData:[Any] = []
    var keys:[String]? = nil
    var type:PopupType = .normal
    var vcTitle: String?
    var fitHeight:CGFloat = 100
    
    var completion:((_ vcs: UIViewController, _ selItem:Any?, _ index:NSInteger) -> Void)?
    
    static func initWithType(_ type: PopupType, _ title:String?, _ data:[Any], _ keys:[String]?, completion:((_ vcs: UIViewController, _ selItem:Any?, _ index:NSInteger) -> Void)?) -> PopupListViewController {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupListViewController") as! PopupListViewController
        
        vc.completion = completion
        vc.listData = data
        vc.type = type
        vc.vcTitle = title
        vc.keys = nil
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        svTitle.isHidden = true
        if let vcTitle = vcTitle {
            svTitle.isHidden = false
            lbTitle.text = vcTitle
        }
        btnClose.imageView?.contentMode = .scaleAspectFill
        self.btnClose.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
        

        self.view.layoutIfNeeded()
        self.tblView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: tblView.bounds.width, height: 64))
        
        self.tblView.reloadData {
            self.view.layoutIfNeeded()
            self.fitHeight = self.tblView.contentSize.height
            if self.svTitle.isHidden == false {
                self.fitHeight += self.svTitle.bounds.height
            }
            self.fitHeight += self.view.window?.safeAreaInsets.bottom ?? 0
            self.panModalSetNeedsLayoutUpdate()
            self.panModalTransition(to: .shortForm)
        }
    }
    
    @objc func onClickedBtnActions(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension PopupListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PopupListCell") as? PopupListCell else {
            return UITableViewCell()
        }
        if type == .normal {
            cell.ivIcon.isHidden = true
            cell.lbSubTitle.isHidden = true
            if let title = listData[indexPath.row] as? String {
                cell.lbTitle.text = title
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = listData[indexPath.row]
        self.completion?(self, item, indexPath.row)
    }
}
extension PopupListViewController: PanModalPresentable {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var panModalBackgroundColor: UIColor {
        return RGBA(0, 0, 0, 0.2)
    }
    var showDragIndicator: Bool {
        return false
    }
    var panScrollable: UIScrollView? {
        return self.tblView
    }
    var topOffset: CGFloat {
        guard let window = AppDelegate.ins.window else {
            return 100
        }
        return window.safeAreaInsets.top + 50
    }
    var shortFormHeight: PanModalHeight {
        return PanModalHeight.contentHeight(fitHeight)
    }
    var cornerRadius : CGFloat {
        return 16.0
    }
    var anchorModalToLongForm: Bool {
        return false
    }
}
