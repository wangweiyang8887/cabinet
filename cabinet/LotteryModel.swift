// Copyright © 2021 evan. All rights reserved.

struct LotteryModel : Codable {
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

extension Server {
    static func fetchLottery(with id: String) -> Operation<LotteryModel> {
        return Server.fire(.get, .lottery, parameters: [ "lottery_id":id, "lottery_no":"", "key":"f7359c92478f397e465867fc24a550a2" ])
    }
}
