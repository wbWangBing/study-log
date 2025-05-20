//
//  ProjectDBHelper.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/13.
//


import SQLite

class ProjectDBHelper {
    static let shared = ProjectDBHelper(); // 单例模式访问接口
    
    private var db : Connection?;
    
    //MARK: -定义数据表
    // 表和列的定义
    private let projectsTable = Table("projects")
    private let idCol = Expression<String>("id")
    private let titleCol = Expression<String>("title")
    private let coverImagePathCol = Expression<String?>("coverImagePath")
    private let creationDateCol = Expression<Date>("creationDate")
    private let lastModifiedDateCol = Expression<Date>("lastModifiedDate")
    private let statusCol = Expression<String>("status") // 将存储 ItemStatus.rawValue
    private let projectFilePathCol = Expression<String?>("projectFilePath")
    private let durationCol = Expression<TimeInterval?>("duration")
    
    private init() {
        // 数据库文件路径
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        do {
            db = try Connection("\(path)/capcut_projects.sqlite3")
            try createProjectsTableIfNeeded()
        } catch {
            db = nil
            print("数据库连接失败: \(error)")
        }
    }
    
    // 创建项目表 (如果不存在)
    private func createProjectsTableIfNeeded() throws {
        guard let db = db else { return }
        try db.run(projectsTable.create(ifNotExists: true) { table in
            table.column(idCol, primaryKey: true)
            table.column(titleCol)
            table.column(coverImagePathCol)
            table.column(creationDateCol)
            table.column(lastModifiedDateCol)
            table.column(statusCol)
            table.column(projectFilePathCol)
            table.column(durationCol)
        })
        print("Projects table created or already exists.")
    }
    
    // MARK: - CRUD 操作

     // 创建项目
     func createProject(item: ProjectItem) throws -> Int64? {
         guard let db = db else { return nil }
         let insert = projectsTable.insert(
             idCol <- item.id,
             titleCol <- item.title,
             coverImagePathCol <- item.coverImagePath,
             creationDateCol <- item.creationDate,
             lastModifiedDateCol <- item.lastModifiedDate,
             statusCol <- item.status.rawValue,
             projectFilePathCol <- item.projectFilePath,
             durationCol <- item.duration
         )
         return try db.run(insert)
     }

     // 获取项目列表
     func fetchProjects(statusFilter: ItemStatus? = nil) throws -> [ProjectItem] {
         guard let db = db else { return [] }
         var query = projectsTable

         if let status = statusFilter {
             query = query.filter(statusCol == status.rawValue)
         }
         
         query = query.order(lastModifiedDateCol.desc) // 按最后修改日期降序排列

         var fetchedItems: [ProjectItem] = []
         for row in try db.prepare(query) {
             let item = ProjectItem(
                 id: row[idCol],
                 title: row[titleCol],
                 status: ItemStatus(rawValue: row[statusCol]) ?? .project, // 提供默认值以防转换失败
                 creationDate: row[creationDateCol],
                 lastModifiedDate: row[lastModifiedDateCol],
                 coverImagePath: row[coverImagePathCol],
                 projectFilePath: row[projectFilePathCol],
                 duration: row[durationCol]
             )
             fetchedItems.append(item)
         }
         return fetchedItems
     }
     
     // 根据ID获取单个项目
     func fetchProject(byId: String) throws -> ProjectItem? {
         guard let db = db else { return nil }
         let query = projectsTable.filter(idCol == byId).limit(1)

         if let row = try db.pluck(query) {
             return ProjectItem(
                 id: row[idCol],
                 title: row[titleCol],
                 status: ItemStatus(rawValue: row[statusCol]) ?? .project,
                 creationDate: row[creationDateCol],
                 lastModifiedDate: row[lastModifiedDateCol],
                 coverImagePath: row[coverImagePathCol],
                 projectFilePath: row[projectFilePathCol],
                 duration: row[durationCol]
             )
         }
         return nil
     }

     // 更新项目
     func updateProject(item: ProjectItem) throws -> Bool {
         guard let db = db else { return false }
         let projectToUpdate = projectsTable.filter(idCol == item.id)
         let update = projectToUpdate.update(
             titleCol <- item.title,
             coverImagePathCol <- item.coverImagePath,
             lastModifiedDateCol <- Date(), // 自动更新最后修改日期
             statusCol <- item.status.rawValue,
             projectFilePathCol <- item.projectFilePath,
             durationCol <- item.duration
         )
         return try db.run(update) > 0
     }

     // 删除项目
     func deleteProject(itemId: String) throws -> Bool {
         guard let db = db else { return false }
         let projectToDelete = projectsTable.filter(idCol == itemId)
         return try db.run(projectToDelete.delete()) > 0
     }
     
     // 删除所有项目 (主要用于测试或重置)
     func deleteAllProjects() throws {
         guard let db = db else { return }
         try db.run(projectsTable.delete())
     }
    
}
