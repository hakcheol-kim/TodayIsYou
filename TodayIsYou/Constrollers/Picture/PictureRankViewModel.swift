//
//  PictureRankViewModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/27.
//

import Foundation
protocol PictureRankViewModelDelegate: AnyObject {
    func reloadData()
    func showErrPopup(error: CError?)
}

class PictureRankViewModel {
    weak var delegate: PictureRankViewModelDelegate?
    
    var data: PictureRankResModel!
    var listData = [PictureRank]()
    var canRequest: Bool = true
    
    private var currentPage: Int = 1
    private let pageCnt = 30
    private var pageEnd: Bool = false
    
    func dataRest() {
        currentPage = 1
        pageEnd = false
        self.fetchRankList()
    }
    func addData() {
        self.fetchRankList()
    }
    
    private func fetchRankList() {
        if pageEnd { return }
        ApiClient.ins.request(.fetchRankList(user_id: ShareData.ins.myId), PictureRankResModel.self, success: { result in
            if result.code == "000" {
                if result.r_list.count > 0 {
                    if self.currentPage == 1 {
                        self.listData = result.r_list
                    }
                    else {
                        self.listData.append(contentsOf: result.r_list)
                    }
                    self.delegate?.reloadData()
                }
                else {
                    //001 화제정보 없음
                    self.pageEnd = true
                }
                self.currentPage += 1
            }
            else {
                
            }
        }, failure: { error in
            self.delegate?.showErrPopup(error: error)
        })
        
    }
}
