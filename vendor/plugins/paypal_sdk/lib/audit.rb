puts "*** Loading paypal audit"

Time::DATE_FORMATS[:ymdhmz] = "%Y-%m-%d %H:%M:%S %Z"     #  2008-06-30 13:38:34 HKT

module PPUtils
  class AuditLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_formatted_s(:ymdhmz)} - #{severity} - #{msg}\n"
    end
  end

  class Audit
    def self.getLogger
      logfile = File.open("#{RAILS_ROOT}/log/paypal.log", 'a')
      logfile.sync = true
      @@PPLogger ||= AuditLogger.new(logfile)
      return @@PPLogger
    end
  end
end
