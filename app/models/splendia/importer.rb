class Splendia::Importer
  class << self 

    def all
      hotels
    end

    def hotels
      import SplendiaHotel
    end

    def import(klass)

      filename = get_and_store

      if klass.respond_to? :cols
        sql = "copy #{klass.table_name} (#{klass.cols}) from '#{filename}' delimiter ';' CSV HEADER;"
      else
        sql = "copy #{klass.table_name} from '#{filename}' delimiter ';' CSV HEADER;"
      end

      klass.delete_all
      Log.info sql
      ActiveRecord::Base.connection.execute sql
    end

    def get_and_store
      response = get_file
      store_file(response)
    end

    def get_file
      conn = Faraday.new("http://xmlfeed.splendia.com/feed.php?affiliate=C287&lang=EN&currency=GBP&type=csv")
      conn.get
    end


    def store_file(response)
      tmp_file = Tempfile.new([Time.now.to_i, '.csv'], "#{Rails.root}/tmp")
      tmp_file.binmode
      tmp_file.write response.body
      tmp_file.close
      Log.info "Written temp file #{ tmp_file.path}"
      tmp_file.path
    end
  end
end