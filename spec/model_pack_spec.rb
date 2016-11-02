require "spec_helper"

describe ModelPack::ClassMethods do

  it "should create model with defaults" do
    class Point
      include ModelPack::Document

      attribute :x, default: 0
      attribute :y, default: 0
    end

    point = Point.new
    expect(point.x).to be(0)
    expect(point.y).to be(0)
    expect(point.attributes).to include({x: 0, y: 0})
  end

  it "should create filled model" do
    point = Point.new(x: 3, y: 5)
    expect(point.x).to be(3)
    expect(point.y).to be(5)
    expect(point.attributes).to include({x: 3, y: 5})
  end

  it "should change attributes" do
    point = Point.new(x: 4, y: 6)
    point.update_attributes(x:3, y:2)
    expect(point.x).to be(3)
    expect(point.y).to be(2)
  end

  it "should create embedded models" do
    class Line
      include ModelPack::Document

      object :from, class_name: Point
      object :to, class_name: Point

      def length
         Math.sqrt((from.x-to.x)**2 + (from.y-to.y)**2)
      end
    end

    line = Line.new(
        from: { x: 1, y: 1 },
        to: { x: 3, y: 5}
    )
    expect(line.from).to be_a(Point)
    expect(line.to).to be_a(Point)
    expect(line.from.attributes).to include({x: 1, y: 1})
    expect(line.to.attributes).to include({x: 3, y: 5})
    expect(line.length).to be_within(0.1).of(4.4)
  end

  it "should create array of models" do
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
    expect(polygon.perimeter).to be_within(0.1).of(17.0)
  end

  it "should serialize model to hash" do
    polygon = Polygon.new(points: [{x: 0, y: 0}, {x:5, y:0}, {x:5, y:5}])
    json = polygon.as_json()
    expect(json).to include(:points)
    expect(json[:points]).to be_a(Array)
    expect(json[:points][0]).to include({x: 0, y:0})
    expect(json[:points][1]).to include({x: 5, y:0})
    expect(json[:points][2]).to include({x: 5, y:5})
  end

  it "should use each attribute like writer" do
    class SecureData
      include ModelPack::Document

      attribute :hidden_field, writer: lambda { |v| nil }
      attribute :const_field, writer: lambda { |v| :always_this }
      attribute :always_string, writer: lambda { |v| v.to_s }
    end

    secure_data = SecureData.new( hidden_field: "secured text", const_field: :some_value, always_string: 55)
    unsecure_hash = secure_data.serializable_hash
    expect(unsecure_hash).not_to include(:hidden_field)
    expect(unsecure_hash).to include(const_field: :always_this)
    expect(unsecure_hash).to include(always_string: "55")
  end

  it "should serialize with custom serializers" do
    class SecureDataSerialized
      include ModelPack::Document

      attribute :hidden_field, serialize: lambda { |v| nil }
      attribute :const_field, serialize: lambda { |v| :always_this }
      attribute :always_string, serialize: lambda { |v| v.to_s }
    end

    secure_data = SecureDataSerialized.new( hidden_field: "secured text", const_field: :some_value, always_string: 55)
    unsecure_hash = secure_data.serializable_hash
    expect(unsecure_hash).not_to include(:hidden_field)
    expect(unsecure_hash).to include(const_field: :always_this)
    expect(unsecure_hash).to include(always_string: "55")
  end

  it "should not allow method with name `method`" do
    expect {
      class Request
        include ModelPack::Document

        attribute :method, default: "get"
      end
    }.to raise_error
  end

  it "should serialize and upload model" do
    polygon = Polygon.new(points: [{x: 3, y: 3}, {x:2, y:1}, {x:4, y:2}])
    polygon_copy = Polygon.new(polygon.serializable_hash) # or as_json
    expect(polygon_copy.points).to be_a(Array)
    polygon.points.each_with_index do |point, index|
      expect(polygon_copy.points[index].attributes).to include(point.attributes)
    end
  end

  it "should copy model" do
    polygon = Polygon.new(points: [{x: 3, y: 3}, {x:2, y:1}, {x:4, y:2}])
    polygon_copy = polygon.copy
    polygon.points.each_with_index do |point, index|
      expect(polygon_copy.points[index].attributes).to include(point.attributes)
    end
  end

  it "should have nary field" do
    class Options
      include ModelPack::Document

      dictionary :options
      dictionary :points, class_name: Point

      def method_missing(name, *a)
        options[name]
      end
    end

    options = Options.new(
      options: { a: 5, b: 6 },
      points: {
        "a" => {x:0, y:1},
        "b" => {x:1, y:3},
        "c" => {x:3, y:2}
      }
    )

    expect(options.a).to be(5)
    expect(options.b).to be(6)
    expect(options.points['a'].x).to be(0)
    expect(options.points['b'].y).to be(3)
    expect(options.points['c'].y).to be(2)
  end

  it "should initizalize with string attributes" do
    point = Point.new({"x" => 3, "y" => 5})
    expect(point.x).to be(3)
    expect(point.y).to be(5)
    expect(point.attributes).to include({x: 3, y: 5})
  end

  it "should serialize model with custom serializer" do
    class IntData
      include ModelPack::Document
      attribute :integer, serialize: lambda { |v| 5 }
    end

    int_data = IntData.new(integer: 13)
    expect(int_data.serializable_hash[:integer]).to be(5)
  end

  it "should have initialize" do
    class StringBuffer
      include ModelPack::Document

      attribute :buffer, default: ''
      attribute :position

      def initialize
        @position = buffer.size
      end
    end

    buffer = StringBuffer.new(buffer: 'Lorem Ipsum')
    expect(buffer.position).to be(11)
  end

  it "should have predicate method" do
    class OptionsWithPredicate
      include ModelPack::Document

      attribute :save, predicate: true
      attribute :load, predicate: lambda { |v| !!v ? 'YES' : 'NO'  }
    end

    owp = OptionsWithPredicate.new(
      save: true,
      load: true
    )
    expect(owp.save?).to be true
    expect(owp.load?).to eq('YES')

    owp = OptionsWithPredicate.new(
      save: false,
      load: false
    )
    expect(owp.save?).to be false
    expect(owp.load?).to eq('NO')

    owp = OptionsWithPredicate.new

    expect(owp.save?).to be false
    expect(owp.load?).to eq('NO')
  end

  it "should boolean type to work too" do
    class BooleanData
      include ModelPack::Document

      attribute :bit
    end

    true_data = BooleanData.new(bit: true)
    false_data = BooleanData.new(bit: false)
    copy_true_data = true_data.copy
    copy_false_data = false_data.copy

    expect(true_data.serializable_hash[:bit]).to be true
    expect(false_data.serializable_hash[:bit]).to be false
    expect(copy_true_data.serializable_hash[:bit]).to be true
    expect(copy_false_data.serializable_hash[:bit]).to be false
  end

  it "should create unique array for each of instance" do
    class ArrayData
      include ModelPack::Document

      array :data
    end

    array1 = ArrayData.new
    array1.data << 1
    array2 = ArrayData.new
    expect(array1.data.size).to be 1
    expect(array2.data.size).to be 0
  end

  it "supports boolean as default values" do
    class BooleanData
      include ModelPack::Document

      attribute :always_false, default: false
      attribute :always_true,  default: true
      attribute :dynamic_default, default: lambda { 1+5 }
    end

    data = BooleanData.new

    expect(data.always_false).to be false
    expect(data.always_true).to be true
    expect(data.dynamic_default).to be 6
  end

  it "has a class in the model" do
    class NestedObject
      include ModelPack::Document
      attribute :a, default: 5
    end

    class ParentObject
      include ModelPack::Document
      object :nested, class_name: NestedObject, as: NestedObject
      attribute :b, default: 1
    end

    parent = ParentObject.new
    expect(parent.nested.a).to be 5
  end

  it "inherits another document" do
    class BaseDocument
      include ModelPack::Document
      attribute :param, default: 'val'
    end

    class CustomDocument < BaseDocument
      include ModelPack::Document
      attribute :first, default: 'foo'
    end

    class AnotherDocument < BaseDocument
      include ModelPack::Document
      attribute :second, default: 'bar'
    end

    expect(BaseDocument.new.attributes).to eq(param: 'val');
    expect(CustomDocument.new.attributes).to eq(param: 'val', first: 'foo');
    expect(AnotherDocument.new.attributes).to eq(param: 'val', second: 'bar');
  end
end
