//
//  PictureDetailViewModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/26.
//

import Foundation
protocol PictureDetailViewModelDelegate: AnyObject {
    func resDetail()
    func showError(_ error: CError?)
    func resPurchasedPicture()
    func resDeletePickture()
}

class PictureDetailViewModel {
    weak var delegate: PictureDetailViewModelDelegate?
    
    var bpUserId: String!
    var seq: String!
    var isMe: Bool = false
    var data: PictureDetail!
    var isModify: Bool = false
    init(seq:String, bpUserId:String) {
        self.seq = seq
        self.bpUserId = bpUserId
        self.isMe = (ShareData.ins.myId == bpUserId)
    }
    
    func requestPictureDetail() {
        ApiClient.ins.request(.pictureDetail(seq: self.seq, bpUserId: self.bpUserId), PictureDetailResModel.self) { result in
            if result.code == "000", let data = result.data {
                self.data = data
                self.delegate?.resDetail()
            }
            else {
                self.delegate?.showError(CError.customError(message: "empty datay"))
            }
        } failure: { error in
            self.delegate?.showError(error)
        }
    }
    
    func requestPurchargePicture() {
        let param: [String : String] = ["seq" : self.seq, "user_id" : ShareData.ins.myId]
        ApiClient.ins.request(.purchasePicture(param), CommonResModel.self) { result in
            if result.code == "000" {
                self.delegate?.resPurchasedPicture()
                self.isModify = true
            }
            else {
                self.delegate?.showError(CError.customError(message: result.msg))
            }
        } failure: { error in
            self.delegate?.showError(error)
        }
    }
    func requestDeletePicture() {
        ApiClient.ins.request(.deletePicture(userId: bpUserId, seq: seq), CommonResModel.self) { result in
            if result.code == "000" {
                self.delegate?.resDeletePickture()
                self.isModify = true
            }
            else {
                self.delegate?.showError(CError.customError(message: result.msg))
            }
        } failure: { error in
            self.delegate?.showError(error)
        }
    }
}
