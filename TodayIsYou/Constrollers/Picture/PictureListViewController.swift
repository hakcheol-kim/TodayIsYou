//
//  PictureListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/24.
//

import UIKit
import SideMenu

class PictureListViewController: BaseViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    var viewModel: PictureListViewModel!
    var didScroll: ((_ direction:ScrollDirection, _ offsetY:CGFloat) -> Void)?
    
    static func initWithViewModel(_ viewmodel:PictureListViewModel) -> PictureListViewController {
        let vc = PictureListViewController.instantiateFromStoryboard(.picture)!
        vc.viewModel = viewmodel
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        viewModel.checkSelfAuth()
        self.viewModel.delegate = self
        self.viewModel.dataRest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if self.viewModel.listData.isEmpty == false {
//            self.collectionView.reloadData()
//        }

    }
    private func initUI() {
        
        let layout = CFlowLayout.init()
        layout.numberOfColumns = 2
        layout.delegate = self
        layout.lineSpacing = 4
        layout.secInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 100)
        self.collectionView.collectionViewLayout = layout
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
    }
    
    private func gotoDetailVC() {
        guard let model = viewModel.selModel else {
            return
        }
        let detailViewModel = PictureDetailViewModel(seq: model.seq, bpUserId: model.user_id)
        let vc = PictureDetailViewController.initWithViewModel(detailViewModel)
        appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        vc.didModify = {() ->Void in
            self.viewModel.dataRest()
        }
    }
}

extension PictureListViewController: PictureListViewModelDelegate {
    func resCheckSelfAuth() {
        print("success")
    }
    
    func resUpdateSelfAuth() { //성인인증 끝나면
        self.gotoDetailVC()
    }
    
    func reloadData() {
        self.collectionView.reloadData {
            self.collectionView.reloadData()
        }
    }
    func showErrPopup(_ error: CError?) {
        guard let msg = error?.errorDescription else {
            return
        }
        self.showToast(msg)
    }
    func resServerCheckAdult(success: Bool) { //서버 성인체크 할지 여부
        if (success) {
            let audltView = AdultPopupView.init(type: 2)
            CAlertView.showCustomView(audltView, [audltView.btnExit2, audltView.btnOk]) { index in
                print("index : \(index)")
                if index == 0 {
                    //
                }
                else {
                    let vc = CertificationWebViewController.instantiateFromStoryboard(.other)!
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    vc.didFinish = {(result) ->(Void) in
                        if result {
                            self.viewModel.updateSelfAuth()
                        }
                        else {
//                            self.gotoDetailVC()
                        }
                    }
                }
            }
        }
        else {
            self.gotoDetailVC()
        }
    }
}

extension PictureListViewController: UICollectionViewDelegate, UICollectionViewDataSource, CFlowLayoutDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureListColCell", for: indexPath) as? PictureListColCell else {
            return UICollectionViewCell()
        }
        
        let model = viewModel.listData[indexPath.row]
//        print(model.pb_url)
        cell.configurationData(model: model)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        var model = viewModel.listData[indexpath.row]
        if model.height > 0 {
//            print("=== aleardy height")
            return model.height
        }
        else {
            let index = (indexpath.row % randomRowRates.count)
            let rate = randomRowRates[index]
            let heigith = 300 * rate
            model.height = heigith
            viewModel.listData[indexpath.row] = model
//            print("=== new height")
            return heigith
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selModel = viewModel.listData[indexPath.row]
//        #if DEBUG
//            viewModel.isCheckedAdult = false
//        #endif
        if viewModel.isCheckedAdult == false {
            viewModel.serverAdultCheck()
        }
        else {
            self.gotoDetailVC()
        }
    }
}

extension PictureListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        
        if velocityY < 0 && offsetY > contentH && viewModel.canRequest == true {
            viewModel.canRequest = false
            viewModel.addData()
        }
        
        if velocityY > 0 {
//            print("down")
            self.didScroll?(.down, scrollView.contentOffset.y)
        }
        else if velocityY < 0 {
//            print("up")
            self.didScroll?(.up, scrollView.contentOffset.y)
        }
    }
}

