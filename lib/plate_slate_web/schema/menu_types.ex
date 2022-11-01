defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers

  object :menu_queries do
    @desc "The list of available items on the menu."
    field :menu_items, list_of(:menu_item) do
      arg(:filter, non_null(:menu_item_filter))
      arg(:order, :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.menu_items/3)
    end

    @desc "The list of categories of items on a menu"
    field :categories, list_of(:category) do
      arg(:matching, :string)
      arg(:order, :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.categories/3)
    end

    @desc """
    The list of categories and menu items that has name
    or description matching passed term.
    """
    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Menu.search/3)
    end
  end

  @desc """
  The category or menu item.
  """
  interface :search_result do
    field :name, :string

    resolve_type(fn
      %PlateSlate.Menu.Item{}, _ ->
        :menu_item

      %PlateSlate.Menu.Category{}, _ ->
        :category

      _, _ ->
        nil
    end)
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
    field :priced_above, :decimal

    @desc "Priced below a value"
    field :priced_below, :decimal

    @desc "Added after a date"
    field :added_after, :date

    @desc "Added before a date"
    field :added_before, :date
  end

  @desc "The item on a menu."
  object :menu_item do
    interfaces([:search_result])

    @desc "The unique identifier of item."
    field :id, :id

    @desc "The name (label) of the item."
    field :name, :string

    @desc "The description (ingredients, weight, etc.) of item."
    field :description, :string

		@desc "The decimal value of price of an item."
		field :price, :decimal

    @desc "The date item has been added on"
    field :added_on, :date

		field :category, :category,
			do: resolve(&Resolvers.Menu.category_for_item/3)
  end

	input_object :menu_item_input do
		field :name, non_null :string
		field :description, :string
		field :price, non_null :decimal
		field :category_id, non_null :id
	end

  @desc "The category of an item on a menu."
  object :category do
    interfaces([:search_result])

    @desc "The name of the category"
    field :name, :string

    @desc "The description of a category"
    field :description, :string

    field :items, list_of(:menu_item) do
      resolve(&Resolvers.Menu.items_for_category/3)
    end
  end

	object :menu_item_result do
		field :menu_item, :menu_item
		field :errors, list_of(:input_error)
	end

	@desc "An error encountered trying to persist input"
	object :input_error do
		field :key, non_null :string
		field :message, non_null :string
	end
end
