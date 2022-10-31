defmodule PlateSlateWeb.Schema.MenuTypes do
	use Absinthe.Schema.Notation

	alias PlateSlateWeb.Resolvers

	@desc """
	The category or menu item.
	"""
	union :search_result do
		types [:menu_item, :category]
		resolve_type fn
			%PlateSlate.Menu.Item{}, _ ->
				:menu_item
			%PlateSlate.Menu.Category{}, _ ->
				:category
			_, _ ->
				nil
		end
	end

	@desc "Filtering options for the menu item list"
	input_object :menu_item_filter do
		@desc "Matching a name"
		field :name, :string

		@desc "Matching a category name"
		field :category, :string

		@desc "Matching a tag"
		field :tag, :string

		@desc "Priced above a value"
		field :priced_above, :float

		@desc "Priced below a value"
		field :priced_below, :float

		@desc "Added after a date"
		field :added_after, :date

		@desc "Added before a date"
		field :added_before, :date
	end

	@desc "The item on a menu."
	object :menu_item do
		@desc "The unique identifier of item."
		field :id, :id

		@desc "The name (label) of the item."
		field :name, :string

		@desc "The description (ingredients, weight, etc.) of item."
		field :description, :string

		@desc "The date item has been added on"
		field :added_on, :date
	end

	@desc "The category of an item on a menu."
	object :category do
		@desc "The name of the category"
		field :name, :string

		@desc "The description of a category"
		field :description, :string

		field :items, list_of(:menu_item) do
			resolve &Resolvers.Menu.items_for_category/3
		end
	end
end
