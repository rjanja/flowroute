# Flowroute

A wrapper around the [Flowroute](https://www.flowroute.com) telephony API v2.1, currently supporting the Messaging component.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `flowroute` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flowroute, "~> 0.1.0"}
  ]
end
```

## Configuration
Set your Flowroute API credentials in your `config.exs`:

```elixir
config :flowroute,
  access_key: System.get_env("FLOWROUTE_ACCESS_KEY"),
  secret_key: System.get_env("FLOWROUTE_SECRET_KEY")
```

## Usage

`send/5` can be used to strip any invalid data keys depending on the type of message.

`send(type, from, to, payload \\ [], options \\ [])`

`send/4` can be used to send arbitrary data keys.

`def send(from, to, payload \\ [], options \\ [])`

The `from` and `to` phone numbers are required by Flowroute to be in [E.164](http://en.wikipedia.org/wiki/E.164) format, but no validation is done by this library. See [ex_phone_number](https://github.com/socialpaymentsbv/ex_phone_number) if you are looking for E.164 validation.

### Sending an SMS

```elixir
iex> Flowroute.Message.send(:sms, "15551230000", "15551234444", body: "Hello there!")
{:ok,
 %{
   "data" => %{
     "id" => "mdr2-f3ce388895a711e89295768a2c7516d2",
     "links" => %{
       "self" => "https://api.flowroute.com/v2.1/messages/mdr2-f3ce388895a711e89295768a2cffffff"
     },
     "type" => "message"
   }
 }}
```

### Sending an MMS

```elixir
Flowroute.Message.send(:mms, "15551230000", "15551234444",
 body: "Enjoy this donut",
 media_urls: ["https://upload.wikimedia.org/wikipedia/commons/b/bb/Donut_879.png"])
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/flowroute](https://hexdocs.pm/flowroute).

