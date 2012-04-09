#!/usr/bin/ruby
# encoding: utf-8

# 2012 Martin Kozák (martinkozak@martinkozak.net)
# Code is Public Domain.

require "hash-utils"

full = (1..9).to_a
$step = 0
$cleans = 0
$round = 0

def print_data(data)
    print "=========\n"
    data.each do |row|
        row.each do |i|
            if i.length == 1
                print i.first
            else
                print "."
            end
        end
        print "\n"
    end
    print "---------\n"
    
    # checks sudoku is finished
    check_finished(data)
end

def check_finished(data)
    $step += 1
    
    total = data.inject(0) do |sum, row|
        sum += row.inject(0) do |subsum, cell|
            subsum += cell.length == 1 ? 1 : 0
        end
    end
    
    puts "round no.: " + $round.to_s
    puts "step no.: " + $step.to_s
    puts "cleans: " + $cleans.to_s
    puts "finished: " + total.to_s + " (" + ((total / 81.0) * 100).to_i.to_s + " %)"
    print "=========\n"
    
    $cleans = 0
        
    if total == 81
        decode_message(data)
        exit
    end
end

def each_square
    (0..8).step(3).each do |s1|
        (0..8).step(3).each do |s2|
            yield [s1, s2]
        end
    end
end

def each_squared(s1, s2)
    (s1..(s1 + 2)).each do |y|
        (s2..(s2 + 2)).each do |x|
            yield x, y
        end
    end
end

def select_section(value)
    (0..8).step(3).each do |i|
        if value < i
            return i - 3
        end
    end
    return 6
end

def select_square(x, y)
    _x = select_section(x)
    _y = select_section(y)
    return [_x, _y]
end

def clean_index(data, x, y)
    value = data[y][x]
    $cleans += 1
    
    if value.length == 1
        value = value.first
    else
        return
    end
    
    # Horizontal
    data[y].each_index do |_x|
        item = data[y][_x]
        if item.length > 1
            item.delete(value)
            clean_index(data, _x, y)
        end
        
    end
    
    # Vertical
    (0..8).each do |_y|
        item = data[_y][x]
        if item.length > 1
            item.delete(value)
            clean_index(data, x, _y)
        end
    end
    
    # Square
    s1, s2 = select_square(x, y)
    each_squared(s2, s1) do |_x, _y|
    #p [[_x, _y], data[_y][_x], value]
        #p [[_x, _y], data[_y][_x], value]
        item = data[_y][_x]
        if item.length > 1
            item  .delete(value)
            clean_index(data, _x, _y)
        end
    end
    #p [[x, y], [s1, s2]]
    #p ""
end

def check_index(data)
    data.each_index do |y|
        row = data[y]
        row.each_index do |x|
            if data[y][x].length == 1
                clean_index(data, x, y)
            end
        end
    end
end

def decode_message(data)
    puts ""
    data.each_index do |y|
        data[y].each_index do |x|
            value = data[y][x].first
            if value == 3 or value == 7
                character = $message[y][x]
                character = " " if character.nil?
                print character
            end
        end
    end
    puts "\n\n"
end

### DATA

data = [
    [nil, nil,   2, nil, nil, nil, nil, nil,   4],
    [  8,   5,   3,   4, nil,   1, nil, nil,   2],
    [nil, nil, nil,   6, nil, nil, nil,   9, nil],
    [nil,   8, nil,   1,   4, nil,   5, nil, nil],
    [  3, nil, nil, nil, nil, nil, nil, nil,   8],
    [nil, nil,   7, nil, nil,   2, nil,   1, nil],
    [nil,   1, nil, nil, nil,   6, nil, nil, nil],
    [  6, nil, nil,   5, nil,   4,   8,   2,   1],
    [  7, nil, nil, nil, nil, nil,   6, nil, nil]
]

$message = [
    [:M, :R, :Q, :U, :X, :B, :A, :Y, :O],
    [nil, :CH, :A, :R, :I, :A, :R, :I, :L],
    [:Ž, :Y, :O, :C, nil, :N, :N, :B, :E],
    [:F, :Ž, nil, :C, :G, :K, :Š, :Y, :H],
    [nil, :S, :R, :B, nil, :L, :L, :N, :I],
    [:B, :M, :A, :Z, nil, :D, :K, :O, :R],
    [:U, :D, :Y, :B, :R, nil, :CH, :V, :C],
    [nil, :A, :H, :N, :D, :F, :J, :D, :A],
    [:L, :Z, :M, :V, :A, :P, :Ě, :T, :E]
]

data.each do |row|
    row.map! do |i|
        i.nil? ? [ ] : [i]
    end
end     

### SOLVER

# Initial   
data.each do |row|
    has = row.reject { |i| i.empty? }.map! { |i| i.first }
    delta = full - has
    row.map! do |i| 
        i.empty? ? delta : i
    end
end

# Regular
puts "ORIGINAL"
print_data(data)

while true
    $round += 1

    ## Existing reduction
    ##
    
    # Vertical
    (0..8).each do |x|
        has = [ ]
        
        data.each_index do |y|
            row = data[y]
            if not row[x].nil? and row[x].length == 1
                has << row[x].first
            end
        end
        
        data.each_index do |y|
            row = data[y]
            if row[x].length > 1
                row[x] -= has
                #clean_index(data, x, y)
            end
        end
    end

    puts "VERTICAL REDUCTION"    
    print_data(data)
    
    # Horizontal
    data.each_index do |y|
        row = data[y]
        has = [ ]
        
        row.each_index do |x|
            i = row[x]
            if i.length == 1
                has << i.first
            end
        end
        
        row.each_index do |x|
            if row[x].length > 1
                row[x] -= has
                #clean_index(data, x, y)
            end
        end
    end
    
    puts "HORIZONTAL REDUCTION"    
    print_data(data)
    
    # Square
    each_square do |s1, s2|
        has = [ ]

        each_squared(s1, s2) do |x, y|
            item = data[y][x]
            if item.length == 1
                has << item.first
            end
        end
        each_squared(s1, s2) do |x, y|
            item = data[y][x]
            if item.length > 1
                item.replace(item - has)
                #clean_index(data, x, y)
            end
        end
    end
    
    puts "SQUARE REDUCTION"    
    print_data(data)
    
    ## Necessity reduction
    ##
    
    check_index(data)
    
    # Vertical
    (0..8).each do |x|
        has = Hash::new { |dict, key| dict[key] = 0 }
        data.each do |row|
            if row[x].length > 1
                row[x].each do |item|
                    has[item] += 1
                end
            end
        end
        
        has = has.reject { |k, v| v > 1 or v < 1 }.keys
        data.each_index do |y|
            row = data[y]
            if row[x].length > 1
                has.each do |item|
                    if row[x].include? item
                        row[x].replace([item])
                        clean_index(data, x, y)
                    end
                end
            end
        end
    end
    
    puts "VERTICAL NECESSITY"    
    print_data(data)
    
    # Horizontal
    data.each_index do |y|
        row = data[y]
        has = Hash::new { |dict, key| dict[key] = 0 }
        
        row.each_index do |x|
            if row[x].length > 1
                row[x].each do |item|
                    has[item] += 1
                end
            end
        end
        
        has = has.reject { |k, v| v > 1 or v < 1 }.keys
        row.each_index do |x|
            if row[x].length > 1
                has.each do |item|
                    if row[x].include? item
                        row[x].replace([item])
                        clean_index(data, x, y)
                    end
                end
            end
        end
    end
    
    puts "HORIZONTAL NECESSITY"    
    print_data(data)

end
