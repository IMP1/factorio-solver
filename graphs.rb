require 'erb'

module FactorioCalculator

    class Graph

        attr_reader :nodes
        attr_reader :edges

        def initialize(nodes, edges)
            @nodes = nodes
            @edges = edges
        end

        def to_s
            str = "digraph \"#{nodes.first.item}\" {\n"
            str += "\tnode [width = 1, margin = 0.2];\n"
            nodes.each do |node|
                shape = "box"
                shape = "trapezium" if node.item.include?("plate")
                shape = "egg" if node.is_a?(Crafter) and node.inputs.any? { |i| i.item.include?("oil") }
                shape = "diamond" if node.is_a?(Throughput)
                
                amount = node.amount_per_second

                width = 1
                width = 0.7 if shape == "trapezium"

                margin = 0.2
                margin = 0 if shape != "box"

                count = node.is_a?(Throughput) ? "" : node.count.to_s + " "
                label = "#{count}#{node.item}\\n(#{amount.numerator} / #{amount.denominator}s)"

                str += "\t\"#{node.item}\" [ shape = #{shape}"
                str += ", margin = #{margin}"
                str += ", width = #{width}"
                str += ", label = \"#{label}\""
                # TODO: 
                #   Have all inputs be in same row
                #   Have all final products be in same row.
                #   Check out page 16 in this for how to? https://graphviz.gitlab.io/_pages/pdf/dotguide.pdf
                str += ", rank = source" if node.is_a?(Throughput)
                str += ", rank = sink" if nodes.none? { |n| n.is_a?(Crafter) && n.inputs.any? { |i| i.item == node.item } }
                str += " ];\n"
            end
            edges.each do |target, sources|
                sources.each do |source|
                    source_node = @nodes.find { |n| n.item == source }
                    target_node = @nodes.find { |n| n.item == target }
                    target_input = target_node.inputs.find { |n| n.item == source }
                    total_output = source_node.amount_per_second
                    partial_input = target_input.amount_per_second
                    # puts
                    # p source_node
                    # p target_node
                    # p target_input
                    # puts
                    fraction = partial_input / total_output
                    str += "\t\"#{source}\" -> \"#{target}\" ["
                    str += " label = \"#{fraction}\"" if fraction != 1
                    str += " ];\n"
                end
            end
            str += "}\n"
            return str
        end

    end

    def self.collapsed_graph(*trees)
        nodes = {}
        edges = {}
        collapse_subtree(nodes, edges, trees)
        return Graph.new(nodes.values, edges)
    end

    def self.collapse_subtree(nodes, edges, branches)
        branches.each do |b|
            if nodes.has_key?(b.item)
                nodes[b.item] += b
            else
                nodes[b.item] = b
            end
            if b.is_a?(Crafter)
                collapse_subtree(nodes, edges, b.inputs) 
                edges[b.item] ||= []
                edges[b.item] += b.inputs.map { |i| i.item }
                edges[b.item].uniq!
            end
        end
    end

    def self.show_svg(dag)
        graph_viewer_url = "https://dreampuf.github.io/GraphvizOnline/#" + ERB::Util.url_encode(dag.to_s)
        `start #{graph_viewer_url}`
    end

end