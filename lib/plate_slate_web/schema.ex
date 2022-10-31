defmodule PlateSlateWeb.Schema do
	use Absinthe.Schema

	import Ecto.Query

	alias PlateSlate.{Menu, Repo}
	alias PlateSlateWeb.Resolvers

	import_types __MODULE__.MenuTypes

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

		@desc "The list of categories of items on a menu"
		field :categories, list_of(:category) do
			arg :matching, :string
			arg :order, :sort_order, default_value: :asc
			resolve &Resolvers.Menu.categories/3
		end

		@desc """
		The list of categories and menu items that has name
		or description matching passed term.
		"""
		field :search, list_of(:search_result) do
			arg :matching, non_null :string
			resolve &Resolvers.Menu.search/3
		end
	end

	@desc "The custom scalar type for emails"
	scalar :email do
		parse fn email ->
			case String.split(email, "@") do
				[username, domain] -> {username, domain}

				_ -> throw "Email \"#{email}\" is not valid."
			end
		end

		serialize fn {username, domain} ->
			"#{username}@#{domain}"
		end
	end

	@desc "The custom scalar type for dates in format \"yyyy-mm-dd\""
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
