defmodule Flowroute.Message do
  alias Flowroute.Client

  @api_url "https://api.flowroute.com/v2.1"

  def send(type, from, to, payload, options \\ [])

  def send(type, from, to, payload, options)
      when is_atom(type)
      when type in [:sms, :mms]
      when is_binary(from)
      when is_binary(to)
      when is_list(payload)
      when is_list(options) do
    payload
    |> Kernel.++(from: from, to: to)
    |> limit_payload(type)
    |> post("messages", options)
  end

  def send(_, _, _, _, _) do
    raise "Argument error"
  end

  def send!(from, to, payload, options \\ [])

  def send!(from, to, payload, options)
      when is_binary(from)
      when is_binary(to)
      when is_list(payload)
      when is_list(options) do
    payload
    |> Kernel.++(from: from, to: to)
    |> post("messages", options)
    |> elem(1)
  end

  def mdr(message_id) do
    get("messages/#{message_id}")
  end

  def mdr!(message_id) do
    with {:ok, result} <- mdr(message_id) do
      result
    end
  end

  def mdr_list(start_date, options \\ []) do
    [
      limit: Keyword.get(options, :limit),
      offset: Keyword.get(options, :offset),
      end_date: Keyword.get(options, :end_date)
    ]
    |> Keyword.put(:start_date, start_date)
    |> Enum.filter(fn {_, v} -> !is_nil(v) end)
    |> URI.encode_query()
    |> (fn query -> "messages/?" <> query end).()
    |> get()
  end

  def mdr_list!(start_date, options \\ []) do
    with {:ok, %{"data" => messages}} <- mdr_list(start_date, options) do
      messages
    end
  end

  def tally_cost(messages) when is_list(messages) do
    messages
    |> Enum.map(&get_in(&1, ["attributes", "amount_nanodollars"]))
    |> Enum.sum()
    |> Kernel.*(0.000000001)
  end

  @spec post([{atom(), any}], String.t(), list()) :: tuple()
  def post(data, uri, options \\ []) do
    with payload <- Enum.into(data, %{}),
         {:ok, body} <- Jason.encode(payload),
         {:ok, response} <-
           Client.request(:post, api_url(uri, options), body, hackney_auth(options)),
         {:ok, decoded} <- Jason.decode(response) do
      {:ok, decoded}
    else
      e -> {:error, e}
    end
  end

  @spec get(String.t(), list()) :: tuple()
  def get(uri, options \\ []) do
    with {:ok, response} <- Client.request(:get, api_url(uri, options), "", hackney_auth(options)),
         {:ok, decoded} <- Jason.decode(response) do
      {:ok, decoded}
    else
      e -> {:error, e}
    end
  end

  defguardp is_phone_number(v) when is_binary(v)
  defguardp is_url(v) when is_binary(v)
  defp sms_option({:to, v}) when is_phone_number(v), do: true
  defp sms_option({:from, v}) when is_phone_number(v), do: true
  defp sms_option({:body, v}) when is_binary(v), do: true
  defp sms_option({:dlr_callback, v}) when is_url(v), do: true
  defp sms_option({_k, _v}), do: false

  defguardp is_url_list(v) when is_list(v)
  defp mms_option({:to, v}) when is_phone_number(v), do: true
  defp mms_option({:from, v}) when is_phone_number(v), do: true
  defp mms_option({:body, v}) when is_binary(v), do: true
  defp mms_option({:media_urls, v}) when is_url_list(v), do: true
  defp mms_option({:is_mms, v}) when is_boolean(v), do: true
  defp mms_option({_k, _v}), do: false

  defp limit_payload(payload, :sms) do
    Enum.filter(payload, &sms_option/1)
  end

  defp limit_payload(payload, :mms) do
    Enum.filter(payload, &mms_option/1)
  end

  defp api_url(uri, options) do
    options
    |> Keyword.get(:api_url, Application.get_env(:flowroute, :api_url, @api_url))
    |> Kernel.<>("/#{uri}")
  end

  defp hackney_auth(options) do
    {
      Keyword.get(options, :access_key, Application.get_env(:flowroute, :access_key)),
      Keyword.get(options, :secret_key, Application.get_env(:flowroute, :secret_key))
    }
  end
end
