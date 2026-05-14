export default async function(shared, config) {
  console.log("[terminal] data_source called", { status: shared.wc.proxy.status })
  return { status: shared.wc.proxy.status || "waiting" }
}
