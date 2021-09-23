// Copyright © 2021 evan. All rights reserved.

class LotteryModel : Codable {
    let lottery_id: String
    let lottery_name: String // 彩种
    let lottery_res: String // 结果
    let lottery_no: String // 期号
    let lottery_date: String
    let lottery_exdate: String
    let lottery_sale_amount: String
    let lottery_pool_amount: String
    let lottery_prize: [Price]
    
    struct Price : Codable {
        let prize_name: String
        let prize_num: String
        let prize_amount: String
        let prize_require: String
    }
}

extension LotteryModel {
    var ssqRedBall: String? {
        guard let result = lottery_res.trimmedNilIfEmpty else { return nil }
        return result.components(separatedBy: ",").prefix(6).joined(separator: " ")
    }
    
    var ssqBlueBall: String? {
        guard let result = lottery_res.trimmedNilIfEmpty else { return nil }
        return result.components(separatedBy: ",").last
    }
    
    var dltRedBall: String? {
        guard let result = lottery_res.trimmedNilIfEmpty else { return nil }
        return result.components(separatedBy: ",").prefix(5).joined(separator: " ")
    }
    
    var dltBlueBallOne: String? {
        guard let result = lottery_res.trimmedNilIfEmpty else { return nil }
        return result.components(separatedBy: ",").suffix(from: 5).first
    }
    
    var dltBlueBallTwo: String? {
        guard let result = lottery_res.trimmedNilIfEmpty else { return nil }
        return result.components(separatedBy: ",").suffix(from: 5).last
    }
}
