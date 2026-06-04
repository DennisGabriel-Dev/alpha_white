#!/usr/bin/env ruby
# frozen_string_literal: true
require "fileutils"
require "rexml/document"

INPUT = File.expand_path("../coverage/coverage.xml", __dir__)
OUTPUT = File.expand_path("../coverage/sonar-coverage.xml", __dir__)

unless File.file?(INPUT)
  warn "Arquivo não encontrado: #{INPUT} (rode make test-coverage antes)"
  exit 1
end

doc = REXML::Document.new(File.read(INPUT))
out_doc = REXML::Document.new
out_doc.add(REXML::XMLDecl.new("1.0", "UTF-8"))
coverage_el = out_doc.add_element("coverage", { "version" => "1" })

file_count = 0

doc.elements.each("coverage/packages/package") do |package|
  package.elements.each("classes/class") do |klass|
    path = klass.attributes["filename"]
    next if path.nil? || path.empty?

    file_el = coverage_el.add_element("file", { "path" => path })
    file_count += 1

    klass.elements.each("lines/line") do |line|
      hits = line.attributes["hits"].to_i
      file_el.add_element("lineToCover", {
        "lineNumber" => line.attributes["number"],
        "covered" => hits.positive? ? "true" : "false"
      })
    end
  end
end

FileUtils.mkdir_p(File.dirname(OUTPUT))
formatter = REXML::Formatters::Pretty.new(2)
File.open(OUTPUT, "w") { |f| formatter.write(out_doc, f) }

puts "Gerado #{OUTPUT} (#{file_count} arquivos)"
