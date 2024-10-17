require 'thor'
require 'dotenv/load'
require_relative 'helper'

module Aissue
  class CLI < Thor
    extend Aissue::Helper

    desc "start", "Start the Aissue CLI"
    def start
      print "Please enter your requirements: "
      purpose = $stdin.gets.chomp

      print "Please enter the relevant data: "
      data = $stdin.gets.chomp

      print "Please enter the path of the target script: "
      script_path = $stdin.gets.chomp

      script = get_file_contents(script_path)

      lang = ENV['AISSUE_LANG'] || '日本語'

      prompt = <<~PROMPT
        [Instructions]
        Create a Ruby code to achieve the [Purpose].
        If there is a [Script], please refer to it for the code.
        Output only the Ruby code without any explanations or results.

        [Purpose]
        #{purpose}

        [Data]
        #{data}

        [Script]
        #{script}

        [Output Constraints] # Most Important
        The [Output Result] will be executed with `exec([Output Result])`.
        Please output in a plain text format suitable for this process.
        Code blocks for markdown are unnecessary.
        Ensure that the result of executing the process is returned as a return value.

        [output language]
        #{lang}
      PROMPT

      ruby_code = post_openai(prompt, json: false)
      puts ruby_code

      if script.nil?
        print "Do you want to run this code?(y/n): "
        is_execute = $stdin.gets.chomp

        if ["Y", "YES"].include?(is_execute.upcase)
          eval(ruby_code, binding, __FILE__, __LINE__)
          result = binding.local_variable_get(:result)
          p result
        else
          puts "Finished without execution."
        end
      end

      print "Would you like to record this code in a GitHub Issue?(y/n): "
      is_record_issue = $stdin.gets.chomp

      if ["Y", "YES"].include?(is_record_issue.upcase)
        puts record_issue(purpose, ruby_code, script_path: script_path)
      end
    end
  end
end
