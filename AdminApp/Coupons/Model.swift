struct Coupon: Decodable {
    var code: String
}

struct PromotionCoupon: Identifiable, Decodable {
    var id: Int
    var name: String
    var coupons: [Coupon]
}

struct PromotionCouponReq {
    var promotionId: Int
    var couponId: String
}
