defmodule Flowroute.Messaging do
  alias Flowroute.Client

  @api_url "https://api.flowroute.com/v2.1"

  def test_send(body) do
    send_sms(
      [from: "15416220100", to: "15416013426", body: body],
      {@temp_username, @temp_secret}
    )
  end

  def test_parse_sms() do
    [from: "15416220100", to: "15416013426", body: "hello moto"]
    |> parse_options(&sms_option/1)
  end

  def test_parse_mms() do
    [from: "15416220100", to: "15416013426", body: "hello moto", is_mms: true, hmm: "nope"]
    |> parse_options(&mms_option/1)
  end

  def parse_options(options, fun) when is_function(fun) do
    options
    |> Enum.filter(fun)
    |> Enum.into(%{})
  end

  defguard is_phone_number(v) when is_binary(v)
  defguard is_url(v) when is_binary(v)
  def sms_option({:to, v}) when is_phone_number(v), do: true
  def sms_option({:from, v}) when is_phone_number(v), do: true
  def sms_option({:body, v}) when is_binary(v), do: true
  def sms_option({:dlr_callback, v}) when is_url(v), do: true
  def sms_option({_k, _v}), do: false

  defguard is_url_list(v) when is_list(v)
  def mms_option({:to, v}) when is_phone_number(v), do: true
  def mms_option({:from, v}) when is_phone_number(v), do: true
  def mms_option({:body, v}) when is_binary(v), do: true
  def mms_option({:media_urls, v}) when is_url_list(v), do: true
  def mms_option({:is_mms, v}) when is_boolean(v), do: true
  def mms_option({_k, _v}), do: false

  def send_sms(options, auth) do
    with payload <- parse_options(options, &sms_option/1),
         {:ok, body} <- Poison.encode(payload),
         {:ok, response} <- Client.post("#{@api_url}/messages", body, auth),
         {:ok, decoded} <- Poison.decode(response) do
      decoded
    else
      e ->
        IO.puts("not what we wanted")
        IO.inspect(e)
    end
  end
end
