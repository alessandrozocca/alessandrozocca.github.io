#!/usr/bin/env ruby

require "json"
require "nokogiri"
require "pathname"
require "uri"

site = Pathname(ARGV.fetch(0, "_site")).expand_path
errors = []

expected_routes = %w[
  index.html
  publications/index.html
  news/index.html
  repositories/index.html
  cv/index.html
  404.html
]

expected_routes.each do |route|
  errors << "missing public route: #{route}" unless site.join(route).file?
end

def local_destination(site, source, raw)
  path = raw.split(/[?#]/, 2).first.to_s
  return nil if path.empty? || path.start_with?("#", "mailto:", "tel:", "javascript:", "data:")
  return nil if path.match?(%r{\Ahttps?://}) || path.start_with?("//")
  # PDF assets are intentionally outside this structural check; they are
  # maintained and reviewed separately from the generated website.
  return nil if File.extname(path).casecmp?(".pdf")

  candidate = if path.start_with?("/")
                site.join(path.delete_prefix("/"))
              else
                source.dirname.join(path).cleanpath
              end
  return candidate if candidate.file?
  return candidate.join("index.html") if candidate.directory?

  html_candidate = Pathname("#{candidate}.html")
  return html_candidate if candidate.extname.empty? && html_candidate.file?

  candidate
end

Dir.glob(site.join("**/*.html")).sort.each do |file_name|
  source = Pathname(file_name)
  label = source.relative_path_from(site).to_s
  document = Nokogiri::HTML5(source.read)

  ids = document.css("[id]").map { |node| node["id"] }
  ids.tally.select { |_id, count| count > 1 }.each_key do |id|
    errors << "#{label}: duplicate id #{id}"
  end

  errors << "#{label}: expected one main landmark" unless document.css("main").length == 1
  errors << "#{label}: expected one h1" unless document.css("h1").length == 1
  errors << "#{label}: missing skip link" unless document.at_css('a.skip-link[href="#main-content"]')

  document.css("img").each do |image|
    errors << "#{label}: image missing alt (#{image['src']})" unless image.key?("alt")
  end

  document.css("button").each do |button|
    name = [button["aria-label"], button["title"], button.text].compact.join(" ").strip
    errors << "#{label}: unnamed button" if name.empty?
  end

  document.css("input:not([type='hidden']), textarea, select").each do |control|
    control_id = control["id"]
    labelled = control["aria-label"] || control["aria-labelledby"] || control.ancestors("label").any?
    labelled ||= control_id && document.css("label[for]").any? { |label_node| label_node["for"] == control_id }
    errors << "#{label}: unlabelled form control #{control.name}##{control_id}" unless labelled
  end

  document.css("script[type='application/ld+json']").each do |script|
    JSON.parse(script.text)
  rescue JSON::ParserError => error
    errors << "#{label}: invalid JSON-LD (#{error.message})"
  end

  document.css("a[href], link[href], img[src], script[src], source[srcset]").each do |element|
    attribute = element.key?("href") ? "href" : (element.key?("src") ? "src" : "srcset")
    values = if attribute == "srcset"
               element[attribute].to_s.split(",").map { |item| item.strip.split.first }
             else
               [element[attribute]]
             end

    values.each do |raw|
      destination = local_destination(site, source, raw.to_s)
      errors << "#{label}: missing local resource #{raw}" if destination && !destination.exist?
    end
  end

  document.css("a[href^='#']").each do |link|
    fragment = URI.decode_www_form_component(link["href"].delete_prefix("#"))
    next if fragment.empty?

    has_target = document.css("[id]").any? { |node| node["id"] == fragment }
    errors << "#{label}: missing fragment ##{fragment}" unless has_target
  end
end

stylesheet = site.join("assets/css/main.css")
unless stylesheet.file? && stylesheet.read.match?(/--global-theme-color:\s*#db3a1d/i)
  errors << "compiled stylesheet does not use #db3a1d as the theme color"
end

if errors.empty?
  puts "Generated site passed structural, accessibility, metadata, and internal-resource checks."
else
  warn errors.join("\n")
  exit 1
end
