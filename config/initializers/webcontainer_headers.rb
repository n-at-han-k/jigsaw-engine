# WebContainer API requires these headers to enable SharedArrayBuffer
# (Cross-Origin Isolation).
# Using "credentialless" instead of "require-corp" so cross-origin CDN
# resources (esm.sh, etc.) are not blocked.
Rails.application.config.action_dispatch.default_headers.merge!(
  "Cross-Origin-Embedder-Policy" => "credentialless",
  "Cross-Origin-Opener-Policy"   => "same-origin"
)
