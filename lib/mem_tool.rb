# http://www.happybootstrapper.com/2014/profile-leaky-sidekiq-job-heroku
# Uses Ruby-Prof in dev env, add the following to gemfile development section:
# gem 'ruby-prof'
require 'ruby-prof'
module MemTool

  def self.start(file_name = 'no_name')
    unless Rails.env.test?
      begin
        start_profiling(file_name)
      rescue => e
        Rails.logger.warn(sprintf 'MemTool: %s', e.message)
      end
    end
  end

  def self.stop
    unless Rails.env.test?
      begin
        stop_profiling
      rescue => e
        Rails.logger.warn(sprintf 'MemTool: %s', e.message)
      end
    end
  end

  def self.object_stats
    stats = Hash.new(0)
    ObjectSpace.each_object { |o| stats[o.class] += 1 }
    stats
  end

  def self.get_memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i
  end

  private

  def self.to_sorted_array(hsh)
    hsh.sort { |a, b| b[1] <=>a[1] }.collect { |k, v| "#{k}: #{v}" }
  end

  def self.start_profiling(file_name)
    @file_name = file_name
    @object_stats = object_stats
    @memory_stats = {memory_usage: get_memory_usage}
    @gc_stats = GC.stat
    RubyProf.start unless Rails.env.production?
  end

  def self.stop_profiling
    result = RubyProf.stop unless Rails.env.production?
    new_gc_stats = GC.stat
    new_memory_stats = {memory_usage: get_memory_usage}
    new_object_stats = object_stats

    if Rails.env.production?
      log_other_stats(new_gc_stats, new_object_stats, new_memory_stats)
    else
      time = DateTime.now.to_i
      print_ruby_prof_stats(result, time)
      print_other_stats(new_gc_stats, new_object_stats, new_memory_stats, time)
    end

    clean_up
  end

  def self.clean_up
    @file_name = nil
    @gc_stats = nil
    @object_stats = nil
    @memory_stats = nil
  end

  def self.print_ruby_prof_stats(result, time)
    html_file = open_file_for_writing time, 'html'
    printer = RubyProf::GraphHtmlPrinter.new(result)
    printer.print(html_file, :min_percent => 5)
    html_file.close
  end


  def self.log_other_stats(new_gc_stats, new_object_stats, new_memory_stats)
    # The sleeps help the log lines to get into right order
    Rails.logger.info 'Memory Profile for ' << @file_name
    Rails.logger.info "**** MEMORY ****"
    sleep(1.0/20.0)
    log_stats new_memory_stats, @memory_stats
    sleep(1.0/20.0)
    Rails.logger.info "**** GARBAGE COLLECTOR ****"
    sleep(1.0/20.0)
    log_stats new_gc_stats, @gc_stats
    sleep(1.0/20.0)

    Rails.logger.info "**** OBJECTS IN MEMORY ****"
    sleep(1.0/20.0)
    log_stats new_object_stats, @object_stats

  end

  def self.print_other_stats(new_gc_stats, new_object_stats, new_memory_stats, time)
    text_file = open_file_for_writing time, 'txt'

    text_file.puts "**** MEMORY ****"
    print_stats new_memory_stats, @memory_stats, text_file
    text_file.puts "\n"

    text_file.puts "**** GARBAGE COLLECTOR ****"
    print_stats new_gc_stats, @gc_stats, text_file

    text_file.puts "\n"

    text_file.puts "**** OBJECTS IN MEMORY ****"
    print_stats new_object_stats, @object_stats, text_file

    text_file.close
  end


  def self.open_file_for_writing(time, suffix)
    File.new "#{Rails.root}/log/#{time}_#{@file_name}.#{suffix}", 'a+'
  end

  def self.print_stats(stats, last_stats, out)
    title = sprintf("%10s | %10s |", 'Before', 'Delta')
    out.puts title

    line_format = "%10d | %10d | %-30s"
    stats.sort { |(k1, v1), (k2, v2)| v2 <=> v1 }.each do |key, value|
      delta = 0
      if last_stats[key]
        delta = value - last_stats[key]
      end
      log_entry = sprintf(line_format, value, delta, key)
      out.puts log_entry
    end
  end

  def self.log_stats(stats, last_stats)
    title = sprintf("%10s | %10s |", 'Before', 'Delta')
    Rails.logger.info title

    # filter away classes with less than 10 instances
    stats.reject! { |key, value| value < 10 }

    line_format = "%10d | %10d | %-30s"
    stats.sort { |(k1, v1), (k2, v2)| v2 <=> v1 }.each do |key, value|
      delta = 0
      if last_stats[key]
        delta = value - last_stats[key]
      end
      log_entry = sprintf(line_format, value, delta, key)
      Rails.logger.info log_entry
    end
  end
end