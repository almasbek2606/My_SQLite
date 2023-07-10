require './my_sqlite_request'
require 'readline'
require 'json'
require 'csv'

class Helper_Funcs
    def strstr(array, string)
        i = 0
        while i < array.length 
            return i if array[i] == string
            i+=1
        end
        return -1
    end
end

class Cli
    def initialize
        @helper = Helper_Funcs.new
    end
    def select_data splited_cli
        request = MySqliteRequest.new
        index = 0
        while index < splited_cli.length
            case splited_cli[index].upcase
            when "SELECT"
                request = request.select(splited_cli.slice(index + 1, @helper.strstr(splited_cli , "FROM")-1)[0].split(","))
            when "FROM"
                request = request.from(splited_cli[index+1])
            when "WHERE"
                splited_cli.slice(index + 1, splited_cli.length - 1).join(' ').split(',').map { |str| str.split('=') }.map { |arr| arr.map { |str| str.strip!.gsub(/\"|\'/, '') } }.each do |item|
                    request = request.where(item[0], item[1])
                end
            end
            index += 1
        end
        request.run
    end

    def insert_data cmd_line
        request = MySqliteRequest.new
        hash = {}
        index = 0
        table_idx = -1
        cmd_line = cmd_line
        while index < cmd_line.length
            if cmd_line[index] == "INSERT"
                table_idx = (index + (1 + 1))
                request = request.insert(cmd_line[index+(1+1)])
            elsif cmd_line[index] == "VALUES"
                values = cmd_line.slice(index + 1, cmd_line.length - 1).join(' ').gsub(/\(|\)/, '').parse_csv
                CSV.read(cmd_line[table_idx])[0].each_with_index do |key, i|
                    hash[key] = values[i]
                end
                request = request.values(hash)
            end
            index += 1
        end
        request.run
    end

    def delete_data cmd_line
        request = MySqliteRequest.new
        index = 0
        request = request.delete()
        while index < cmd_line.length
            case cmd_line[index].upcase
            when "DELETE"
                request = request.from(cmd_line[index+2])
            when "WHERE"
                cmd_line.slice(index + 1, cmd_line.length - 1).join(' ').split(',').map { |str| str.split('=') }.map { |arr| arr.map { |str| str.strip!.gsub(/\"|\'/, '') } }.each do |item|
                    request = request.where(item[0], item[1])
                end
            end
            index+=1
        end
        request.run
    end

    def update_data cmd_line
        request = MySqliteRequest.new
        i = 0
        request = request.update(cmd_line[1])
        while i < cmd_line.length
            case cmd_line[i].upcase
            when "SET"
                values =  cmd_line.slice(i + 1, cmd_line.index("WHERE") - 3).join(' ').split(',').map { |str| str.split('=') }.map { |arr| arr.map { |str| str.strip!.gsub(/\"|\'/, '') } }.to_h
                request = request.values(values)
            when "WHERE"
                cmd_line.slice(i + 1, cmd_line.length - 1).join(' ').split(',').map { |str| str.split('=') }.map { |arr| arr.map { |str| str.strip!.gsub(/\"|\'/, '') } }.each do |item|
                    request = request.where(item[0], item[1])
                end
            end
            i+=1
        end
        request.run
    end

    def redirect command_line
        splited_cli = command_line.split(' ')
            
        if splited_cli[0].upcase == "SELECT"
            select_data(splited_cli)
        elsif splited_cli[0].upcase == "UPDATE"
            update_data(splited_cli)
        elsif splited_cli[0].upcase == "DELETE"
            delete_data(splited_cli)
        elsif splited_cli[0].upcase == "INSERT"
            insert_data(splited_cli)
        else
            p "You choose wrong type of request!"
        end
    end
end

cli = Cli.new
while true
    command_line = Readline.readline("> " , true)
    if command_line == 'exit' || command_line == "quit"
        puts "Bye Bye :)"
        break
    elsif command_line == "clear"
        puts "\e[H\e[2J"
        next
    end
    cli.redirect(command_line)
end