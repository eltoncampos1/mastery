defmodule Mastery.Core.QuizTest do
  use ExUnit.Case
  use QuizBuilders

  describe "when a quiz has two templates" do
    setup [:quiz]

    test "the nex question is randomly selected", %{quiz: q} do
      %{current_question: %{template: first_template}} = Quiz.select_question(q)

      other_template = eventualli_pick_other_template(q, first_template)
      assert first_template != other_template
    end

    test "templates are unique cycle repeats", %{quiz: q} do
      first_quiz = Quiz.select_question(q)
      second_quiz = Quiz.select_question(first_quiz)
      reset_quiz = Quiz.select_question(second_quiz)

      assert template(first_quiz) != template(second_quiz)
      assert template(reset_quiz) in [template(first_quiz), template(second_quiz)]
    end
  end

  describe "a quiz that always adds one and two" do
    setup [:quiz_always_adds_one_and_two]

    test "a wrong answer resets mastery", %{quiz: q} do
      q
      |> Quiz.select_question()
      |> assert_more_questions
      |> right_answer
      |> Quiz.select_question()
      |> assert_more_questions
      |> wrong_answer
      |> Quiz.select_question()
      |> assert_more_questions
      |> right_answer
      |> Quiz.select_question()
      |> assert_more_questions
      |> right_answer
      |> Quiz.select_question()
      |> refute_more_questions
    end
  end

  defp eventualli_pick_other_template(quiz, template) do
    Stream.repeatedly(fn ->
      Quiz.select_question(quiz).current_question.template
    end)
    |> Enum.find(&(&1 != template))
  end

  defp template(quiz) do
    quiz.current_question.template
  end

  defp right_answer(quiz), do: answer_question(quiz, "3")
  defp wrong_answer(quiz), do: answer_question(quiz, "wrong")

  defp answer_question(quiz, answer) do
    email = "mathy@example.com"
    response = Response.new(quiz, email, answer)
    Quiz.answer_question(quiz, response)
  end

  defp quiz(ctx) do
    Map.put(ctx, :quiz, build_quiz_with_two_templates())
  end

  defp quiz_always_adds_one_and_two(ctx) do
    fields = template_fields(generators: addition_generators([1], [2]))

    quiz =
      build_quiz(mastery: 2)
      |> Quiz.add_template(fields)

    Map.put(ctx, :quiz, quiz)
  end

  defp assert_more_questions(quiz) do
    refute is_nil(quiz)
    quiz
  end

  defp refute_more_questions(quiz) do
    assert is_nil(quiz)
    quiz
  end
end
