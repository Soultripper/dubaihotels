$logger = Log4r::Logger.new('hot5')
$logger.outputters << Log4r::Outputter.stdout
$logger.outputters << Log4r::FileOutputter.new('log_app', :filename =>  Rails.env.development? ? 'log/development.log'  : 'log/application.log')


