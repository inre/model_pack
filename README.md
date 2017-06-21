# Model Pack - model interfaces

Model Pack - набор интерфейсов, который позволяет создавать специальные атрибуты в объекте.
Также добавляет методы работы model attributes. Позволяет сериализовывать атрибуты модели, сохраняя их правильную иерархию.

Model Pack is an interfaces collection for creating object's attributes. It also adds methods for working with this attributes and allows to safely serialize your model without loosing their hierarchical structure.

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

### Атрибуты и вложенные объекты

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

Создаем экземпляры модели:

```ruby
point = Point.new(x: 3, y: 5)
line = Line.new(
	from: { x: 1, y: 1 },
	to: { x: 3, y: 5}
)
puts line.length
```

### Перекрываем запись атрибутов

```ruby
class Text
  attribute :always_string, writer: ->(v) { v.to_s }
end

text = Text.new(always_string: 123)
puts text.always_string # "123"
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
	attribute :hidden_field, serialize: lambda { |v| nil }
	attribute :const_field, serialize: lambda { |v| :always_this }
	attribute :always_string, serialize: lambda { |v| v.to_s }
end
secure_data = SecureData.new( hidden_field: "secured text", const_field: :some_value, always_string: 55)
unsecure_hash = secure_data.serializable_hash
puts unsecure_hash
```

### Наследование
Для того чтобы использовать всю мощь ModelPack, но при этом не переопределять конструкор через `ModelPack::Constructor`
существует класс `ModelPack::Super`, от которого можно наследоваться. Однако в этом случае необходимо явно передавать в
`super` аргументы, которые вы хотите установить в модель
```ruby
class MyClass < ModelPack::Super
  attribute :foo
  attribute :bar, default: "default value"
  
  def initialize(args)
    # do some work with args, may be collect from it foo and bar values
    my_foo_bar_values = some_work_with_args(args)
    super(my_foo_bar_values)
  end
end

```
## Contributing

1. Fork it ( https://github.com/inre/model_pack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
