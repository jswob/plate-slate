defmodule PlateSlateWeb.Schema do
	use Absinthe.Schema
	alias PlateSlate.{Menu, Repo}

	query do
		@desc "The list of available items on the menu."
		field :menu_items, list_of(:menu_items) do
			resolve fn _, _, _ ->
				{:ok, Repo.all(Menu.Item)} end
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
