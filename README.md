# Flowroute

A wrapper for the [Flowroute](https://www.flowroute.com) telephony API, currently supporting the Messaging v2.1 component.

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

`send(:sms, from, to, payload \\ [], options \\ [])`

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

### Retrieving a Message Delivery Receipt (MDR)

```elixir
iex(2)> Flowroute.Message.mdr("mdr2-f3ce388895a711e89295768a2c7516d2")
{:ok,
 %{
   "data" => %{
     "attributes" => %{
       "delivery_receipts" => [],
       "status" => "mmsc submit",
       ...
     },
     "id" => "mdr2-f3ce388895a711e89295768a2c7516d2",
     ...
   },
   ...
 }}
```

### Retreiving a list of MDRs within a date range

```elixir
iex(3)> Flowroute.Message.mdr_list("2018-08-01", limit: 2, end_date: "2018-08-31")
{:ok,
 %{
   "data" => [
     %{
       "attributes" => %{
         "amount_display" => "$0.0040",
         "amount_nanodollars" => 4000000,
         "body" => "This is a test of the yoyoyo system!",
         "delivery_receipts" => [
           ...
         ]
       },
       ...
    },
    %{
      "attributes" => %{
      "amount_display" => "$0.0040",
         "amount_nanodollars" => 4000000,
         "body" => "This is a test of the yoyoyo system!",
         "delivery_receipts" => [
           ...
         ]
       },
       ...
    }
  ]
}}
```

### Tallying costs of messages

```elixir
iex(4)> Flowroute.Message.mdr_list!("2018-08-01", limit: 1) |> Flowroute.Message.tally_cost()
0.004
iex(5)> Flowroute.Message.mdr_list!("2018-08-01") |> Flowroute.Message.tally_cost()
0.057
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/flowroute](https://hexdocs.pm/flowroute).

