defmodule PlateSlateWeb.Resolvers.Menu do
  import Ecto.Query

  alias PlateSlate.Menu
  alias PlateSlate.Menu.Item

  def items_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)
    {:ok, PlateSlate.Repo.all(query)}
  end

  def category_for_item(item, _, _) do
    query = Ecto.assoc(item, :category)
    {:ok, PlateSlate.Repo.one(query)}
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

  def update_item(_, %{item_id: item_id, input: input}, _) do
    case Menu.update_item(item_id, input) do
			{:error, :not_found} ->
				{:ok, %{errors: %{key: "item_id", message: "Item not found."}}}

      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}

      {:ok, menu_item} ->
        {:ok, %{menu_item: menu_item}}
    end
  end

  def create_item(_, %{input: params}, _) do
    case Menu.create_item(params) do
      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}

      {:ok, menu_item} ->
        {:ok, %{menu_item: menu_item}}
    end
  end

  defp transform_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_error/1)
    |> Enum.map(fn
      {key, value} ->
        %{key: key, message: value}
    end)
  end

  defp format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
