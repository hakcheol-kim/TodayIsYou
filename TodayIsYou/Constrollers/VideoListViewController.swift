//
//  VideoListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit

class VideoListViewController: BaseViewController {
    var sortType: SortedType = .mail
    var listType: ListType = .collection
    
    @IBOutlet weak var centerSelMarkView: NSLayoutConstraint!
    @IBOutlet weak var btnListType: CButton!
    @IBOutlet weak var btnFemail: CButton!
    @IBOutlet weak var btnMail: CButton!
    @IBOutlet weak var btnTotal: CButton!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "VideoColCell", bundle: nil), forCellWithReuseIdentifier: "VideoColCell")
        }
    }
    
    var listData:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        decorationUI()
        toggleListType()
        selectedSortedBtn()
    }
    
    func decorationUI() {
        let imgNor = UIImage.image(from: RGB(120, 120, 130))
        let imgSel = UIImage.image(from: RGB(230, 100, 100))
        
        btnTotal.setBackgroundImage(imgNor, for: .normal)
        btnTotal.setBackgroundImage(imgSel, for: .selected)
        btnTotal.setTitle(SortedType.total.displayName(), for: .normal)
        
        btnFemail.setBackgroundImage(imgNor, for: .normal)
        btnFemail.setBackgroundImage(imgSel, for: .selected)
        btnFemail.setTitle(SortedType.femail.displayName(), for: .normal)
        
        btnMail.setBackgroundImage(imgNor, for: .normal)
        btnMail.setBackgroundImage(imgSel, for: .selected)
        btnMail.setTitle(SortedType.mail.displayName(), for: .normal)
    }
    
    func selectedSortedBtn() {
        if (sortType == .femail) {
            btnTotal.isSelected = false
            btnFemail.isSelected = true
            btnMail.isSelected = false
        }
        else if(sortType == .mail ) {
            btnTotal.isSelected = false
            btnFemail.isSelected = false
            btnMail.isSelected = true
        }
        else {
            btnTotal.isSelected = true
            btnFemail.isSelected = false
            btnMail.isSelected = false
        }
    }
    func toggleListType() {
        if listType == .collection {
            btnListType.isSelected = true
            centerSelMarkView.constant = 15
            
            collectionView.isHidden = false
            tblView.isHidden = true
            collectionView.delegate = self
            collectionView.dataSource = self
            tblView.delegate = nil;
            tblView.dataSource = nil;
        }
        else {
            btnListType.isSelected = false
            centerSelMarkView.constant = -15
            
            collectionView.isHidden = true
            tblView.isHidden = false
            collectionView.delegate = nil
            collectionView.dataSource = nil
            tblView.delegate = self;
            tblView.dataSource = self;
        }
        self.dataRest()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if (sender == btnListType) {
            btnListType.isSelected = !sender.isSelected
            if (btnListType.isSelected) {
                self.listType = .collection
            }
            else {
                self.listType = .table
            }
            toggleListType()
        }
        else if (sender == btnTotal) {
            sortType = .total
            self.selectedSortedBtn()
        }
        else if (sender == btnFemail) {
            sortType = .femail
            self.selectedSortedBtn()
        }
        else if (sender == btnMail) {
            sortType = .mail
            self.selectedSortedBtn()
        }
    }
    
    func dataRest() {
        
    }
    func addData() {
        
    }
    func requestData() {
        
    }
}
extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20// listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VideoTblCell") as? VideoTblCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("VideoTblCell", owner: nil, options: nil)?.first as? VideoTblCell
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension VideoListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20//listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoColCell", for: indexPath) as! VideoColCell
        
        return cell
    }
}
