defmodule PlateSlateWeb.Schema do
	use Absinthe.Schema

	import Ecto.Query

	alias PlateSlate.{Menu, Repo}
	alias PlateSlateWeb.Resolvers

	query do
		@desc "The list of available items on the menu."
		field :menu_items, list_of(:menu_items) do
			arg :matching, :string
			resolve &Resolvers.Menu.menu_items/3
		end
	end

	@desc "The item on a menu."
	object :menu_items do
		@desc "The unique identifier of item."
		field :id, :id

		@desc "The name (label) of the item."
		field :name, :string

		@desc "The description (ingredients, weight, etc.) of item."
		field :description, :string
	end
end
