module Utilities
  extend self

  def helpers
    @helpers ||= ActionController::Base.helpers
  end

  def to_currency(value, args={})
    helpers.number_to_currency(value.to_f, {unit:'$'}.merge(args))
  end

  def to_money(value, args={})
    Money.new(value)
  end

  def simplify(value)
    value > 99999 ? "#{(value / 1000)}K" : value
  end

  def humanize_number(value)
    helpers.number_to_human value.to_i
  end

  def nil_round(value, default=0)
    value ? value.to_f.round : default
  end

  def file_to_json(file)
    f = File.open(file)
    doc = Nokogiri::XML(f)
    f.close
    Hash.from_xml doc.to_xml    
  end

  def mem_check(&block)
    return puts(mem_report) unless block_given?
    puts "Before " + mem_report
    yield
    puts "After " + mem_report
  end

  def mem_report
    size = (`ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split[1].to_f / 1024).round(2)
    "Memory: #{size}MB"
  end

end