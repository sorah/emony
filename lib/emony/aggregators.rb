module Emony
  module Aggregators
    def self.find(name)
      retried = false
      constant_name = name.to_s.gsub(/\A.|_./) { |s| s[-1].upcase }

      begin
        const_get constant_name
      rescue NameError
        unless retried
          begin
            require "emony/aggregators/#{name}"
          rescue LoadError
          end

          retried = true
          retry
        end

        nil
      end
    end
  end
end
