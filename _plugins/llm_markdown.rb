# frozen_string_literal: true

# llm_markdown.rb — agent-accessible markdown for claude-code-guide.org.
#
# Emits, at build time, a raw-markdown twin of every content page plus a single
# concatenated `llms-full.txt`. Twins let agents fetch the source markdown of a
# page instead of parsing the full just-the-docs HTML chrome (nav sidebar, SVG
# sprite, search scripts). The companion `_worker.js` serves these twins under
# content negotiation (`Accept: text/markdown`); they are also fetchable
# directly by appending `.md` to a page URL.
#
# Twin path scheme (must stay in lockstep with _worker.js `markdownTwin`):
#   "/docs/getting-started/"  -> "/docs/getting-started.md"
#   "/skills/ask/references/beginner/memory/" -> "/skills/ask/references/beginner/memory.md"
#   "/some/page.html"         -> "/some/page.md"
#   "/"  (home)               -> no twin (body lives in the layout; the
#                                worker maps "/" to "/llms.txt" instead)
#
# Content is Liquid-rendered (so data-driven pages resolve) but deliberately NOT
# Markdown-converted — the output is the markdown source, not HTML.

require "fileutils"

module ClaudeCodeGuide
  # A virtual file whose bytes are written verbatim to the build output,
  # bypassing Jekyll's render pipeline (no Liquid, no Markdown conversion at
  # write time — the content is already final).
  class RawFile < Jekyll::StaticFile
    def initialize(site, dir, name, content)
      @site = site
      @dir = dir            # output dir relative to site root, e.g. "docs"
      @name = name          # output filename, e.g. "getting-started.md"
      @content = content
      @relative_path = File.join(@dir, @name).sub(%r{\A/}, "")
      @extname = File.extname(@name)
      @data = {}
      @collection = nil
    end

    def write(dest)
      dest_path = File.join(dest, @relative_path)
      FileUtils.mkdir_p(File.dirname(dest_path))
      File.write(dest_path, @content)
      true
    end

    # One-shot builds never compare mtimes; always (re)write.
    def modified?
      true
    end

    def path
      @relative_path
    end

    def to_liquid
      {}
    end
  end

  class MarkdownTwinGenerator < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      twins = []
      corpus = []

      twinnable(site).each do |page|
        body = render_liquid(site, page).strip
        next if body.empty? # e.g. the home page, whose body lives in the layout

        rel = twin_relpath(page.url)
        next if rel.nil?

        dir = File.dirname(rel)
        dir = "" if dir == "."
        twins << RawFile.new(site, dir, File.basename(rel), body + "\n")
        corpus << { url: page.url, title: page.data["title"], body: body }
      end

      twins << build_full(site, corpus)
      site.static_files.concat(twins)
      Jekyll.logger.info "llm-markdown:", "wrote #{twins.length - 1} markdown twins + llms-full.txt"
    end

    private

    # Pages that produce an HTML document from markdown source. Excludes the
    # liquid utility pages (robots.txt, sitemap.xml, llms.txt), assets, and
    # anything opting out with `llm_twin: false` in front matter.
    def twinnable(site)
      site.pages.select do |page|
        markdown_ext?(page.extname) &&
          page.output_ext == ".html" &&
          page.data["llm_twin"] != false
      end
    end

    def markdown_ext?(ext)
      [".md", ".markdown"].include?(ext.to_s.downcase)
    end

    def twin_relpath(url)
      return nil if url.nil? || url.empty?

      if url.end_with?("/")
        return nil if url == "/"

        "#{url[1..-2]}.md"
      elsif url.end_with?(".html")
        "#{url[1..].sub(/\.html\z/, '')}.md"
      end
    end

    def render_liquid(site, page)
      payload = site.site_payload
      payload["page"] = page.to_liquid
      payload["paginator"] = nil
      info = {
        registers: { site: site, page: payload["page"] },
        strict_filters: false,
        strict_variables: false,
      }
      site.liquid_renderer.file(page.path).parse(page.content).render!(payload, info)
    rescue StandardError => e
      Jekyll.logger.warn "llm-markdown:", "Liquid render failed for #{page.path}: #{e.message}"
      page.content
    end

    def build_full(site, corpus)
      base = site.config["url"].to_s
      out = +"# Claude Code Guide — full documentation\n\n"
      out << "> #{site.config['description']}\n\n" if site.config["description"]
      out << "Every claude-code-guide.org documentation page, concatenated as " \
             "markdown for LLM ingestion. Each page is also available on its own " \
             "at the same URL with `.md` appended, or via `Accept: text/markdown`.\n"
      corpus.sort_by { |e| e[:url] }.each do |entry|
        out << "\n---\n\n"
        out << "# #{entry[:title]}\n" if entry[:title]
        out << "Source: #{base}#{entry[:url]}\n\n"
        out << entry[:body] << "\n"
      end
      RawFile.new(site, "", "llms-full.txt", out)
    end
  end
end
