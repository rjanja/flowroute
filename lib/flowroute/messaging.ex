defmodule Flowroute.Messaging do
  alias Flowroute.Client

  @api_url "https://api.flowroute.com/v2.1"

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

  def send(type, from, to, options \\ [], auth \\ [])

  def send(type, from, to, options, auth)
      when is_atom(type)
      when type in [:sms, :mms]
      when is_binary(from)
      when is_binary(to) do
    options
    |> Kernel.++(from: from, to: to)
    |> raw(type, auth)
  end

  def send(_, _, _, _, _) do
    raise "Argument error"
  end

  def send(from, to, options \\ [], auth \\ [])

  def send(from, to, options, auth)
      when is_binary(from)
      when is_binary(to) do
    options
    |> Kernel.++(from: from, to: to)
    |> raw(:any, auth)
  end

  @spec raw([{atom(), any}], atom(), list()) :: tuple()
  def raw(data, message_type, auth \\ []) do
    auth_user = Keyword.get(auth, :access_key, Application.get_env(:flowroute, :access_key))
    auth_pass = Keyword.get(auth, :secret_key, Application.get_env(:flowroute, :secret_key))

    data_fun =
      case message_type do
        :sms -> &sms_option/1
        :mms -> &mms_option/1
        :any -> fn _ -> true end
      end

    with payload <- format_request_data(data, data_fun),
         {:ok, body} <- Poison.encode(payload),
         {:ok, response} <- Client.post("#{@api_url}/messages", body, {auth_user, auth_pass}),
         {:ok, decoded} <- Poison.decode(response) do
      {:ok, decoded}
    else
      e ->
        IO.puts("not what we wanted")
        IO.inspect(e)
    end
  end
end
