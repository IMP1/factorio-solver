module FactorioCalculator

    RECIPES_PATH = "recipes/*.lua"

    def self.parse_lua_recipes(recipes, text)
        text.split(/type\s*=\s*"recipe"/).each do |string|
            string.match(/name\s*=\s*"(.+?)"/) do
                recipe_name = string.match(/name\s*=\s*"(.+?)"/)[1]

                amount = 1
                string.match(/result_count\s*=\s*(\d+)/) do |count|
                    amount = count[1].to_r
                end

                duration = string.match(/energy_required\s*=\s*(\d+(?:\.\d+)?)/)[1].to_r

                recipe_results = {}
                string.match(/result\s*=\s*"(.+?)"/) do |m|
                    recipe_results[m[1]] = amount
                end
                if recipe_results.empty?
                    string.match(/results\s*=[\s\n]*\{[\s\n]*(\{.+?\})[\s\n]*\}/m)[1].scan(/\{.+?\}/).each do |r| 
                        simple_result = r.scan(/\"(.+?)\",\s*(\d+)/)
                        if simple_result.empty?
                            item_name = r.scan(/name\s*=\s*"(.+?)"/)[0][0]
                            amount = r.scan(/amount\s*=\s*(.+?)/)[0][0]
                        else
                            item_name, amount = simple_result[0]
                        end
                        recipe_results[item_name] = amount.to_r
                    end
                end

                ingredients = []
                string.match(/ingredients\s*=[\s\n]*\{[\s\n]*(\{.+?\})[\s\n]*\}/m)[1].scan(/\{.+?\}/).each do |i|
                    simple_ingredient = i.scan(/\"(.+?)\",\s*(\d+)/)
                    if simple_ingredient.empty?
                        item_name = i.scan(/name\s*=\s*"(.+?)"/)[0][0]
                        amount = i.scan(/amount\s*=\s*(.+?)/)[0][0]
                    else
                        item_name, amount = simple_ingredient[0]
                    end
                    ingredients.push(Throughput.new(item_name, amount.to_r / duration))
                end

                recipe_results.each do |item_name, output_amount|
                    recipes[item_name] ||= Crafter.new(item_name, output_amount / duration, ingredients)
                end
            end
        end
    end

    def self.load_recipes
        recipes = {}
        Dir.glob(RECIPES_PATH).each do |recipe_file|
            file_contents = File.read(recipe_file)
            parse_lua_recipes(recipes, file_contents)
        end
        @recipes = recipes
    end

    def self.recipes
        return @recipes
    end

end
