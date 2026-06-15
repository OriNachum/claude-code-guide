// _worker.js — content negotiation for claude-code-guide.org (Cloudflare Pages,
// advanced mode).
//
// The site is deployed as a Cloudflare Pages project serving the Jekyll build
// (_site). A file named `_worker.js` at the root of the deploy output puts Pages
// into "advanced mode": every request is routed here, and static assets are
// fetched via env.ASSETS.fetch() (Pages provides the ASSETS fetcher
// automatically — no wrangler binding needed). This is the Pages equivalent of a
// Workers static-assets Worker; a plain wrangler.jsonc `main` is NOT honored by a
// Pages git build.
//
// It lets agents request markdown instead of HTML:
//
//   • GET /docs/getting-started   with `Accept: text/markdown`  -> the markdown twin
//   • GET /docs/getting-started.md  (explicit)                  -> the markdown twin
//   • everything else                                           -> the HTML build
//
// The .md twins are produced at build time by _plugins/llm_markdown.rb. The
// path scheme below MUST stay in lockstep with that plugin's `twin_relpath`.
//
// Source lives at _worker.js; Jekyll copies it verbatim to the build root via
// `include:` in _config.yml.

const MARKDOWN_TYPE = "text/markdown; charset=utf-8";

// Map an HTML page path to its markdown twin path. Returns null when no twin
// applies. "/" has no twin (the home body lives in a layout) — we hand agents
// the curated llms.txt index instead.
function markdownTwin(pathname) {
  if (pathname === "" || pathname === "/") return "/llms.txt";
  if (pathname.endsWith("/")) return pathname.slice(0, -1) + ".md";
  if (pathname.endsWith(".html")) return pathname.slice(0, -5) + ".md";
  // Extensionless "pretty" path (e.g. /docs/getting-started) — the same twin as
  // its trailing-slash form, since clients often drop the slash. A "." in the
  // last segment marks a real asset (e.g. /assets/app.js, /favicon.ico), which
  // has no twin.
  const lastSegment = pathname.slice(pathname.lastIndexOf("/") + 1);
  if (!lastSegment.includes(".")) return pathname + ".md";
  return null;
}

// True when the client expresses a preference for markdown. A substring check
// is sufficient for agent clients that opt in deliberately; we don't parse
// q-values.
function wantsMarkdown(request) {
  return /\btext\/markdown\b/i.test(request.headers.get("Accept") || "");
}

// Add "Accept" to the response's Vary header without clobbering any value the
// upstream asset already set, and without duplicating the token.
function addVaryAccept(headers) {
  const existing = headers.get("Vary");
  if (!existing) {
    headers.set("Vary", "Accept");
    return;
  }
  const hasAccept = existing
    .split(",")
    .some((v) => v.trim().toLowerCase() === "accept");
  if (!hasAccept) headers.set("Vary", existing + ", Accept");
}

function asMarkdown(resp) {
  const out = new Response(resp.body, resp);
  out.headers.set("Content-Type", MARKDOWN_TYPE);
  addVaryAccept(out.headers);
  return out;
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    // A malformed %-escape in the path makes decodeURIComponent throw, which
    // would 500 the request. Fall back to the raw pathname instead.
    let pathname = url.pathname;
    try {
      pathname = decodeURIComponent(url.pathname);
    } catch {
      pathname = url.pathname;
    }
    const readOnly = request.method === "GET" || request.method === "HEAD";

    // 1. Explicit .md request — label it markdown regardless of Accept.
    if (pathname.endsWith(".md")) {
      const resp = await env.ASSETS.fetch(request);
      return resp.status === 200 ? asMarkdown(resp) : resp;
    }

    // 2. Content negotiation — markdown asked for on an HTML URL.
    if (readOnly && wantsMarkdown(request)) {
      const twin = markdownTwin(pathname);
      if (twin) {
        const twinURL = new URL(url);
        twinURL.pathname = twin;
        const mdResp = await env.ASSETS.fetch(new Request(twinURL, request));
        if (mdResp.status === 200) return asMarkdown(mdResp);
        // No twin on disk — fall through to the HTML response.
      }
    }

    // 3. Default — serve the static asset. Only key the edge cache on Accept
    //    for paths that can actually be content-negotiated into markdown (HTML
    //    pages, pretty URLs, home). Real assets (css/js/img) have no twin, so
    //    adding Vary: Accept would only fragment their cache.
    const resp = await env.ASSETS.fetch(request);
    const out = new Response(resp.body, resp);
    if (markdownTwin(pathname) !== null) {
      addVaryAccept(out.headers);
    }
    return out;
  },
};
