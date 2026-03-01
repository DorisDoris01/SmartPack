//
//  PresetData.swift
//  SmartPack
//
//  预设数据：标签组、标签、物品（SPEC: Input-Output Mapping）
//  - 标签组：旅行活动、特定场合、出行配置
//  - 基础清单：共有项 + 性别特有项
//

import Foundation
import Combine

/// 预设数据管理
class PresetData {
    static let shared = PresetData()
    
    private init() {}
    
    // MARK: - 物品数据库
    
    lazy var allItems: [String: Item] = {
        var items: [String: Item] = [:]
        for item in itemList {
            items[item.id] = item
        }
        return items
    }()
    
    private let itemList: [Item] = [
        // ========== SPEC 3.1: 共有基础项 ==========
        // 证件
        Item(id: "base_doc_001", name: "身份证", nameEn: "ID Card", category: .documents, genderSpecific: nil),
        // 电子
        Item(id: "base_ele_001", name: "数据线", nameEn: "Data&Charing Cable", category: .electronics, genderSpecific: nil),
        Item(id: "base_ele_002", name: "充电宝", nameEn: "Power Bank", category: .electronics, genderSpecific: nil),
        Item(id: "base_ele_003", name: "耳机", nameEn: "Headphone", category: .electronics, genderSpecific: nil),
        // 卫生
        Item(id: "base_hyg_001", name: "纸巾", nameEn: "Tissues", category: .toiletries, genderSpecific: nil),
        Item(id: "base_hyg_002", name: "墨镜", nameEn: "Sunglasses", category: .other, genderSpecific: nil),
        Item(id: "base_hyg_003", name: "洗面奶", nameEn: "Facial Cleanser", category: .toiletries, genderSpecific: nil),
        Item(id: "base_hyg_004", name: "牙刷/牙膏", nameEn: "Toothbrush/Toothpaste", category: .toiletries, genderSpecific: nil),
        Item(id: "base_hyg_005", name: "防晒霜", nameEn: "Sunscreen", category: .toiletries, genderSpecific: nil),
        Item(id: "base_hyg_006", name: "面霜", nameEn: "Face Cream", category: .toiletries, genderSpecific: nil),
        Item(id: "base_hyg_007", name: "唇膏", nameEn: "Lip Balm", category: .toiletries, genderSpecific: nil),
        // 衣物
        Item(id: "base_clo_001", name: "内裤", nameEn: "Underwear", category: .clothing, genderSpecific: nil),
        Item(id: "base_clo_002", name: "袜子", nameEn: "Socks", category: .clothing, genderSpecific: nil),
        Item(id: "base_clo_003", name: "睡衣", nameEn: "Pajamas", category: .clothing, genderSpecific: nil),
        Item(id: "base_clo_004", name: "上衣", nameEn: "Top", category: .clothing, genderSpecific: nil),
        Item(id: "base_clo_005", name: "裤子", nameEn: "Pants", category: .clothing, genderSpecific: nil),
        
        // ========== SPEC 3.1: 男性特有项 ==========
        Item(id: "male_001", name: "剃须刀", nameEn: "Razor", category: .toiletries, genderSpecific: .male),
        Item(id: "male_002", name: "发胶", nameEn: "Hair Gel", category: .toiletries, genderSpecific: .male),
        
        // ========== SPEC 3.1: 女性特有项 ==========
        Item(id: "female_001", name: "卸妆油", nameEn: "Makeup Remover", category: .toiletries, genderSpecific: .female),
        Item(id: "female_002", name: "护发素", nameEn: "Hair Conditioner", category: .toiletries, genderSpecific: .female),
        Item(id: "female_003", name: "化妆品", nameEn: "Makeup", category: .toiletries, genderSpecific: .female),
        Item(id: "female_004", name: "面膜", nameEn: "Face Mask", category: .toiletries, genderSpecific: .female),
        Item(id: "female_005", name: "护肤品", nameEn: "Skincare Kit", category: .toiletries, genderSpecific: .female),
        Item(id: "female_006", name: "发圈", nameEn: "Hair Tie", category: .toiletries, genderSpecific: .female),
        Item(id: "female_007", name: "卫生巾/棉条", nameEn: "Sanitary Pads/Tampons", category: .toiletries, genderSpecific: .female),
        Item(id: "female_008", name: "内衣", nameEn: "Bra", category: .clothing, genderSpecific: .female),
        Item(id: "female_009", name: "裙子", nameEn: "Dress", category: .clothing, genderSpecific: .female),
        Item(id: "female_010", name: "配饰", nameEn: "Accessories", category: .clothing, genderSpecific: .female),
        
        // ========== SPEC 4.2: 旅行活动 - 跑步 ==========
        Item(id: "act_run_001", name: "跑鞋", nameEn: "Running Shoes", category: .sports, genderSpecific: nil),
        Item(id: "act_run_002", name: "速干衣裤", nameEn: "Moisture-Wicking Clothes", category: .sports, genderSpecific: nil),
        Item(id: "act_run_003", name: "运动袜", nameEn: "Sports Socks", category: .sports, genderSpecific: nil),
        Item(id: "act_run_004", name: "导汗带", nameEn: "Sweatband", category: .sports, genderSpecific: nil),
        Item(id: "act_run_005", name: "运动补给（能量胶）", nameEn: "Energy Gels", category: .sports, genderSpecific: nil),
        Item(id: "act_run_006", name: "运动手表", nameEn: "Sports Watch", category: .electronics, genderSpecific: nil),
        
        // ========== SPEC 4.2: 旅行活动 - 攀岩 ==========
        Item(id: "act_climb_001", name: "攀岩鞋", nameEn: "Climbing Shoes", category: .sports, genderSpecific: nil),
        Item(id: "act_climb_002", name: "镁粉", nameEn: "Chalk", category: .sports, genderSpecific: nil),
        Item(id: "act_climb_003", name: "安全带", nameEn: "Harness", category: .sports, genderSpecific: nil),
        Item(id: "act_climb_004", name: "头盔", nameEn: "Helmet", category: .sports, genderSpecific: nil),
        Item(id: "act_climb_005", name: "主锁", nameEn: "Carabiner", category: .sports, genderSpecific: nil),
        Item(id: "act_climb_006", name: "快挂", nameEn: "Quickdraw", category: .sports, genderSpecific: nil),
        
        // ========== SPEC 4.2: 旅行活动 - 潜水 ==========
        Item(id: "act_dive_001", name: "面镜", nameEn: "Diving Mask", category: .sports, genderSpecific: nil),
        Item(id: "act_dive_002", name: "呼吸管", nameEn: "Snorkel", category: .sports, genderSpecific: nil),
        Item(id: "act_dive_003", name: "潜水电脑表", nameEn: "Dive Computer", category: .sports, genderSpecific: nil),
        Item(id: "act_dive_004", name: "水母衣", nameEn: "Rash Guard", category: .sports, genderSpecific: nil),
        Item(id: "act_dive_005", name: "防水袋", nameEn: "Waterproof Bag", category: .sports, genderSpecific: nil),
        
        // ========== SPEC 4.2: 旅行活动 - 露营 ==========
        Item(id: "act_camp_001", name: "帐篷", nameEn: "Tent", category: .sports, genderSpecific: nil),
        Item(id: "act_camp_002", name: "睡袋", nameEn: "Sleeping Bag", category: .sports, genderSpecific: nil),
        Item(id: "act_camp_003", name: "防潮垫", nameEn: "Sleeping Pad", category: .sports, genderSpecific: nil),
        Item(id: "act_camp_004", name: "睡垫", nameEn: "Sleeping Mat", category: .sports, genderSpecific: nil),
        Item(id: "act_camp_005", name: "头灯", nameEn: "Headlamp", category: .sports, genderSpecific: nil),
        Item(id: "act_camp_006", name: "营地灯", nameEn: "Camp Light", category: .sports, genderSpecific: nil),
        Item(id: "act_camp_007", name: "驱蚊水", nameEn: "Mosquito Repellent", category: .sports, genderSpecific: nil),
        Item(id: "act_camp_008", name: "急救毯", nameEn: "Emergency Blanket", category: .sports, genderSpecific: nil),
        
        // ========== SPEC 4.2: 旅行活动 - 越野 ==========
        Item(id: "act_trail_001", name: "越野跑鞋", nameEn: "Trail Running Shoes", category: .sports, genderSpecific: nil),
        Item(id: "act_trail_002", name: "越野跑背包", nameEn: "Trail Running Pack", category: .sports, genderSpecific: nil),
        Item(id: "act_trail_003", name: "软水壶", nameEn: "Soft Water Bottle", category: .sports, genderSpecific: nil),
        Item(id: "act_trail_004", name: "救生哨", nameEn: "Whistle", category: .sports, genderSpecific: nil),
        Item(id: "act_trail_005", name: "急救毯", nameEn: "Emergency Blanket", category: .sports, genderSpecific: nil),
        Item(id: "act_trail_006", name: "凡士林", nameEn: "Vaseline", category: .sports, genderSpecific: nil),
        Item(id: "act_trail_007", name: "强光头灯", nameEn: "Bright Headlamp", category: .sports, genderSpecific: nil),
        Item(id: "act_trail_008", name: "运动补给（能量胶）", nameEn: "Energy Gels", category: .sports, genderSpecific: nil),
        Item(id: "act_trail_009", name: "运动手表", nameEn: "Sports Watch", category: .electronics, genderSpecific: nil),
        Item(id: "act_trail_010", name: "GPX", nameEn: "GPX", category: .electronics, genderSpecific: nil),
        
        // ========== SPEC 4.2: 旅行活动 - 摄影 ==========
        Item(id: "act_photo_001", name: "相机机身", nameEn: "Camera Body", category: .electronics, genderSpecific: nil),
        Item(id: "act_photo_002", name: "镜头群", nameEn: "Lenses", category: .electronics, genderSpecific: nil),
        Item(id: "act_photo_003", name: "备用电池", nameEn: "Spare Batteries", category: .electronics, genderSpecific: nil),
        Item(id: "act_photo_004", name: "存储卡", nameEn: "Memory Cards", category: .electronics, genderSpecific: nil),
        Item(id: "act_photo_005", name: "三脚架", nameEn: "Tripod", category: .electronics, genderSpecific: nil),
        Item(id: "act_photo_006", name: "清洁套装", nameEn: "Cleaning Kit", category: .electronics, genderSpecific: nil),
        Item(id: "act_photo_007", name: "排插", nameEn: "Power Strip", category: .electronics, genderSpecific: nil),
        Item(id: "act_photo_008", name: "无人机", nameEn: "Drone", category: .electronics, genderSpecific: nil),
        
        // ========== SPEC 4.2: 旅行活动 - 摩旅 ==========
        Item(id: "act_moto_001", name: "头盔", nameEn: "Helmet", category: .sports, genderSpecific: nil),
        Item(id: "act_moto_002", name: "骑行服/护具", nameEn: "Riding Gear/Armor", category: .sports, genderSpecific: nil),
        Item(id: "act_moto_003", name: "雨衣", nameEn: "Rain Gear", category: .sports, genderSpecific: nil),
        Item(id: "act_moto_004", name: "维修工具", nameEn: "Repair Tools", category: .sports, genderSpecific: nil),
        Item(id: "act_moto_005", name: "蓝牙耳机（对讲）", nameEn: "Bluetooth Headset (Intercom)", category: .electronics, genderSpecific: nil),
        
        // ========== SPEC 4.2: 旅行活动 - 滑雪 ==========
        Item(id: "act_ski_001", name: "雪服", nameEn: "Ski Suit", category: .sports, genderSpecific: nil),
        Item(id: "act_ski_002", name: "雪镜", nameEn: "Ski Goggles", category: .sports, genderSpecific: nil),
        Item(id: "act_ski_003", name: "护脸", nameEn: "Face Mask", category: .sports, genderSpecific: nil),
        Item(id: "act_ski_004", name: "速干内衣", nameEn: "Moisture-Wicking Underwear", category: .clothing, genderSpecific: nil),
        Item(id: "act_ski_005", name: "护具", nameEn: "Protective Gear", category: .sports, genderSpecific: nil),
        Item(id: "act_ski_006", name: "暖宝宝", nameEn: "Hand Warmers", category: .other, genderSpecific: nil),
        Item(id: "act_ski_007", name: "滑雪袜", nameEn: "Ski Socks", category: .clothing, genderSpecific: nil),
        
        // ========== SPEC 4.2: 旅行活动 - 海滩 ==========
        Item(id: "act_beach_001", name: "泳衣", nameEn: "Swimsuit", category: .clothing, genderSpecific: nil),
        Item(id: "act_beach_002", name: "沙滩鞋", nameEn: "Beach Sandals", category: .clothing, genderSpecific: nil),
        Item(id: "act_beach_003", name: "防水手机袋", nameEn: "Waterproof Phone Pouch", category: .electronics, genderSpecific: nil),
        Item(id: "act_beach_004", name: "沙滩浴巾", nameEn: "Beach Towel", category: .other, genderSpecific: nil),
        Item(id: "act_beach_005", name: "晒后修复", nameEn: "After-Sun Care", category: .toiletries, genderSpecific: nil),
        
        // ========== SPEC 4.3: 特定场合 - 宴会 ==========
        Item(id: "occ_party_001", name: "礼服/西装", nameEn: "Formal Dress/Suit", category: .clothing, genderSpecific: nil),
        Item(id: "occ_party_002", name: "皮鞋/高跟鞋", nameEn: "Leather Shoes/High Heels", category: .clothing, genderSpecific: nil),
        Item(id: "occ_party_003", name: "配饰", nameEn: "Accessories", category: .clothing, genderSpecific: nil),
        Item(id: "occ_party_004", name: "发胶", nameEn: "Hair Gel", category: .toiletries, genderSpecific: nil),
        
        // ========== SPEC 4.3: 特定场合 - 商务会议 ==========
        Item(id: "occ_biz_001", name: "正装", nameEn: "Business Attire", category: .clothing, genderSpecific: nil),
        Item(id: "occ_biz_002", name: "皮鞋/高跟鞋", nameEn: "Leather Shoes/High Heels", category: .clothing, genderSpecific: nil),
        Item(id: "occ_biz_003", name: "配饰", nameEn: "Accessories", category: .clothing, genderSpecific: nil),
        Item(id: "occ_biz_004", name: "发胶", nameEn: "Hair Gel", category: .toiletries, genderSpecific: nil),
        Item(id: "occ_biz_005", name: "笔记本电脑", nameEn: "Laptop", category: .electronics, genderSpecific: nil),
        Item(id: "occ_biz_006", name: "演示翻页笔", nameEn: "Presentation Remote", category: .electronics, genderSpecific: nil),
        Item(id: "occ_biz_007", name: "名片", nameEn: "Business Cards", category: .other, genderSpecific: nil),
        Item(id: "occ_biz_008", name: "文件夹/笔", nameEn: "Folder/Pen", category: .other, genderSpecific: nil),
        
        // ========== SPEC 4.3: 特定场合 - 自驾 ==========
        Item(id: "occ_drive_001", name: "驾驶证", nameEn: "Driver's License", category: .documents, genderSpecific: nil),
        Item(id: "occ_drive_002", name: "车载充电线", nameEn: "Car Charging Cable", category: .electronics, genderSpecific: nil),
        Item(id: "occ_drive_003", name: "手机支架", nameEn: "Phone Mount", category: .electronics, genderSpecific: nil),
        Item(id: "occ_drive_004", name: "应急补胎液", nameEn: "Tire Sealant", category: .other, genderSpecific: nil),
        Item(id: "occ_drive_005", name: "墨镜", nameEn: "Sunglasses", category: .other, genderSpecific: nil),
        
        // ========== SPEC 4.4: 出行配置 - 国际旅行 ==========
        Item(id: "cfg_intl_001", name: "护照", nameEn: "Passport", category: .documents, genderSpecific: nil),
        Item(id: "cfg_intl_002", name: "签证", nameEn: "Visa", category: .documents, genderSpecific: nil),
        Item(id: "cfg_intl_003", name: "转换插头", nameEn: "Adapter", category: .electronics, genderSpecific: nil),
        Item(id: "cfg_intl_004", name: "SIM卡", nameEn: "SIM Card", category: .electronics, genderSpecific: nil),
        Item(id: "cfg_intl_005", name: "外币", nameEn: "Foreign Currency", category: .documents, genderSpecific: nil),
        Item(id: "cfg_intl_006", name: "常备急救药", nameEn: "First Aid Kit", category: .other, genderSpecific: nil),
        Item(id: "cfg_intl_007", name: "洗发水", nameEn: "Shampoo", category: .toiletries, genderSpecific: nil),
        Item(id: "cfg_intl_008", name: "沐浴露", nameEn: "Body Wash", category: .toiletries, genderSpecific: nil),
        Item(id: "cfg_intl_009", name: "身体乳", nameEn: "Body Lotion", category: .toiletries, genderSpecific: nil),
        
        // ========== SPEC 4.4: 出行配置 - 带娃 ==========
        Item(id: "cfg_kids_001", name: "尿布", nameEn: "Diapers", category: .other, genderSpecific: nil),
        Item(id: "cfg_kids_002", name: "奶瓶/奶粉", nameEn: "Bottle/Formula", category: .other, genderSpecific: nil),
        Item(id: "cfg_kids_003", name: "湿巾", nameEn: "Wet Wipes", category: .other, genderSpecific: nil),
        Item(id: "cfg_kids_004", name: "折叠推车", nameEn: "Stroller", category: .other, genderSpecific: nil),
        Item(id: "cfg_kids_005", name: "玩具", nameEn: "Toy", category: .other, genderSpecific: nil),
        Item(id: "cfg_kids_006", name: "儿童药品", nameEn: "Children's Medicine", category: .other, genderSpecific: nil),
        
        // ========== SPEC 4.4: 出行配置 - 带宠物 ==========
        Item(id: "cfg_pet_001", name: "牵引绳", nameEn: "Leash", category: .other, genderSpecific: nil),
        Item(id: "cfg_pet_002", name: "便便袋", nameEn: "Poop Bags", category: .other, genderSpecific: nil),
        Item(id: "cfg_pet_003", name: "折叠碗", nameEn: "Collapsible Bowl", category: .other, genderSpecific: nil),
        Item(id: "cfg_pet_004", name: "宠物口粮", nameEn: "Pet Food", category: .other, genderSpecific: nil),
        Item(id: "cfg_pet_005", name: "疫苗证明", nameEn: "Vaccination Certificate", category: .documents, genderSpecific: nil),
        Item(id: "cfg_pet_006", name: "航空箱", nameEn: "Pet Carrier", category: .other, genderSpecific: nil),
    ]
    
    // MARK: - SPEC 3.1: 基础清单（共有项 + 性别特有项）
    
    /// 共有基础项 ID（不限性别）
    let commonBaseItemIds: [String] = [
        "base_doc_001",                    // 证件
        "base_ele_001", "base_ele_002", "base_ele_003",  // 电子
        "base_hyg_001", "base_hyg_002", "base_hyg_003", "base_hyg_004", "base_hyg_005", "base_hyg_006", "base_hyg_007",  // 卫生
        "base_clo_001", "base_clo_002", "base_clo_003", "base_clo_004", "base_clo_005"  // 衣物
    ]
    
    /// 男性特有项 ID
    let maleSpecificItemIds: [String] = [
        "male_001", "male_002"
    ]
    
    /// 女性特有项 ID
    let femaleSpecificItemIds: [String] = [
        "female_001", "female_002", "female_003", "female_004", "female_005",
        "female_006", "female_007", "female_008", "female_009", "female_010"
    ]
    
    // MARK: - 标签数据库
    
    lazy var allTags: [String: Tag] = {
        var tags: [String: Tag] = [:]
        for tag in tagList {
            tags[tag.id] = tag
        }
        return tags
    }()
    
    /// 按分组获取标签
    func tags(for group: TagGroup) -> [Tag] {
        return tagList.filter { $0.group == group }
    }
    
    private let tagList: [Tag] = [
        // ========== SPEC 4.2: 旅行活动 ==========
        Tag(
            id: "running",
            name: "跑步",
            nameEn: "Running",
            group: .activity,
            icon: "figure.run",
            itemIds: ["act_run_001", "act_run_002", "act_run_003", "act_run_004", "act_run_005", "act_run_006"]
        ),
        Tag(
            id: "climbing",
            name: "攀岩",
            nameEn: "Climbing",
            group: .activity,
            icon: "figure.climbing",
            itemIds: ["act_climb_001", "act_climb_002", "act_climb_003", "act_climb_004", "act_climb_005", "act_climb_006"]
        ),
        Tag(
            id: "diving",
            name: "潜水",
            nameEn: "Diving",
            group: .activity,
            icon: "figure.pool.swim",
            itemIds: ["act_dive_001", "act_dive_002", "act_dive_003", "act_dive_004", "act_dive_005"]
        ),
        Tag(
            id: "camping",
            name: "露营",
            nameEn: "Camping",
            group: .activity,
            icon: "tent",
            itemIds: ["act_camp_001", "act_camp_002", "act_camp_003", "act_camp_004", "act_camp_005", "act_camp_006", "act_camp_007", "act_camp_008"]
        ),
        Tag(
            id: "trail_running",
            name: "越野",
            nameEn: "Trail Running",
            group: .activity,
            icon: "figure.run.circle",
            itemIds: ["act_trail_001", "act_trail_002", "act_trail_003", "act_trail_004", "act_trail_005", "act_trail_006", "act_trail_007", "act_trail_008", "act_trail_009", "act_trail_010"]
        ),
        Tag(
            id: "photography",
            name: "摄影",
            nameEn: "Photography",
            group: .activity,
            icon: "camera",
            itemIds: ["act_photo_001", "act_photo_002", "act_photo_003", "act_photo_004", "act_photo_005", "act_photo_006", "act_photo_007", "act_photo_008"]
        ),
        Tag(
            id: "motorcycle",
            name: "摩旅",
            nameEn: "Motorcycle Tour",
            group: .activity,
            icon: "motorcycle",
            itemIds: ["act_moto_001", "act_moto_002", "act_moto_003", "act_moto_004", "act_moto_005"]
        ),
        Tag(
            id: "skiing",
            name: "滑雪",
            nameEn: "Skiing",
            group: .activity,
            icon: "snowflake",
            itemIds: ["act_ski_001", "act_ski_002", "act_ski_003", "act_ski_004", "act_ski_005", "act_ski_006", "act_ski_007"]
        ),
        Tag(
            id: "beach",
            name: "海滩",
            nameEn: "Beach",
            group: .activity,
            icon: "beach.umbrella",
            itemIds: ["act_beach_001", "act_beach_002", "act_beach_003", "act_beach_004", "act_beach_005"]
        ),
        
        // ========== SPEC 4.3: 特定场合 ==========
        Tag(
            id: "party",
            name: "宴会",
            nameEn: "Party",
            group: .occasion,
            icon: "wineglass",
            itemIds: ["occ_party_001", "occ_party_002", "occ_party_003", "occ_party_004"]
        ),
        Tag(
            id: "business_meeting",
            name: "商务会议",
            nameEn: "Business Meeting",
            group: .occasion,
            icon: "briefcase",
            itemIds: ["occ_biz_001", "occ_biz_002", "occ_biz_003", "occ_biz_004", "occ_biz_005", "occ_biz_006", "occ_biz_007", "occ_biz_008"]
        ),
        Tag(
            id: "self_drive",
            name: "自驾",
            nameEn: "Self Drive",
            group: .occasion,
            icon: "car",
            itemIds: ["occ_drive_001", "occ_drive_002", "occ_drive_003", "occ_drive_004", "occ_drive_005"]
        ),
        
        // ========== SPEC 4.4: 出行配置 ==========
        Tag(
            id: "international",
            name: "国际旅行",
            nameEn: "International Travel",
            group: .config,
            icon: "airplane.departure",
            itemIds: ["cfg_intl_001", "cfg_intl_002", "cfg_intl_003", "cfg_intl_004", "cfg_intl_005", "cfg_intl_006", "cfg_intl_007", "cfg_intl_008", "cfg_intl_009"]
        ),
        Tag(
            id: "with_kids",
            name: "带娃",
            nameEn: "With Kids",
            group: .config,
            icon: "figure.child",
            itemIds: ["cfg_kids_001", "cfg_kids_002", "cfg_kids_003", "cfg_kids_004", "cfg_kids_005", "cfg_kids_006"]
        ),
        Tag(
            id: "with_pet",
            name: "带宠物",
            nameEn: "With Pet",
            group: .config,
            icon: "pawprint",
            itemIds: ["cfg_pet_001", "cfg_pet_002", "cfg_pet_003", "cfg_pet_004", "cfg_pet_005", "cfg_pet_006"]
        ),
    ]
    
    // MARK: - 清单生成
    
    /// 根据选中的标签生成物品清单（SPEC: 基础清单 + 标签对应 Item + 自定义 Item）
    func generatePackingList(tagIds: Set<String>, gender: Gender) -> [TripItem] {
        var itemSet = Set<String>()
        
        // 1. SPEC 3.1: 先加入基础清单（共有项 + 性别特有项）
        itemSet.formUnion(commonBaseItemIds)
        if gender == .male {
            itemSet.formUnion(maleSpecificItemIds)
        } else {
            itemSet.formUnion(femaleSpecificItemIds)
        }
        
        // 2. SPEC 4.2/4.3/4.4: 收集所有选中标签的预设物品 ID（过滤已删除的）
        let customManager = CustomItemManager.shared
        for tagId in tagIds {
            if let tag = allTags[tagId] {
                // SPEC v1.5: 过滤已删除的预设 Item
                let activeItemIds = tag.itemIds.filter { !customManager.isPresetItemDeleted($0) }
                itemSet.formUnion(activeItemIds)
            }
        }
        
        // 3. 转换为 TripItem（性别过滤已在基础清单中处理，标签 Item 无需再过滤）
        // PRD v1.0: 实现基于名称的物品去重机制
        var tripItems: [TripItem] = []
        var addedItemNames = Set<String>() // 记录已添加的物品名称（中英文组合）

        for itemId in itemSet {
            if let item = allItems[itemId] {
                // 检查性别过滤（仅对标签 Item 中的性别特定项）
                let shouldAddItem: Bool
                if let genderSpecific = item.genderSpecific {
                    shouldAddItem = (genderSpecific == gender)
                } else {
                    shouldAddItem = true
                }

                if shouldAddItem {
                    // PRD v1.0: 检查名称是否重复（基于中英文名称）
                    let nameKey = "\(item.name)|\(item.nameEn)"
                    if !addedItemNames.contains(nameKey) {
                        addedItemNames.insert(nameKey)
                        tripItems.append(item.toTripItem())
                    } else {
                        // 调试日志：记录被去重的物品
                        print("🔄 去重: \(item.name) (\(item.nameEn)) - ID: \(itemId)")
                    }
                }
            }
        }
        
        // 4. PRD v1.4: 加入用户自定义 Item
        // PRD v1.0: 自定义物品也需要参与去重，避免与预设物品重复
        var customItemNames = Set<String>()

        for tagId in tagIds {
            let customItems = customManager.getCustomItems(for: tagId)
            customItemNames.formUnion(customItems)
        }

        // 转换自定义 Item 为 TripItem（放入"其他"分类）
        for customName in customItemNames {
            // PRD v1.0: 使用 addedItemNames 进行去重检查
            let nameKey = "\(customName)|\(customName)"
            if !addedItemNames.contains(nameKey) {
                addedItemNames.insert(nameKey)
                let customTripItem = TripItem(
                    id: "custom_\(UUID().uuidString.prefix(8))",
                    name: customName,
                    nameEn: customName,
                    category: ItemCategory.other.nameCN,
                    categoryEn: ItemCategory.other.nameEN,
                    sortOrder: ItemCategory.other.sortOrder
                )
                tripItems.append(customTripItem)
            } else {
                // 调试日志：记录被去重的自定义物品
                print("🔄 去重自定义物品: \(customName)")
            }
        }
        
        // 5. 按分类排序（F3 fix: 直接使用 TripItem.sortOrder，而非 rawValue 匹配）
        tripItems.sort { item1, item2 in
            if item1.sortOrder != item2.sortOrder {
                return item1.sortOrder < item2.sortOrder
            }
            return item1.name < item2.name
        }
        
        return tripItems
    }
    
    /// 获取某个标签下的所有预设 Item（过滤已删除的）
    func getPresetItems(for tagId: String) -> [Item] {
        guard let tag = allTags[tagId] else { return [] }
        let customManager = CustomItemManager.shared
        // SPEC v1.5: 过滤已删除的预设 Item
        let activeItemIds = tag.itemIds.filter { !customManager.isPresetItemDeleted($0) }
        return activeItemIds.compactMap { allItems[$0] }
    }
    
    /// 按分类分组物品
    func groupByCategory(_ items: [TripItem], language: AppLanguage) -> [(category: String, items: [TripItem])] {
        var grouped: [String: [TripItem]] = [:]
        
        for item in items {
            let category = language == .chinese ? item.category : item.categoryEn
            if grouped[category] == nil {
                grouped[category] = []
            }
            grouped[category]?.append(item)
        }
        
        // 按分类顺序排序
        let categoryOrder: [String: Int] = [
            "证件/钱财": 0, "Documents & Money": 0,
            "衣物": 1, "Clothing": 1,
            "洗漱用品": 2, "Toiletries": 2,
            "电子产品": 3, "Electronics": 3,
            "运动装备": 4, "Sports Gear": 4,
            "其他": 5, "Other": 5
        ]
        
        return grouped.map { ($0.key, $0.value) }
            .sorted { (categoryOrder[$0.category] ?? 99) < (categoryOrder[$1.category] ?? 99) }
    }
}
