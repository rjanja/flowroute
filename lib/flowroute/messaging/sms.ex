defmodule Flowroute.API.SMS do
  def send() do
    hackney = [basic_auth: {"25918417", "0235992c6d35854bddc4a3992c7969ee"}]

    body =
      Poison.encode!(%{
        to: "15416013426",
        from: "18449762378",
        body: "hello moto!"
      })

    HTTPoison.post(
      "https://api.flowroute.com/v2.1/messages",
      body,
      [
        {"Content-Type", "application/json"}
      ],
      hackney: hackney
    )
  end

  @api_url "https://api.flowroute.com/v2.1"

  def send(%{from: sender, to: recipient, body: body}) do
    headers = [
      {"Content-Type", "application/json"}
    ]

    options = [basic_auth: {"25918417", "0235992c6d35854bddc4a3992c7969ee"}]

    with {:ok, body} <- Poison.encode(%{to: recipient, from: sender, body: body}),
         {:ok, %HTTPoison.Response{body: response_body}} <-
           HTTPoison.post("#{@api_url}/messages", body, headers, hackney: options),
         {:ok, result} <- Poison.decode(response_body) do
      result
    else
      _ = e ->
        e
    end
  end
end
