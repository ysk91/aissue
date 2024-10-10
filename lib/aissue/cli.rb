require 'aissue'
require 'aissue/util'
require 'thor'
require 'dotenv/load'

module Aissue
  class CLI < Thor
    desc "start", "Start the Aissue CLI"
    def start
      puts "Aissue CLI started"
      # その他の処理
    end
  end
end
