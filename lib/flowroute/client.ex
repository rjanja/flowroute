defmodule Flowroute.Client do
  @headers [
    {"Content-Type", "application/json"}
  ]

  def request(type, url, body, auth) do
    case HTTPoison.request(
           type,
           url,
           body,
           @headers,
           hackney: [basic_auth: auth]
         ) do
      {:ok, %HTTPoison.Response{body: response_body}} -> {:ok, response_body}
      {:error, _} -> :error
    end
  end
end
