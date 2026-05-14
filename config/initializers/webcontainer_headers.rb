# WebContainer API requires these headers to enable SharedArrayBuffer
# (Cross-Origin Isolation).
Rails.application.config.action_dispatch.default_headers.merge!(
  "Cross-Origin-Embedder-Policy" => "require-corp",
  "Cross-Origin-Opener-Policy"   => "same-origin"
)
