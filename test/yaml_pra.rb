require "yaml"

file_name = "config.yml"

file = File.open(file_name, "w")


data1 = {"wikiperank" => {"read_data_number" => 500, "base_url" => "http://dumps.wikimedia.org/other/pagecounts-raw/year/year-month/", "number_of_rank_to_be_output" => 100}}
str_r = YAML.dump(data1)

puts str_r

file.write(str_r)
file.close

config = YAML.load_file("config.yml")
p config["wikiperank"]["read_data_number"]
p config["wikiperank"]["base_url"]
p config["wikiperank"]["number_of_rank_to_be_output"]
