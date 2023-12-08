defmodule Mastery.Core.ResponseTest do
  use ExUnit.Case
  use QuizBuilders

  describe "a right response and a wrong response" do
    setup [:right, :wrong]

    test "building responses checks answers", %{right: right, wrong: wrong} do
      assert right.correct
      refute wrong.correct
    end

    test "a timestamp is added at build time", %{right: response} do
      assert %DateTime{} = response.timestamp
      assert response.timestamp < DateTime.utc_now()
    end
  end

  defp quiz do
    fields = template_fields(generators: %{left: [1], right: [2]})

    build_quiz()
    |> Quiz.add_template(fields)
    |> Quiz.select_question()
  end

  defp response(answer) do
    Response.new(quiz(), "mathy@example.com", answer)
  end

  defp right(ctx) do
    Map.put(ctx, :right, response("3"))
  end

  defp wrong(ctx) do
    Map.put(ctx, :wrong, response("2"))
  end
end
