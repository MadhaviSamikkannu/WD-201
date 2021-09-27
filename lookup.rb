def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")
##

def parse_dns(dns_raw1)
 domain_record = Hash.new
 dns_raw1.
  delete_if { |line| line.empty? }.map { |line| line.strip.split(", ") }.
  each_with_object({}) do |record, records|
    domain_record[record[1]] = { type: record[0], target: record[2] }
  end
 domain_record
end


def resolve(dns_records, lookup_chain, domain_record)
 row = dns_records[domain_record]
    if (!row)
        lookup_chain = []
        lookup_chain << "Error: record not found for  " + domain_record
    elsif row[:type] == "CNAME"
        lookup_chain << row[:target]
        resolve(dns_records, lookup_chain, row[:target])
    elsif row[:type] == "A"
        lookup_chain << row[:target]
    else
        puts "Error"
        return lookup_chain
    end
  end


# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.


dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
