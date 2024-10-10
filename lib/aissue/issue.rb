$LOAD_PATH.unshift(File.expand_path('../', __dir__))
require 'aissue/util'

module Aissue
  include Aissue::Util

  class Issue
    class << self
      def record(purpose, ruby_code, script_path: nil)
        issue_title = purpose
        issue_body = <<~BODY
          ## 対象スクリプト
          #{script_path}

          ## 実装コード
          ```ruby
          #{ruby_code}
          ```
        BODY

        create_issue(issue_title, issue_body)
      end

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

        prompt = <<~PROMPT
          [命令]
          [エラー内容]を解析し、原因と改善策を<<comment>>に記述してください。
          <<comment>>の内容を簡単にまとめ、<<title>>としてください。
          結果をJSON形式で出力してください。
          JSONに含める項目は[出力項目]の通りです。

          [<<comment>>の形式]
          ## 発生エラー
          ```
          #{error_details}
          ```
          (発生したエラーについて説明)

          ## 原因
          (エラーについて、発生箇所と原因を説明
          特に、本エラーは[エラー発生箇所]を実行した際に発生したものです。
          このスクリプト内で、[エラー内容]が発生する箇所を特定しつつ、[モジュール]が原因である可能性も考慮してください)

          ## 改善策
          (エラーを解消するために、どのファイルに対してどのような修正を行うべきかを記述)

          ### 対象ファイル
          （修正すべきファイルのパスを記載）

          ### 修正内容
          （修正後のコードを記載）

          [出力項目]
          title: <<title>>
          comment: <<comment>>

          [エラー内容]
          "#{e.class}: #{e.message}"

          [エラー発生箇所]
          #{error_details[-1]}

          [モジュール]
          #{error_scripts}
        PROMPT

        response = post_openai(prompt, json: true)
        title = response["title"]
        body = response["comment"]
        create_issue(title, body)
      end
    end
  end
end
