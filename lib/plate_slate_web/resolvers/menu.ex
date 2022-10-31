defmodule PlateSlateWeb.Resolvers.Menu do
	import Ecto.Query

	alias PlateSlate.Menu
	alias PlateSlate.Menu.Item

	def menu_items(_, args, _) do
		{:ok, Menu.list_items(args)}
	end

	def categories(_, args, _) do
		{:ok, Menu.list_categories(args)}
	end
end
