defmodule PlateSlateWeb.Schema do
	use Absinthe.Schema

	alias PlateSlateWeb.Resolvers

	import_types __MODULE__.Scalars
	import_types __MODULE__.Enums
	import_types __MODULE__.MenuTypes

	query do
		import_fields :menu_queries
	end

	mutation do
		field :create_menu_item, :menu_item_result do
			arg :input, non_null :menu_item_input
			resolve &Resolvers.Menu.create_item/3
		end

		field :update_menu_item, :menu_item_result do
			arg :input, non_null :menu_item_update_input
			arg :item_id, non_null :string
			resolve &Resolvers.Menu.update_item/3
		end
	end
end
