require 'open3'

module Pronto
  class Ktlint
    class Wrapper
      def initialize(path)
        stdout, stderr, _status = Open3.capture3("ktlint \"#{path}\" --reporter=json")

        puts "WARN: stderr #{stderr}" if stderr && stderr.size > 0
        return [] if stdout.nil? || stdout.size == 0
        JSON.parse(stdout)
      rescue => e
        puts "ERROR: pronto-ktlint failed to process a diff: #{e}"
        []
      end
    end
  end
end
