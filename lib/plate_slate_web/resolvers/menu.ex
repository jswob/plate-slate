defmodule PlateSlateWeb.Resolvers.Menu do
	import Ecto.Query

	alias PlateSlate.Menu
	alias PlateSlate.Menu.Item

	def items_for_category(category, _, _) do
		query = Ecto.assoc(category, :items)
		{:ok, PlateSlate.Repo.all(query)}
	end

	def menu_items(_, args, _) do
		{:ok, Menu.list_items(args)}
	end

	def categories(_, args, _) do
		{:ok, Menu.list_categories(args)}
	end

	def search(_, %{matching: term}, _) do
		{:ok, Menu.search(term)}
	end
end
