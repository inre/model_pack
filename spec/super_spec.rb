require "spec_helper"

describe ModelPack::Super do
  class Dummy < ModelPack::Super
    attribute :foo
    attribute :bar, default: "default"
  end

  class Child < Dummy
    attr_reader :args
    def initialize(args)
      @args = args
      super args
    end
  end

  describe ".initialize" do
    let(:args) { { foo: 1, bar: "2" } }

    let(:child) { Child.new(args) }

    it "runs child initializer before Super's initializer" do
      expect(child.args).to eq(args)
    end

    it "updates attributes as ModelPack do" do
      expect(child.foo).to eq(args[:foo])
      expect(child.bar).to eq(args[:bar])
    end

    context "non hash attributes" do
      let(:non_hash) { "ololo" }

      let(:child) { Child.new(non_hash) }

      it "calls childs initializer" do
        expect(child.args).to eq(non_hash)
      end

      it "has default values of attributes" do
        expect(child.bar).to eq("default")
      end
    end
  end
end