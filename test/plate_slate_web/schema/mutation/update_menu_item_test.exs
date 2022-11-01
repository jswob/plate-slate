defmodule PlateSlateWeb.Schema.Mutation.UpdateMenuTest do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Repo, Menu}
  import Ecto.Query

  setup do
    PlateSlate.Seeds.run()

    category_id =
      from(c in Menu.Category, where: c.name == "Sandwiches")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string

    {:ok, %Menu.Item{id: item_id}} =
      Menu.create_item(%{
        "name" => "French Dip",
        "description" => "Roast beef, camelized onions, horseradish, ...",
        "price" => "5.75",
        "category_id" => category_id
      })

    {:ok, item_id: to_string(item_id)}
  end

  @query """
  mutation UpdateMenuItem($input: MenuItemUpdateInput!, $item_id: String!) {
  	updateMenuItem(input: $input, item_id: $item_id) {
  		errors { key, message }
  		menuItem {
  			name
				category {
					name
				}
  		}
  	}
  }
  """
  test "updateMenuItem field returns an error when item is not found" do
    conn = build_conn()

    conn =
      post conn, "/api",
        query: @query,
        variables: %{"input" => %{}, "item_id" => "123456789"}

    assert %{
             "data" => %{
               "updateMenuItem" => %{
                 "errors" => [%{"key" => "item_id", "message" => "Item not found."}],
                 "menuItem" => nil
               }
             }
           } == json_response(conn, 200)
  end

  test "updateMenuItem field updates item", %{item_id: item_id} do
    input = %{"name" => "Hello"}
    conn = build_conn()

    conn =
      post conn, "/api",
        query: @query,
        variables: %{"input" => input, "item_id" => item_id}

    assert %{
             "data" => %{
               "updateMenuItem" => %{"errors" => nil, "menuItem" => %{"name" => "Hello"}}
             }
           } == json_response(conn, 200)
  end
end
