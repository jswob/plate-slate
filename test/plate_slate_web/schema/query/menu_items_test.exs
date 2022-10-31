defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  	query GetMenuItems($filter: MenuItemFilter!) {
  		menuItems(filter: $filter) {
  			name
  		}
  	}
  """
  @variables %{
    "filter" => %{}
  }
  test "menuItems field returns menu items" do
    conn = build_conn()
    conn = get conn, "/api", query: @query, variables: @variables

    assert json_response(conn, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Bánh mì"},
                 %{"name" => "Chocolate Milkshake"},
                 %{"name" => "Croque Monsieur"},
                 %{"name" => "French Fries"},
                 %{"name" => "Lemonade"},
                 %{"name" => "Masala Chai"},
                 %{"name" => "Muffuletta"},
                 %{"name" => "Papadum"},
                 %{"name" => "Pasta Salad"},
                 %{"name" => "Reuben"},
                 %{"name" => "Soft Drink"},
                 %{"name" => "Vada Pav"},
                 %{"name" => "Vanilla Milkshake"},
                 %{"name" => "Water"}
               ]
             }
           }
  end

  @query """
  	{
  		menuItems(filter: {name: "reu"}) {
  			name
  		}
  	}
  """
  test "menuItems field returns menu items filtered by name" do
    response = get(build_conn(), "/api", query: @query)

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
  	{
  		menuItems(filter: {name: 123}) {
  			name
  		}
  	}
  """
  test "menuItems field returns errors when using a bad value" do
    response = get(build_conn(), "/api", query: @query)

    assert %{
             "errors" => [
               %{"message" => message}
             ]
           } = json_response(response, 200)

    assert message ==
             "Argument \"filter\" has invalid value {name: 123}.\nIn field \"name\": Expected type \"String\", found 123."
  end

  @query """
  	query GetMenuItems($filter: MenuItemFilter!) {
  		menuItems(filter: $filter) {
  			name
  		}
  	}
  """
  @variables %{"filter" => %{"name" => "reu"}}
  test "menuItems field filters by name when using a variable" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
  	query GetMenuItems($filter: MenuItemFilter!, $order: SortOrder!) {
  		menuItems(filter: $filter, order: $order) {
  			name
  		}
  	}
  """
  @variables %{
    "filter" => %{},
    "order" => "DESC"
  }
  test "menuItems field returns items descending using literals" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{
               "menuItems" => [%{"name" => "Water"} | _]
             }
           } = json_response(response, 200)
  end

  @query """
  	query GetMenuItems($filter: MenuItemFilter!){
  		menuItems(filter: $filter) {
  			name
  		}
  	}
  """
  @variables %{
    "filter" => %{
      "category" => "Sandwiches",
      "tag" => "Vegetarian"
    }
  }
  test "test" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
           } == json_response(response, 200)
  end

  @query """
  	query GetMenuItems($filter: MenuItemFilter!){
  		menuItems(filter: $filter) {
  			name
  			addedOn
  		}
  	}
  """
  @variables %{"filter" => %{"addedBefore" => "2022-10-15"}}
  test "menuItems filtered by custom scalar" do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")

    %PlateSlate.Menu.Item{
      name: "Garlic Fries",
      added_on: ~D[2022-10-10],
      price: 2.50,
      category: sides
    }
    |> PlateSlate.Repo.insert!()

    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Garlic Fries", "addedOn" => "2022-10-10"}]}
           } == json_response(response, 200)
  end

  @query """
  	query GetMenuItems($filter: MenuItemFilter!){
  		menuItems(filter: $filter) {
  			name
  			addedOn
  		}
  	}
  """
  @variables %{"filter" => %{"addedBefore" => "not-a-date"}}
  test "menuItems filtered by custom scalar with error" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "errors" => [
               %{
                 "locations" => [
                   %{"column" => 13, "line" => 2}
                 ],
                 "message" => message
               }
             ]
           } = json_response(response, 200)

    expected = """
    Argument "filter" has invalid value $filter.
    In field "addedBefore": Expected type "Date", found "not-a-date".\
    """

    assert expected == message
  end

  @query """
  query Search($term: String!) {
  	search(matching: $term) {
  		name
  		__typename
  	}
  }
  """
  @variables %{term: "e"}
  test "search returns a list of menu items and categories" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)
    assert %{"data" => %{"search" => results}} = json_response(response, 200)
    assert length(results) > 0
    assert Enum.find(results, &(&1["__typename"] == "Category"))
    assert Enum.find(results, &(&1["__typename"] == "MenuItem"))
  end
end
