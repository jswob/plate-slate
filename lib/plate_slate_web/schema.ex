defmodule PlateSlateWeb.Schema do
	use Absinthe.Schema
	alias PlateSlate.{Menu, Repo}

	query do
		field :menu_items, list_of(:menu_items) do
			resolve fn _, _, _ ->
				{:ok, Repo.all(Menu.Item)} end
		end
	end

	object :menu_items do
		field :id, :id
		field :name, :string
		field :description, :string
	end
end
