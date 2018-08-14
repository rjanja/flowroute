defmodule Flowroute.Client do
  def request(type, url, body, auth) do
    case HTTPoison.request(
           type,
           url,
           body,
           {"Content-Type", "application/json"},
           hackney: [basic_auth: auth]
         ) do
      {:ok, %HTTPoison.Response{body: response_body}} -> {:ok, response_body}
      {:error, _} -> :error
    end
  end
end
