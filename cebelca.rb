require 'http'

class Cebelca
	def initialize(api_key=nil)
		@api_key = api_key
	end

	def call(r, m, params={})
		url = "https://www.cebelca.biz/API?_r=#{r}&_m=#{m}"
		HTTP.basic_auth(:user => @api_key, :pass => "x").post(url, :form => params)
	end

	def add_partner(order)
		unwind call('partner', 'assure', {name: order.name, street: order.address, postal: order.zip, city: order.city})
	end

	def add_invoice(order, partner_id)
		unwind call('invoice-sent', 'insert-into', {date_sent: date, date_to_pay: date_to_pay , date_served: date, id_partner: partner_id})
	end

	def add_invoice_item(order, invoice_id)
		unwind call('invoice-sent-b', 'insert-into', {title: title_id(order), qty: order.qty, mu: 'kos', vat: 0, price: order.amount.to_s, id_invoice_sent: invoice_id})
	end

	def unwind(response)
		JSON.parse(response)[0][0]["id"]
	end

	def date(t=Time.now)
		t.strftime("%d.%m.%Y")
	end

	def date_to_pay
		date(Time.now)
	end

	def import(order)
		partner_id = add_partner(order)
		invoice_id = add_invoice(order, partner_id)
		add_invoice_item(order, invoice_id)
		true
	end

	def title_id(order)
		"#{order.title} (ID:#{order.get_id})"
	end
end

