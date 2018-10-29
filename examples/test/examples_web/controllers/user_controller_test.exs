defmodule ExamplesWeb.UserControllerTest do
  use ExamplesWeb.ConnCase

  describe "create" do
    test "should respond with a 200 when valid params are passed in", %{conn: conn} do
      params = %{
        age: 25,
        type: "super_admin",
        password: "1234567890",
        password_confirmation: "1234567890",
        terms_conditions: true,
        interests: ["technology", "art"],
        favorite_programming_language: "Javascript",
        addresses: %{
          billing_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            zip_code: "12345",
            coordinates: %{
              lat: 14.5,
              long: 20
            }
          },
          shipping_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            zip_code: "12345",
            coordinates: %{
              lat: 14.5,
              long: 20
            }
          }
        }
      }

      path = Routes.user_path(conn, :create)
      resp = post(conn, path, params)

      assert resp.status == 200
      assert Jason.decode!(resp.resp_body) == %{}
    end

    test "should respond with a 422 when no parameters are passed in", %{conn: conn} do
      params = %{}
      path = Routes.user_path(conn, :create)
      resp = post(conn, path, params)

      assert resp.status == 422

      assert Jason.decode!(resp.resp_body) == %{
               "errors" => %{
                 "addresses" => ["can't be blank"],
                 "age" => ["can't be blank"],
                 "password" => ["can't be blank"],
                 "password_confirmation" => ["can't be blank"],
                 "terms_conditions" => ["must be accepted", "can't be blank"],
                 "type" => ["can't be blank"]
               }
             }
    end

    test "should respond with a 422 when invalid addresses are passed in", %{conn: conn} do
      base_params = %{
        age: 25,
        type: "super_admin",
        password: "1234567890",
        password_confirmation: "1234567890",
        terms_conditions: true,
        interests: ["technology", "art"],
        favorite_programming_language: "Javascript",
        addresses: %{
          billing_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            zip_code: "12345",
            coordinates: %{
              lat: 14.5,
              long: 20
            }
          },
          shipping_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            zip_code: "12345",
            coordinates: %{
              lat: 14.5,
              long: 20
            }
          }
        }
      }

      params = [
        {put_in(base_params, [:addresses, :billing_address, :coordinates, :lat], -1000),
         %{
           "errors" => %{
             "addresses" => %{
               "billing_address" => %{
                 "coordinates" => %{"lat" => ["must be greater than or equal to -90"]}
               }
             }
           }
         }},
        {put_in(base_params, [:addresses, :billing_address, :zip_code], "INVALID"),
         %{
           "errors" => %{
             "addresses" => %{"billing_address" => %{"zip_code" => ["has invalid format"]}}
           }
         }},
        {put_in(base_params, [:addresses, :billing_address, :coordinates], nil),
         %{
           "errors" => %{
             "addresses" => %{"billing_address" => %{"coordinates" => ["can't be blank"]}}
           }
         }}
      ]

      Enum.each(params, fn {params, expected_result} ->
        path = Routes.user_path(conn, :create)
        resp = post(conn, path, params)

        assert resp.status == 422
        assert Jason.decode!(resp.resp_body) == expected_result
      end)
    end

    test "should respond with a 422 when invalid fields are passed in", %{
      conn: conn
    } do
      base_params = %{
        age: 25,
        type: "super_admin",
        password: "1234567890",
        password_confirmation: "1234567890",
        terms_conditions: true,
        interests: ["technology", "art"],
        favorite_programming_language: "Javascript",
        addresses: %{
          billing_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            zip_code: "12345",
            coordinates: %{
              lat: 14.5,
              long: 20
            }
          },
          shipping_address: %{
            street_line_1: "99 Place Ave",
            street_line_2: "Unit 2",
            zip_code: "12345",
            coordinates: %{
              lat: 14.5,
              long: 20
            }
          }
        }
      }

      params = [
        {%{base_params | favorite_programming_language: "Java"},
         %{"errors" => %{"favorite_programming_language" => ["is reserved"]}}},
        {%{base_params | favorite_programming_language: ["Java", "PHP"]},
         %{"errors" => %{"favorite_programming_language" => ["is invalid"]}}},
        {%{base_params | interests: ["art", "music", "technology"]},
         %{"errors" => %{"interests" => ["should have at most 2 item(s)"]}}},
        {%{base_params | interests: ["something", "nothing"]},
         %{"errors" => %{"interests" => ["has an invalid entry"]}}},
        {%{base_params | password_confirmation: "asdf"},
         %{"errors" => %{"password_confirmation" => ["does not match confirmation"]}}},
        {%{base_params | terms_conditions: false},
         %{"errors" => %{"terms_conditions" => ["must be accepted"]}}}
      ]

      Enum.each(params, fn {params, expected_result} ->
        path = Routes.user_path(conn, :create)
        resp = post(conn, path, params)

        assert resp.status == 422
        assert Jason.decode!(resp.resp_body) == expected_result
      end)
    end
  end
end
