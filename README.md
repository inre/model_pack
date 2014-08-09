# Model Pack - model intefaces

Model Pack - набор интерфейсов, который позволяет создавать в объекте специальные аттрибуты.
Также добавляет методы работы model attributes. Прозволяет сериализировать иерахнию модельных
аттрибутов.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'model_pack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install model_pack

## Usage

```ruby
class Point
  include ModelPack::Document

  attribute :x
  attribute :y
end

class Line
  include ModelPack::Document

  object :begin, class_name: Point
  object :end, class_name: Point
end
```

## Contributing

1. Fork it ( https://github.com/chelovekov/model_pack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
