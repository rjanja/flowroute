defmodule Flowroute.Messaging do
  alias Flowroute.Client

  @api_url "https://api.flowroute.com/v2.1"

  def test_sms(body) do
    sms(
      [from: @my_voip, to: @my_cell, body: body],
      {@temp_username, @temp_secret}
    )
  end

  def test_mms(body) do
    mms(
      [
        from: @my_voip,
        to: @my_cell,
        body: body,
        media_urls: [
          "https://co0069yjui-flywheel.netdna-ssl.com/wp-content/uploads/2017/04/Gopher-1-e1493176782243.png"
        ]
      ],
      {@temp_username, @temp_secret}
    )
  end

  def test_parse_sms() do
    [from: @my_voip, to: @my_cell, body: "hello moto"]
    |> format_request_data(&sms_option/1)
  end

  def test_parse_mms() do
    [from: @my_voip, to: @my_cell, body: "hello moto", is_mms: true, hmm: "nope"]
    |> format_request_data(&mms_option/1)
  end

  @spec format_request_data([{atom(), any}], function()) :: map()
  def format_request_data(data, fun)
      when is_list(data)
      when is_function(fun) do
    data
    |> Enum.filter(fun)
    |> Enum.into(%{})
  end

  def format_request_data(_, _), do: %{}

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

  @spec sms([{atom(), any}], {String.t(), String.t()}) :: tuple()
  def sms(data, auth) do
    send("#{@api_url}/messages", data, &sms_option/1, auth)
  end

  @spec mms([{atom(), any}], {String.t(), String.t()}) :: tuple()
  def mms(data, auth) do
    send("#{@api_url}/messages", data, &mms_option/1, auth)
  end

  @spec send(String.t(), [{atom(), any}], function(), {String.t(), String.t()}) :: tuple()
  def send(url, data, data_fun, auth) do
    with payload <- format_request_data(data, data_fun),
         {:ok, body} <- Poison.encode(payload),
         {:ok, response} <- Client.post(url, body, auth),
         {:ok, decoded} <- Poison.decode(response) do
      {:ok, decoded}
    else
      e ->
        IO.puts("not what we wanted")
        IO.inspect(e)
    end
  end
end
