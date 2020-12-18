//
//  GroupListView.swift
//  AgoraEducation
//
//  Created by SRS on 2020/11/19.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

import UIKit

class GroupListView: UITableView {
    
    fileprivate let GroupCellID = "GroupCell"
    fileprivate let NoGroupCellID = "studentCell"
    
    @objc var localUserUuid: String = ""
    @objc var groupState: GroupCommonState = GroupCommonState.on
    @objc var groups: Array<GroupStudentList>?
    @objc var noGroups: Array<NoGroupStudentList>?
    
    @objc weak var muteDelegate: RoomProtocol?

    @objc func setupTableView() {
        
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    
        separatorStyle = .none
        delegate = self
        dataSource = self
        estimatedRowHeight = 0
        estimatedSectionFooterHeight = 0
        estimatedSectionHeaderHeight = 0
        tableFooterView = UIView()
        clipsToBounds = true
        register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: GroupCellID)
        register(UINib(nibName: "MCStudentViewCell", bundle: nil), forCellReuseIdentifier: NoGroupCellID)
    }
}

//MARK:Delegate DataSource
extension GroupListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (groupState == GroupCommonState.on) {
            return groups?.count ?? 0
        } else {
            return noGroups?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (groupState == GroupCommonState.on) {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupCellID, for: indexPath) as! GroupCell
    
            cell.selectionStyle = .none
    
            let array = groups ?? []
            if (array.count > indexPath.row) {
                cell.updateView(model: array[indexPath.row])
            } else {
                cell.updateView(model: nil)
            }
    
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoGroupCellID, for: indexPath) as! MCStudentViewCell
            cell.selectionStyle = .none
            cell.contentView.alpha = 1
            cell.delegate = self
            
            let array = noGroups ?? []
            if (array.count > indexPath.row) {
                let studentInfo = array[indexPath.row]
                cell.muteWhiteButton?.isHidden = true
                cell.userUuid = localUserUuid
                
                var streamInfo = studentInfo.stream
                
                // If there is no stream, create a stream information for display
                if streamInfo == nil {
                    streamInfo = MCStreamInfo(userUuid: studentInfo.userUuid, userName: studentInfo.userName, hasAudio: false, hasVideo: false, streamState: 0, userState: studentInfo.state)
                }
                cell.stream = streamInfo!

            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (groupState == GroupCommonState.on) {
            return 138
        } else {
            return 40
        }
    }
}

extension GroupListView: RoomProtocol {
    func muteVideoStream(_ mute: Bool) {
        self.muteDelegate?.muteVideoStream?(mute)
    }
    
    func muteAudioStream(_ mute: Bool) {
        self.muteDelegate?.muteAudioStream?(mute)
    }
}
