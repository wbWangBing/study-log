//
//  ProfileModel.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/12.
//
import Foundation

struct ProfileModel: Codable {
    var nickname: String
    var avatarPath: String
    var gender: String
    var birthday: Date
    var description: String
    var address: String
    var school: String

    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        return ageComponents.year ?? 0
    }

    // 带默认值的初始化方法
    init(
        nickname: String = "请登录",
        avatarPath: String = "avatar4",
        gender: String = "未知",
        birthday: Date = Date(timeIntervalSince1970: 946684800), // 2000-01-01
        desc: String = "这个人很神秘，什么都没写",
        address: String = "",
        school: String = ""
    ) {
        self.nickname = nickname
        self.avatarPath = avatarPath
        self.gender = gender
        self.birthday = birthday
        self.description = desc
        self.address = address
        self.school = school
    }
}

extension ProfileModel {
    static let userDefaultsKey = "profile_model"

    // 保存到UserDefaults
    func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: ProfileModel.userDefaultsKey)
        }
    }

    // 从UserDefaults加载
    static func loadFromUserDefaults() -> ProfileModel? {
        if let data = UserDefaults.standard.data(forKey: ProfileModel.userDefaultsKey),
           let profile = try? JSONDecoder().decode(ProfileModel.self, from: data) {
            return profile
        }
        return nil
    }
}


