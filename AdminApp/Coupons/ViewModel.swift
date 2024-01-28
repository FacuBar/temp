import SwiftUI

class CouponViewModel: ObservableObject
{
	enum State
	{
		case idle
		case loading
		case failed(Error)
		case loaded(PromotionCoupon)

		var isIdle: Bool
		{
			if case .idle = self { return true }
			return false
		}
	}

	@Published private(set) var state: State = .idle

	func getCoupon(coupon: PromotionCouponReq)
	{
		state = .loading

		// TODO: we're pointing to local
		let url =
			URL(
				string: "http://192.168.100.2:8080/promotions/\(coupon.promotionId)/coupons/\(coupon.couponId)"
			)!
		var request = URLRequest(url: url)
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "GET"

		let dataTask = URLSession.shared.dataTask(with: request)
		{ data, response, error in
			if let error = error
			{
				self.state = .failed(error)
				return
			}

			guard let response = response as? HTTPURLResponse
			else
			{
				self.state = .failed(NSError(domain: url.absoluteString, code: 503))
				return
			}

			if response.statusCode >= 200 && response.statusCode < 300
			{
				guard let data = data
				else
				{
					print("Error: Empty response")
					self.state = .failed(NSError(domain: url.absoluteString, code: 1))
					return
				}
				guard let decoded = try? JSONDecoder().decode(
					PromotionCoupon.self,
					from: data
				)
				else
				{
					print("Error: Marshalling unsuccessfull")
					self.state = .failed(NSError(domain: url.absoluteString, code: 1))
					return
				}
				self.state = .loaded(decoded)
				return
			}
			else
			{
				self.state = .failed(NSError(
					domain: url.absoluteString,
					code: response.statusCode
				))
				return
			}
		}
		dataTask.resume()
	}
}
