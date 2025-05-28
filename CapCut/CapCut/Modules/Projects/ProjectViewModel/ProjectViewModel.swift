//
//  ProjectViewModel.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/13.
//

import Foundation
import Combine
import UIKit

class ProjectViewModel: ObservableObject {
    
    let itemStatus : ItemStatus
    
    @Published var projectItems: [ProjectItem] = []
    @Published var errorMessage: String? = nil

    private var dbHelper = ProjectDBHelper.shared

    init(itemStatus : ItemStatus) {
        // 初始加载时可以获取所有项目和草稿，或者根据需要指定
        self.itemStatus = itemStatus
        loadProjects(statusFilter: itemStatus)
    }

    // MARK: - 获取数据
    func loadProjects(statusFilter: ItemStatus? = nil) {
        do {
            self.projectItems = try dbHelper.fetchProjects(statusFilter: statusFilter)
            self.errorMessage = nil
        } catch {
            self.projectItems = []
            self.errorMessage = "加载项目失败: \(error.localizedDescription)"
            print("Error fetching projects: \(error)")
        }
    }

    // MARK: - 增加数据
    func createProject(title: String, status: ItemStatus, coverImagePath: String? = nil, projectFilePath: String? = nil, duration: TimeInterval? = nil) {
        let newItem = ProjectItem(
            title: title,
            status: status,
            coverImagePath: coverImagePath,
            projectFilePath: projectFilePath,
            duration: duration
        )
        do {
            _ = try dbHelper.createProject(item: newItem)
            // 创建成功后重新加载列表，或者直接将 newItem 添加到 projectItems 数组
            projectItems.insert(newItem, at: 0)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "创建项目失败: \(error.localizedDescription)"
            print("Error creating project: \(error)")
        }
    }
    
    //MARK: -更新
    func updateProject(_ item: ProjectItem) {
        do {
            let success = try dbHelper.updateProject(item: item)
            if success {
                // 更新成功后重新加载列表，或者找到并更新数组中的对应项
                if let index = projectItems.firstIndex(where: { $0.id == item.id }) {
                    let project = projectItems.remove(at: index)
                    projectItems.insert(project, at: 0)
                }

                self.errorMessage = nil
            } else {
                self.errorMessage = "更新项目失败: 未找到项目或无变更。"
                print("Error updating project: No rows updated or item not found.")
            }
        } catch {
            self.errorMessage = "更新项目失败: \(error.localizedDescription)"
            print("Error updating project: \(error)")
        }
    }
    
    //MARK: -删除
    func deleteProject(item: ProjectItem) {
        deleteProject(itemId: item.id)
    }

    func deleteProject(itemId: String) {
        do {
            let success = try dbHelper.deleteProject(itemId: itemId)
            if success {
                // 删除成功后重新加载列表，或者从数组中移除对应项
                self.projectItems.removeAll { $0.id == itemId }
                self.errorMessage = nil
            } else {
                self.errorMessage = "删除项目失败: 未找到项目。"
                print("Error deleting project: Item not found or no rows deleted.")
            }
        } catch {
            self.errorMessage = "删除项目失败: \(error.localizedDescription)"
            print("Error deleting project: \(error)")
        }
    }
    

    // 用于测试或演示，添加一些示例数据
//    func addSampleProjects() {
//        
//         //清空现有数据以避免重复添加
//         do {
//             try dbHelper.deleteAllProjects()
//         } catch {
//             print("Error deleting all projects for sample data: \(error)")
//         }
//
//        let project1 = ProjectItem(title: "我的第一个大片", status: .project, duration: 120.5)
//        let draft1 = ProjectItem(title: "旅行Vlog草稿", status: .draft)
//        let project2 = ProjectItem(title: "生日聚会回顾", status: .project, projectFilePath: "/path/to/project2_data", duration: 300)
//
//        let samples = [project1, draft1, project2]
//        var createdCount = 0
//        for sample in samples {
//            do {
//                // 检查是否已存在相同标题的项目，避免重复添加 (简单示例)
//                let existing = try dbHelper.fetchProjects().first(where: { $0.title == sample.title && $0.status == sample.status })
//                if existing == nil {
//                    _ = try dbHelper.createProject(item: sample)
//                    createdCount += 1
//                }
//            } catch {
//                print("Error adding sample project \(sample.title): \(error)")
//            }
//        }
//        if createdCount > 0 {
//            print("\(createdCount) sample items added.")
//        }
//        loadProjects() // 重新加载数据
//    }
}
