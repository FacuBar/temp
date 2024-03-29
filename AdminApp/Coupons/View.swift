import SwiftUI

struct CouponsView: View
{
	@StateObject var viewModel = CouponViewModel()
	var body: some View
	{
		CouponForm(viewModel: viewModel)
	}
}

struct CouponForm: View
{
	@ObservedObject var viewModel: CouponViewModel
	@State private var promotionCoupon: PromotionCouponReq = .init(
		promotionId: 0,
		couponId: ""
	)
	@State private var modalOpen: Bool = false

	// TODO: debugging; remove
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	var body: some View
	{
		ZStack
		{
			Form
			{
				Section("Promotion")
				{
					TextField(
						"Insert Promotion ID",
						value: $promotionCoupon.promotionId,
						formatter: NumberFormatter()
					).keyboardType(.decimalPad)
				}

				Section("Coupon")
				{
					TextField("Insert Coupon", text: $promotionCoupon.couponId)
				}

				Button("Validate Coupon")
				{
					modalOpen = true
					viewModel.getCoupon(coupon: promotionCoupon)
				}
			}.disabled(modalOpen)
			if modalOpen
			{
				ModalView(modalOpen: $modalOpen)
				{
					switch viewModel.state
					{
					case .idle:
						Text("idle")
					case .loading:
						Text("Loading ...")
					case let .loaded(resp):
						Text("Valid Coupon for Promo \(resp.name)")
					case let .failed(err):
						Text(err.localizedDescription)
					}
				}
			}
			// TODO: debugging; remove
		}.onReceive(timer, perform: { _ in
			print(viewModel.state)
		})
	}
}

struct ModalView<Content: View>: View
{
	@Binding var modalOpen: Bool
	@ViewBuilder var content: Content

	var body: some View
	{
		if modalOpen
		{
			Color.gray.opacity(0.4).edgesIgnoringSafeArea(.all)

			VStack
			{
				content.frame(maxHeight: .infinity)
				Button("X")
				{
					modalOpen = false
				}
			}
			.frame(maxWidth: 300, maxHeight: 200, alignment: .bottom)
			.padding()
			.background(Color.primary.colorInvert())
			.cornerRadius(50)
		}
	}
}

struct CouponsView_Previews: PreviewProvider
{
	static var previews: some View
	{
		CouponsView()
	}
}
