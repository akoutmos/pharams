defmodule ExamplesWeb.OrderControllerTest do
  use ExamplesWeb.ConnCase

  describe "create" do
    test "should respond with a 200 when valid params are passed in", %{conn: conn} do
      params = %{
        shipping_method: "1_day_air",
        items: [
          %{quantity: 7, item_id: "e1ff4243-90e9-47ed-9c63-d4d45dd14f9b"},
          %{quantity: 3, item_id: "77cce0f1-fd48-4dba-9701-e6b06b1865b9"},
          %{quantity: 5, item_id: "9dc4ca4e-c873-4e9f-9649-522e604e4a5e"}
        ],
        price: 145.99,
        addresses: %{
          billing_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            city: "Somewhere",
            state: "TX",
            zip_code: "12345"
          },
          shipping_address: %{
            street_line_1: "99 Place Ave",
            city: "Somwhere",
            state: "TX",
            zip_code: "12345"
          }
        }
      }

      path = Routes.order_path(conn, :create)
      resp = post(conn, path, params)

      assert resp.status == 200

      assert resp.params == %{
               shipping_method: "1_day_air",
               items: [
                 %{quantity: 7, item_id: "e1ff4243-90e9-47ed-9c63-d4d45dd14f9b"},
                 %{quantity: 3, item_id: "77cce0f1-fd48-4dba-9701-e6b06b1865b9"},
                 %{quantity: 5, item_id: "9dc4ca4e-c873-4e9f-9649-522e604e4a5e"}
               ],
               price: 145.99,
               addresses: %{
                 billing_address: %{
                   street_line_1: "99 Place Ave",
                   street_line_2: "Unit 2",
                   city: "Somewhere",
                   state: "TX",
                   zip_code: "12345"
                 },
                 shipping_address: %{
                   street_line_1: "99 Place Ave",
                   street_line_2: nil,
                   city: "Somwhere",
                   state: "TX",
                   zip_code: "12345"
                 }
               }
             }
    end

    test "should respond with a 422 when no parameters are passed in", %{conn: conn} do
      params = %{}
      path = Routes.order_path(conn, :create)
      resp = post(conn, path, params)

      assert resp.status == 422

      assert Jason.decode!(resp.resp_body) == %{
               "errors" => %{
                 "addresses" => ["can't be blank"],
                 "items" => ["can't be blank"],
                 "price" => ["can't be blank"],
                 "shipping_method" => ["can't be blank"]
               }
             }
    end

    test "should respond with a 422 when invalid addresses are passed in", %{conn: conn} do
      params = %{
        shipping_method: "1_day_air",
        items: [
          %{quantity: 7, item_id: "e1ff4243-90e9-47ed-9c63-d4d45dd14f9b"},
          %{quantity: 3, item_id: "77cce0f1-fd48-4dba-9701-e6b06b1865b9"},
          %{quantity: 5, item_id: "9dc4ca4e-c873-4e9f-9649-522e604e4a5e"}
        ],
        price: 145.99,
        addresses: %{
          billing_address: %{
            street_line_1: 111,
            street_line_2: 111,
            city: nil,
            state: "INVALID",
            zip_code: 12345
          },
          shipping_address: %{
            street_line_1: ["invalid", "street"],
            state: 11,
            zip_code: "123457890"
          }
        }
      }

      path = Routes.order_path(conn, :create)
      resp = post(conn, path, params)

      assert resp.status == 422

      assert Jason.decode!(resp.resp_body) == %{
               "errors" => %{
                 "addresses" => %{
                   "billing_address" => %{
                     "city" => ["can't be blank"],
                     "state" => ["is an invalid state abbreviation"],
                     "street_line_1" => ["is invalid"],
                     "street_line_2" => ["is invalid"],
                     "zip_code" => ["is invalid"]
                   },
                   "shipping_address" => %{
                     "city" => ["can't be blank"],
                     "state" => ["is invalid"],
                     "street_line_1" => ["is invalid"],
                     "zip_code" => ["has invalid format"]
                   }
                 }
               }
             }
    end

    test "should respond with a 422 when invalid items are passed in", %{conn: conn} do
      params = %{
        shipping_method: "1_day_air",
        items: [
          %{quantity: -1, item_id: 123},
          %{quantity: 0, item_id: nil},
          %{quantity: 1.5}
        ],
        price: 145.99,
        addresses: %{
          billing_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            city: "Somewhere",
            state: "TX",
            zip_code: "12345"
          },
          shipping_address: %{
            street_line_1: "99 Place Ave",
            city: "Somwhere",
            state: "TX",
            zip_code: "12345"
          }
        }
      }

      path = Routes.order_path(conn, :create)
      resp = post(conn, path, params)

      assert resp.status == 422

      assert Jason.decode!(resp.resp_body) == %{
               "errors" => %{
                 "items" => [
                   %{"item_id" => ["is invalid"], "quantity" => ["must be greater than 0"]},
                   %{"item_id" => ["can't be blank"], "quantity" => ["must be greater than 0"]},
                   %{"item_id" => ["can't be blank"], "quantity" => ["is invalid"]}
                 ]
               }
             }
    end

    test "should respond with a 422 when invalid price is passed in", %{conn: conn} do
      base_params = %{
        shipping_method: "1_day_air",
        items: [
          %{quantity: 7, item_id: "e1ff4243-90e9-47ed-9c63-d4d45dd14f9b"},
          %{quantity: 3, item_id: "77cce0f1-fd48-4dba-9701-e6b06b1865b9"},
          %{quantity: 5, item_id: "9dc4ca4e-c873-4e9f-9649-522e604e4a5e"}
        ],
        price: nil,
        addresses: %{
          billing_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            city: "Somewhere",
            state: "TX",
            zip_code: "12345"
          },
          shipping_address: %{
            street_line_1: "99 Place Ave",
            city: "Somwhere",
            state: "TX",
            zip_code: "12345"
          }
        }
      }

      param_tests = [
        {%{base_params | price: "-124.99"},
         %{"errors" => %{"price" => ["must be greater than or equal to 0"]}}},
        {%{base_params | price: -124.99},
         %{"errors" => %{"price" => ["must be greater than or equal to 0"]}}},
        {%{base_params | price: "asdf"}, %{"errors" => %{"price" => ["is invalid"]}}}
      ]

      Enum.each(param_tests, fn {params, expected_result} ->
        path = Routes.order_path(conn, :create)
        resp = post(conn, path, params)

        assert resp.status == 422
        assert Jason.decode!(resp.resp_body) == expected_result
      end)
    end
  end
end
