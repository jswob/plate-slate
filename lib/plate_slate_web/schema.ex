defmodule PlateSlateWeb.Schema do
	use Absinthe.Schema

	query do
		field :menu_items, list_of(:menu_items)
	end

	object :menu_item do
		field :id, :id
		field :name, :string
		field :description, :string
	end
end
