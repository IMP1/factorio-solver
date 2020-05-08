require_relative 'data_loader'
require_relative 'graphs'

module FactorioCalculator

    class Throughput

        attr_reader :item
        attr_reader :amount_per_second

        def initialize(item, amount_per_second)
            @item = item
            @amount_per_second = amount_per_second
        end

        def +(t)
            raise TypeError.new("no implicit conversion of #{t.class} into #{self.class}") unless t.is_a?(Throughput)
            raise TypeError.new("no implicit conversion of #{t.item} into #{self.item}") unless t.item == item
            new_amount_per_second = amount_per_second + t.amount_per_second
            return Throughput.new(item, new_amount_per_second)
        end

        def to_s
            return "<#{amount_per_second} #{item} / s>"
        end

    end

    class Crafter

        attr_reader :item
        attr_reader :count
        attr_reader :inputs
        attr_reader :amount_per_second_per_craft

        def initialize(item, amount_per_second_per_craft, inputs, count=1)
            @item = item
            @amount_per_second_per_craft = amount_per_second_per_craft
            @inputs = inputs
            @count = count
        end

        def amount_per_second
            return @amount_per_second_per_craft * @count
        end

        def +(c)
            raise TypeError.new("no implicit conversion of #{c.class} into #{self.class}") unless c.is_a?(Crafter)
            raise TypeError.new("no implicit conversion of #{c.item} into #{self.item}") unless c.item == item
            new_count = count + c.count
            new_inputs = (inputs + c.inputs).group_by { |i| i.item }.map { |item, group| group.inject(:+) }
            return Crafter.new(item, amount_per_second_per_craft, new_inputs, new_count)
        end

        def to_s
            input_string = inputs.map { |i| i.to_s }.join("\n\t+ ")
            return ("<#{amount_per_second} #{item} / s>\n= #{count} [#{item}]\n\t= " + input_string).gsub("\n", "\n\t")
        end

    end

    def self.recipe_input_tree(inputs, parent_count=1)
        return inputs.map do |input|
            needed_amount_per_second = input.amount_per_second * parent_count
            if recipes.has_key?(input.item)
                reference = recipes[input.item]
                count = needed_amount_per_second / reference.amount_per_second
                new_inputs = recipe_input_tree(reference.inputs, count)
                Crafter.new(input.item, reference.amount_per_second_per_craft, new_inputs, count)
            else
                Throughput.new(input.item, needed_amount_per_second)
            end
        end
    end

    def self.recipe_tree(item, amount_per_second=nil)
        if recipes.has_key?(item)
            root = recipes[item]
            amount_per_second ||= root.amount_per_second
            count = amount_per_second / root.amount_per_second
            return Crafter.new(root.item, root.amount_per_second, recipe_input_tree(root.inputs, count), count)
        else
            amount_per_second ||= 1
            return Throughput.new(item, amount_per_second)
        end
    end

    def self.leaves(tree)
        result = []
        tree.inputs.each do |branch|
            case branch
            when Crafter
                result += leaves(branch)
            when Throughput
                result.push(branch)
            end
        end
        return result
    end

end
