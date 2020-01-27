defmodule Tilex.Notifications.Notifiers.GoogleChat do
  @emoji ~w(
    :tada:
    :birthday:
    :sparkles:
    :boom:
    :hearts:
    :balloon:
    :crown:
    :mortar_board:
    :trophy:
    :100:
  )

  use Tilex.Notifications.Notifier

  def handle_post_created(post, developer, channel, url) do
    "#{developer.username} created a new post <#{url}|#{post.title}> ##{channel.name}"
    |> send_google_chat_message
  end

  def handle_post_liked(%Tilex.Post{max_likes: max_likes, title: title}, developer, url) do
    appropriate_emoji =
      @emoji
      |> Enum.at(round(max_likes / 10 - 1), ":smile:")

    "#{developer.username}'s post has #{max_likes} likes! #{appropriate_emoji} - <#{url}|#{title}>"
    |> send_google_chat_message
  end

  def handle_page_views_report(report) do
    report
    |> send_google_chat_message
  end

  defp send_google_chat_message(message) do
    endpoint =
      String.to_charlist(System.get_env("google_chat_post_endpoint"))

    :httpc.request(
      :post,
      {endpoint, [], 'application/json', "{\"text\": \"#{message}\"}"},
      [],
      []
    )
  end
end
