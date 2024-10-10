require_relative 'util'

module Aissue
  include Aissue::Util

  class Issue
    class << self
      def rescue(e)
        repo_root = Dir.pwd
        error_details = e.backtrace.map do |line|
          line.sub(/^#{Regexp.escape(repo_root)}\//, '')
        end

        error_script_paths = error_details.map do |detail|
          detail.split(':').first.strip
        end
        error_script_paths.uniq!

        error_scripts = error_script_paths.map do |error_script_path|
          get_file_contents(error_script_path)
        end

        lang = ENV['AISSUE_LANG'] || '日本語'

        prompt = <<~PROMPT
          [Instructions]
          Analyze the [Error Details], describe the cause and corrective actions in <<comment>>.
          Summarize the contents of <<comment>> and use it as <<title>>.
          Output the results in JSON format.
          Include items in the JSON according to [Output Items].

          [Format of <<comment>>]
          ## Error Occurrence
          ```
          #{error_details}
          ```
          (Describe the occurred error)

          ## Cause
          (Explain the location and cause of the error
          Particularly, this error occurred when executing [Error Location].
          Within this script, while identifying where [Error Details] occurs, also consider the possibility that the [Module] might be the cause.)

          ## Corrective Actions
          (Describe what kind of corrections should be made to which file to resolve the error)

          ### Target File
          (Specify the path of the file to be corrected)

          ### Correction Content
          (Describe the corrected code)

          [Output Items]
          title: <<title>>
          comment: <<comment>>

          [Error Details]
          "#{e.class}: #{e.message}"

          [Error Location]
          #{error_details[-1]}

          [Module]
          #{error_scripts}

          [output language]
          #{lang}
        PROMPT

        response = post_openai(prompt, json: true)
        title = response["title"]
        body = response["comment"]
        create_issue(title, body)
      end
    end
  end
end
