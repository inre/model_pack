require "spec_helper"

describe ModelPack::ClassMethods do

  it "should create model with default fields" do
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

  it "should create model and fill it thought initialization" do
    point = Point.new(x: 3, y: 5)
    expect(point.x).to be(3)
    expect(point.y).to be(5)
    expect(point.attributes).to include({x: 3, y: 5})
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

    line = Line.new({
        from: { x: 1, y: 1 },
        to: { x: 3, y: 5}
    })
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

  it "should serialize model with custom serializer" do
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

  it "should serialize and load back model" do
    polygon = Polygon.new(points: [{x: 3, y: 3}, {x:2, y:1}, {x:4, y:2}])
    polygon_copy = Polygon.new(polygon.serializable_hash) # or as_json
    expect(polygon_copy.points).to be_a(Array)
    polygon.points.each_with_index do |point, index|
      expect(polygon_copy.points[index].attributes).to include(point.attributes)
    end
  end

  it "should create copy of model" do
    polygon = Polygon.new(points: [{x: 3, y: 3}, {x:2, y:1}, {x:4, y:2}])
    polygon_copy = polygon.copy
    polygon.points.each_with_index do |point, index|
      expect(polygon_copy.points[index].attributes).to include(point.attributes)
    end
  end

  it "should model have hashable field" do
    class Options
      include ModelPack::Document

      hashable :options

      def method_missing(name, *a)
        options[name]
      end
    end

    options = Options.new(options: { a: 5, b: 6 })

    expect(options.a).to be(5)
    expect(options.b).to be(6)
  end

  it "should serialize model with custom serializer" do

  end

end
