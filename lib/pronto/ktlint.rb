require 'pronto'
require 'open3'
require 'byebug'

module Pronto
  class Ktlint < Runner
    def run
      return [] unless @patches

      @patches.select { |patch| patch.additions > 0 }
              .select { |patch| kt_file?(patch.new_file_full_path) }
              .flat_map { |patch| inspect(patch) }
              .compact
              .flatten
    end

    private

    def lint(path)
      stdout, stderr, _status = Open3.capture3("ktlint \"#{path}\" --reporter=json")

      puts "WARN: stderr #{stderr}" if stderr && stderr.size > 0
      return [] if stdout.nil? || stdout.size == 0
      JSON.parse(stdout)
    rescue => e
      puts "ERROR: pronto-ktlint failed to process a diff: #{e}"
      []
    end

    def inspect(patch)
      offences = lint(patch.new_file_full_path.to_s)

      offences[0]['errors'].map do |violation|
        patch.added_lines
             .select { |line| line.new_lineno == violation['line'] }
             .map { |line| new_message(violation, line) }
      end
    end

    def new_message(violation, line)
      path = line.patch.delta.new_file[:path]
      level = :warning
      Message.new(path, line, level, violation['message'], nil, self.class)
    end

    def kt_file?(path)
      %w(.kt).include? File.extname(path)
    end

    def pronto_ktlint_config
      @pronto_ktlint_config ||= Pronto::ConfigFile.new.to_h['ktlint'] || {}
    end
  end
end
