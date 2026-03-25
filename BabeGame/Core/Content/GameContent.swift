import Foundation

struct DestinationDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let accentKey: String
    let baseCoinReward: Int
    let souvenirIDs: [String]
    let photoCardIDs: [String]
}

struct OutfitDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let accentKey: String
    let cost: Int
}

struct AccessoryDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let accentKey: String
    let cost: Int
}

struct FurnitureDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let accentKey: String
    let slot: HomeSlot
    let cost: Int
}

struct CollectibleDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let blurb: String
    let destinationID: String
    let rarityLabel: String
}

struct PhotoCardDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let caption: String
    let destinationID: String
}

enum GameContent {
    static let tripDurations = [30, 60, 120]

    static let destinations: [DestinationDefinition] = [
        DestinationDefinition(
            id: "bamboo-trail",
            title: "竹影小径",
            subtitle: "风吹竹叶，会带回来淡淡青草味。",
            accentKey: "mint",
            baseCoinReward: 14,
            souvenirIDs: ["bamboo-leaf", "rain-stone", "tea-postcard", "reed-lantern"],
            photoCardIDs: ["bamboo-nap", "trail-breeze"]
        ),
        DestinationDefinition(
            id: "sunset-pier",
            title: "晚霞码头",
            subtitle: "会看到橘色海面和摇晃的小船。",
            accentKey: "peach",
            baseCoinReward: 18,
            souvenirIDs: ["shell-ribbon", "drift-bottle", "sunset-ticket", "little-anchor"],
            photoCardIDs: ["pier-gold", "boat-yawn"]
        ),
        DestinationDefinition(
            id: "starlight-market",
            title: "星灯集市",
            subtitle: "夜里热闹，常有亮闪闪的小惊喜。",
            accentKey: "berry",
            baseCoinReward: 22,
            souvenirIDs: ["berry-bell", "jam-spoon", "woven-star", "night-badge"],
            photoCardIDs: ["market-smile", "lantern-spark"]
        )
    ]

    static let outfits: [OutfitDefinition] = [
        OutfitDefinition(id: "linen-apron", title: "亚麻围裙", subtitle: "像在家里做小饼干。", accentKey: "butter", cost: 0),
        OutfitDefinition(id: "sea-scarf", title: "海风围巾", subtitle: "出门会更精神。", accentKey: "sky", cost: 60),
        OutfitDefinition(id: "leaf-kimono", title: "落叶和服", subtitle: "轻轻一披就很治愈。", accentKey: "mint", cost: 90),
        OutfitDefinition(id: "berry-cape", title: "莓果小披风", subtitle: "晚霞时最可爱。", accentKey: "berry", cost: 120),
        OutfitDefinition(id: "cloud-sweater", title: "云朵毛衣", subtitle: "适合赖在窗边。", accentKey: "pearl", cost: 150),
        OutfitDefinition(id: "moon-pajamas", title: "月亮睡衣", subtitle: "适合抱着枕头打滚。", accentKey: "indigo", cost: 180)
    ]

    static let accessories: [AccessoryDefinition] = [
        AccessoryDefinition(id: "bell-collar", title: "小铃铛", subtitle: "默认随身的小响声。", accentKey: "gold", cost: 0),
        AccessoryDefinition(id: "peach-bow", title: "桃桃蝴蝶结", subtitle: "软软的很甜。", accentKey: "peach", cost: 45),
        AccessoryDefinition(id: "leaf-pin", title: "叶片发夹", subtitle: "像从花园带回来的礼物。", accentKey: "mint", cost: 65),
        AccessoryDefinition(id: "star-charm", title: "星星挂件", subtitle: "会轻轻闪一下。", accentKey: "berry", cost: 85)
    ]

    static let furniture: [FurnitureDefinition] = [
        FurnitureDefinition(id: "cotton-bed", title: "棉花小窝", subtitle: "一靠进去就不想起来。", accentKey: "butter", slot: .bed, cost: 0),
        FurnitureDefinition(id: "moon-bed", title: "月牙窝床", subtitle: "圆圆地抱住小猫。", accentKey: "indigo", slot: .bed, cost: 110),
        FurnitureDefinition(id: "sun-window", title: "日光窗台", subtitle: "晒太阳的首选。", accentKey: "peach", slot: .window, cost: 0),
        FurnitureDefinition(id: "green-window", title: "薄荷窗台", subtitle: "清清爽爽像早晨。", accentKey: "mint", slot: .window, cost: 95),
        FurnitureDefinition(id: "woven-rug", title: "编织地毯", subtitle: "踩上去像棉花。", accentKey: "pearl", slot: .rug, cost: 80),
        FurnitureDefinition(id: "berry-rug", title: "莓果圆毯", subtitle: "房间会活泼很多。", accentKey: "berry", slot: .rug, cost: 105),
        FurnitureDefinition(id: "postcard-wall", title: "明信片墙", subtitle: "挂上旅行回忆。", accentKey: "sky", slot: .wall, cost: 88),
        FurnitureDefinition(id: "lantern-wall", title: "晚灯挂饰", subtitle: "夜里会很温柔。", accentKey: "gold", slot: .wall, cost: 135)
    ]

    static let collectibles: [CollectibleDefinition] = [
        CollectibleDefinition(id: "bamboo-leaf", title: "竹叶书签", blurb: "风吹得边角卷卷的。", destinationID: "bamboo-trail", rarityLabel: "普通"),
        CollectibleDefinition(id: "rain-stone", title: "雨后小石", blurb: "摸上去凉凉的。", destinationID: "bamboo-trail", rarityLabel: "普通"),
        CollectibleDefinition(id: "tea-postcard", title: "茶香明信片", blurb: "上面还有淡淡茶味。", destinationID: "bamboo-trail", rarityLabel: "稀有"),
        CollectibleDefinition(id: "reed-lantern", title: "芦苇小灯", blurb: "像把黄昏带回家。", destinationID: "bamboo-trail", rarityLabel: "稀有"),
        CollectibleDefinition(id: "shell-ribbon", title: "贝壳丝带", blurb: "系在礼盒上很漂亮。", destinationID: "sunset-pier", rarityLabel: "普通"),
        CollectibleDefinition(id: "drift-bottle", title: "漂流瓶", blurb: "里面有一张卷起来的小纸条。", destinationID: "sunset-pier", rarityLabel: "普通"),
        CollectibleDefinition(id: "sunset-ticket", title: "夕照船票", blurb: "像一小块被压平的晚霞。", destinationID: "sunset-pier", rarityLabel: "稀有"),
        CollectibleDefinition(id: "little-anchor", title: "迷你船锚", blurb: "口袋里沉甸甸的。", destinationID: "sunset-pier", rarityLabel: "稀有"),
        CollectibleDefinition(id: "berry-bell", title: "莓果风铃", blurb: "轻轻一晃就叮当响。", destinationID: "starlight-market", rarityLabel: "普通"),
        CollectibleDefinition(id: "jam-spoon", title: "果酱小勺", blurb: "亮晶晶的像新洗过。", destinationID: "starlight-market", rarityLabel: "普通"),
        CollectibleDefinition(id: "woven-star", title: "手编星星", blurb: "摸起来毛茸茸。", destinationID: "starlight-market", rarityLabel: "稀有"),
        CollectibleDefinition(id: "night-badge", title: "夜市徽章", blurb: "像偷偷盖了章的勇气。", destinationID: "starlight-market", rarityLabel: "稀有")
    ]

    static let photoCards: [PhotoCardDefinition] = [
        PhotoCardDefinition(id: "bamboo-nap", title: "竹林打盹", caption: "靠着风声睡着了。", destinationID: "bamboo-trail"),
        PhotoCardDefinition(id: "trail-breeze", title: "小径回头", caption: "像是刚听见你叫它。", destinationID: "bamboo-trail"),
        PhotoCardDefinition(id: "pier-gold", title: "码头金光", caption: "胡须边缘都被染成暖色。", destinationID: "sunset-pier"),
        PhotoCardDefinition(id: "boat-yawn", title: "船边哈欠", caption: "困困地伸了个懒腰。", destinationID: "sunset-pier"),
        PhotoCardDefinition(id: "market-smile", title: "夜市偷笑", caption: "像发现了很想分享的宝贝。", destinationID: "starlight-market"),
        PhotoCardDefinition(id: "lantern-spark", title: "灯下闪光", caption: "眼睛里装着细碎星点。", destinationID: "starlight-market")
    ]

    static func destination(id: String) -> DestinationDefinition? {
        destinations.first { $0.id == id }
    }

    static func outfit(id: String?) -> OutfitDefinition? {
        guard let id else { return nil }
        return outfits.first { $0.id == id }
    }

    static func accessory(id: String?) -> AccessoryDefinition? {
        guard let id else { return nil }
        return accessories.first { $0.id == id }
    }

    static func furniture(id: String?) -> FurnitureDefinition? {
        guard let id else { return nil }
        return furniture.first { $0.id == id }
    }

    static func collectible(id: String) -> CollectibleDefinition? {
        collectibles.first { $0.id == id }
    }

    static func photoCard(id: String) -> PhotoCardDefinition? {
        photoCards.first { $0.id == id }
    }

    static func furniture(for slot: HomeSlot) -> [FurnitureDefinition] {
        furniture.filter { $0.slot == slot }
    }
}
