//
//  PictureRankViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/24.
//

import UIKit
import SwiftyJSON

class PictureRankViewController: MainActionViewController {
    @IBOutlet weak var tblView: UITableView!
    var didScroll: ((_ direction:ScrollDirection, _ offsetY:CGFloat) -> Void)?
    var viewModel: PictureRankViewModel!
    
    static func initWithViewModel(_ viewModel: PictureRankViewModel) -> PictureRankViewController {
        let vc = PictureRankViewController.instantiateFromStoryboard(.picture)!
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        viewModel.dataRest()
    }
}

extension PictureRankViewController: PictureRankViewModelDelegate {
    func reloadData() {
        self.tblView.reloadData()
    }
    func showErrPopup(error: CError?) {
        self.showErrorToast(error)
    }
}

extension PictureRankViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PictureRankCell") as? PictureRankCell else {
            return UITableViewCell()
        }
        let model = viewModel.listData[indexPath.row]
        cell.configurationData(model, rank: indexPath.row+1)
        cell.didAction = {(action, model) ->Void in
            if action == 100 { // 앨범
                let viewModel = PictureAlbumViewModel(bpUserId: model.user_id, bpUserName: model.user_name)
                let vc = PictureAlbumViewController.initWithModel(viewModel)
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
            else if action == 200 {
                self.selUser = JSON(["user_id" : model.user_id])
                self.checkTalk()
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let model = viewModel.listData[indexPath.row]
//        let detailViewModel = PictureDetailViewModel(seq: model.seq, bpUserId: model.user_id)
//        let vc = PictureDetailViewController.initWithViewModel(detailViewModel)
//        appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
    }
}

extension PictureRankViewController: UIScrollViewDelegate {
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

