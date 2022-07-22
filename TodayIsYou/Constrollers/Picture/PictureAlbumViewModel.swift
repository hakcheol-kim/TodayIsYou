//
//  PictureAlbumViewModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/28.
//

import Foundation
protocol PictureAlbemViewModelDelegate: AnyObject {
    func reloadData()
    func showErrPopup(error: CError?)
}

class PictureAlbumViewModel {
    weak var delegate: PictureAlbemViewModelDelegate?
    let bpUserId: String!
    let bpUserName: String!
    
    var data: PictureAlbumResModel!
    var listData = [PictureAlbumModel]()
    var canRequest: Bool = true
    
    private var currentPage: Int = 1
    private let pageCnt = 30
    private var pageEnd: Bool = false
    var isMe: Bool = false
    
    init(bpUserId: String, bpUserName: String) {
        self.bpUserId = bpUserId
        self.bpUserName = bpUserName
        self.isMe = (ShareData.ins.myId == bpUserId)
    }
    
    func dataRest() {
        currentPage = 1
        pageEnd = false
        self.fetchPictureShowList()
    }
    func addData() {
        self.fetchPictureShowList()
    }
    
    private func fetchPictureShowList() {
        if pageEnd { return }
        var param = [String:Any]()
        if isMe {
            param["user_id"] = ShareData.ins.myId
            param["current_page"] = currentPage
            param["page_cnt"] = pageCnt
            
            ApiClient.ins.request(.fetchMyPictureList(param), PictureAlbumResModel.self) { result in
                if result.code == "000" {
                    self.data = result
                    if result.bb_list.count > 0 {
                        if self.currentPage == 1 {
                            self.listData = result.bb_list
                        }
                        else {
                            self.listData.append(contentsOf: result.bb_list)
                        }
                    }
                    else {
                        //001 화제정보 없음
                        self.pageEnd = true
                    }
                    self.currentPage += 1
                    self.delegate?.reloadData()
                }
                else {
                    self.pageEnd = true
    //                self.delegate?.showErrPopup(CError.customError(message: result.msg))
                }
                
            } failure: { error in
                self.delegate?.showErrPopup(error: error)
            }
        }
        else {
            param["user_id"] = ShareData.ins.myId
            param["bp_user_id"] = self.bpUserId
            param["current_page"] = currentPage
            param["page_cnt"] = pageCnt
            
            ApiClient.ins.request(.fetchPictureAlbumList(param: param), PictureAlbumResModel.self) { result in
                if result.code == "000" {
                    self.data = result
                    if result.bb_list.count > 0 {
                        if self.currentPage == 1 {
                            self.listData = result.bb_list
                        }
                        else {
                            self.listData.append(contentsOf: result.bb_list)
                        }
                    }
                    else {
                        //001 화제정보 없음
                        self.pageEnd = true
                    }
                    self.currentPage += 1
                    self.delegate?.reloadData()
                }
                else {
                    self.pageEnd = true
    //                self.delegate?.showErrPopup(CError.customError(message: result.msg))
                }
                
            } failure: { error in
                self.delegate?.showErrPopup(error: error)
            }
        }
    }
}
