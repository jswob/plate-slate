defmodule PlateSlateWeb.Schema do
	use Absinthe.Schema

	import Ecto.Query

	alias PlateSlate.{Menu, Repo}
	alias PlateSlateWeb.Resolvers

	enum :sort_order do
		value :asc
		value :desc
	end

	query do
		@desc "The list of available items on the menu."
		field :menu_items, list_of(:menu_item) do
			arg :filter, non_null :menu_item_filter
			arg :order, :sort_order, default_value: :asc
			resolve &Resolvers.Menu.menu_items/3
		end
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

		field :added_before, :date
		field :added_after, :date
	end

	scalar :date do
		parse fn input ->
			with %Absinthe.Blueprint.Input.String{value: value} <- input,
			{:ok, date} <- Date.from_iso8601(value) do
				{:ok, date}
			else
				_ -> :error
			end
		end

		serialize fn date ->
			Date.to_iso8601(date)
		end
	end
end
