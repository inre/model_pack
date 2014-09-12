# Model Pack - model interfaces

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

## Использование

### Атрибуты и вложеные объекты

```ruby
class Point
  include ModelPack::Document

  attribute :x
  attribute :y
end

class Line
  include ModelPack::Document

  object :from, class_name: Point
  object :to, class_name: Point

  def length
     Math.sqrt((from.x-to.x)**2 + (from.y-to.y)**2)
  end
end
```

Создаем эксземпляры модели:

```ruby
point = Point.new(x: 3, y: 5)
line = Line.new(
	from: { x: 1, y: 1 },
	to: { x: 3, y: 5}
)
puts line.length
```

### Массив моделей

```ruby
class Polygon
	include ModelPack::Document

	array :points, class_name: Point

	def sides
		return [] if points.size < 2
		[[points.first]].tap do |sides|
			(1...(points.size)).to_a.each do |index|
				sides.last.push points[index]
				sides.push [points[index]]
      			end
      			sides.last.push(points.first)
    		end
 	end

	def perimeter
		sides.inject(0) { |sum, side| sum + Math.sqrt((side[0].x-side[1].x)**2 + (side[0].y-side[1].y)**2) }
	end
end
polygon = Polygon.new(points: [{x: 0, y: 0}, {x:5, y:0}, {x:5, y:5}])
puts polygon.perimeter
```

### Сериализация моделей

```ruby
polygon = Polygon.new(points: [{x: 0, y: 0}, {x:5, y:0}, {x:5, y:5}])
json = polygon.as_json     # same serializable_hash
```

### Копирование моделей

```ruby
polygon = Polygon.new(points: [{x: 3, y: 3}, {x:2, y:1}, {x:4, y:2}])
polygon_copy = polygon.copy   # same polygon_copy = Polygon.new(polygon.serializable_hash)
puts polygon_copy.serializable_hash
```

### Выборочная сериализация

```ruby
class SecureData
	include ModelPack::Document
	attribute :hidden_field, writer: lambda { |v| nil }
	attribute :const_field, writer: lambda { |v| :always_this }
	attribute :always_string, writer: lambda { |v| v.to_s }
end
secure_data = SecureData.new( hidden_field: "secured text", const_field: :some_value, always_string: 55)
unsecure_hash = secure_data.serializable_hash
puts unsecure_hash
```

## Contributing

1. Fork it ( https://github.com/chelovekov/model_pack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
