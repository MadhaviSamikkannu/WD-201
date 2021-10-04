def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument
dns_raw = File.readlines("zone")

def parse_dns(dns_raw1)
  domain_record = Hash.new
  dns_raw1.
    delete_if { |line| line.strip.empty? }.map { |line| line.strip.split(", ") }.
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
  elsif row[:type] == "A"
    lookup_chain << row[:target]
  elsif row[:type] == "CNAME"
    lookup_chain << row[:target]
    resolve(dns_records, lookup_chain, row[:target])
  else
    return lookup_chain
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
