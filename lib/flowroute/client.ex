defmodule Flowroute.Client do
  @headers [
    {"Content-Type", "application/json"}
  ]

  def post(url, body, {username, secret}) do
    case HTTPoison.post(
           url,
           body,
           @headers,
           hackney: [basic_auth: {username, secret}]
         ) do
      {:ok, %HTTPoison.Response{body: response_body}} -> {:ok, response_body}
      {:error, _} -> :error
    end
  end
end
