//
//  PictureListViewModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/25.
//

import Foundation
import SwiftyJSON
import SocketIO
import Contacts
protocol PictureListViewModelDelegate: AnyObject {
    func reloadData()
    func showErrPopup(_ error: CError?)
    func resServerCheckAdult(success: Bool)
    func resCheckSelfAuth()
    func resUpdateSelfAuth()
}

class PictureListViewModel {
    weak var delegate: PictureListViewModelDelegate?
    var listData = [PictureModel]()
    var canRequest: Bool = true
    private let category: Int! //1:신규, 2:인기
    private var currentPage: Int = 1
    private let pageCnt = 30
    private var pageEnd: Bool = false
    var isCheckedAdult: Bool = false
    var selModel: PictureModel!
    
    init(category: Int) {
        self.category = category
    }
    
    func dataRest() {
        currentPage = 1
        pageEnd = false
        requestData()
    }
    func addData() {
        requestData()
    }
    
    private func requestData() {
        if pageEnd { return }
        ApiClient.ins.request(.fetchPictorialList(category: category, current_page: currentPage, page_cnt: pageCnt), PictureResModel.self, success: { result in
            if result.code == "000" {
                if result.bb_list.count > 0 {
                    if self.currentPage == 1 {
                        self.listData = result.bb_list
                        self.isCheckedAdult = (result.sa_yn == "Y")
                    }
                    else {
                        self.listData.append(contentsOf: result.bb_list)
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
//                self.delegate?.showErrPopup(CError.customError(message: result.msg))
            }
        }, failure: { error in
            self.delegate?.showErrPopup(error)
        })
    }
    func checkSelfAuth() {
        ApiClient.ins.request(.checkSelfAuth(user_id: ShareData.ins.myId), CommonResModel.self) { result in
            if result.code == "000" {
                self.isCheckedAdult = true
                self.delegate?.resCheckSelfAuth()
            }
            else {
                self.delegate?.showErrPopup(CError.customError(message: result.msg))
            }
        } failure: { error in
            self.delegate?.showErrPopup(error)
        }
    }
    func updateSelfAuth() {
        ApiClient.ins.request(.updateSelfAuth(user_id: ShareData.ins.myId), CommonResModel.self) { result in
            if result.code == "000" || result.code == "003" {
                self.delegate?.resUpdateSelfAuth()
            }
            else {
                self.delegate?.showErrPopup(CError.customError(message: result.msg))
            }
        } failure: { error in
            self.delegate?.showErrPopup(error)
        }
    }
    
    func serverAdultCheck() {
        //통신
        ApiClient.ins.request(.adultCheck, CommonResModel.self) { result in
            if result.code == "000" {
                self.delegate?.resServerCheckAdult(success: true)
            }
            else {
                self.delegate?.resServerCheckAdult(success: false)
            }
        } failure: { error in
            self.delegate?.resServerCheckAdult(success: false)
        }
    }

}
