require 'csv'

class MySqliteRequest
    def initialize
        @data_base_name = ""
        @select_query = []
        @where_query = {}
        @request_method = ""
        @value_of_element = {}
    end

    def from data_base_name
        @data_base_name = data_base_name
        self
    end

    def select string
        @request_method = "SELECT"
        flag = 0
        if !string.is_a?(String)
            flag = 1
        end
        if flag != 1
            @select_query.push(string)
        else
            for point in string do
                @select_query.push(point)
            end
        end
        self
    end

    def values value_of_element
        elements_value = value_of_element
        @value_of_element = elements_value
        self
    end

    def insert data_base_name
        @request_method = "INSERT"
        name_of_db = data_base_name
        @data_base_name = name_of_db
        return self
    end

    def where(column_key, column_value)
        key_of_column = column_key
        value_of_column = column_value
        @where_query[key_of_column] = value_of_column
        return self
    end

    def update data_base_name
        @request_method = "UPDATE"
        name_of_db = data_base_name
        @data_base_name = name_of_db
        self
    end

    def delete
        @request_method = "DELETE"
        self
    end

    def reproduce hashs
        column_names = hashs.first.keys
        string = ""
        string += "#{column_names.join(',')}\n"
        hashs.each do |value|
            string += "#{value.values.join(',')}\n"
        end
        File.write(@data_base_name, string)
    end

    def get_selected_query(point)
        filter_items = point.to_hash.slice(*@select_query)
        return filter_items
    end

    def print_out point
        if @select_query[0] == "*"
            p point.to_hash
        else
            p get_selected_query(point)
        end
    end

    def print_ parsed_data
        for point in parsed_data do
            if @where_query.length > 0
                for item in @where_query.keys do
                    if (@where_query[item] == point.to_hash[item])
                        print_out(point)
                    end
                end
            else
                print_out(point)
            end
        end
    end

    def insert_method 
        file = File.open(@data_base_name, 'a')
        file << "\n"
        file << "#{@value_of_element.values.join(',')}"
    end

   

    def select_method
        temp = @data_base_name
        parsed_data = CSV.parse(File.read(temp), headers: true)
        print_(parsed_data)
    end

    def update_method
        parsed_data = CSV.parse(File.read(@data_base_name), headers: true)
        result = Array.new
        for point in parsed_data do
            if point.to_hash.has_key?(@where_query.keys[0])
                x = point.to_hash[@where_query.keys[0]]
                y = @where_query[@where_query.keys[0]]
                if (x == y)
                    for key in @value_of_element.keys do
                        point[key] = @value_of_element[key]
                    end
                end
            end
            result.push(point.to_hash)
        end
        reproduce(result)
    end

    def delete_method
        result = Array.new
        parsed_data = CSV.parse(File.read(@data_base_name), headers: true).each do |point|
            if point.to_hash.has_key?(@where_query.keys[0])
                x = point.to_hash[@where_query.keys[0]]
                y = @where_query[@where_query.keys[0]]
                next if x == y
            end
            result.push(point.to_hash)
        end
        reproduce(result)
    end

    def run
        @request_method = @request_method.downcase
        if @request_method == "select"
            select_method()
        elsif @request_method == "update"
            update_method()
        elsif @request_method == "delete"
            delete_method()
        elsif @request_method == "insert"
            insert_method()
        else 
            p "Wrong type of request #{@request_method}!"
        end
    end
end

# request = MySqliteRequest.new
# request = request.select(["name", "college"])
# request = request.from('nba_player_data.csv')
# request = request.where('college', 'University of California, Los Angeles')
# request = request.where('name', 'Don Ackerman')
# request.run