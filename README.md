# Inngest Ruby SDK


## Install

```
gem install inngest
```

## Usage

```ruby
require 'inngest'

client = Inngest::Client.new("your-key-here")
event = Inngest::Event.new(
  name: "user.signup",
  data: {
    "plan" => "free",
  },
  user: {
    "external_id" => "6ddd160c-fdde-11eb-9a03-0242ac130003",
    "email" => "eng@inngest.com"
  }
)

client.send event
```
Or, even simpler, without creating an `Inngest::Event`:

```ruby
client.send {
  name: "user.upgraded",
  data: {
    "plan" => "paid",
  }
}
```

