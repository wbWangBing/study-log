//
//  ProfileViewModel.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/9.
//

import Foundation



class ProfileViewModel {
    private(set) var profile: ProfileModel
    
    func updateProfile(_ newProfile: ProfileModel) {
        self.profile = newProfile
    }
    
    init(profile: ProfileModel) {
        self.profile = profile
    }

    var nickname: String {
        profile.nickname
    }

    var avatarURL: String {
        profile.avatarPath
    }

    var description: String {
        profile.description
    }


}

