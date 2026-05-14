export default async function(shared, config) {
  console.log("[preview] data_source called", { previewUrl: shared.wc.proxy.previewUrl })
  return { previewUrl: shared.wc.proxy.previewUrl || null }
}
