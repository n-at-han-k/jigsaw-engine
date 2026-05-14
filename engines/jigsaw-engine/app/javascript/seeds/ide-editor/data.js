export default async function(shared, config) {

  console.log("[editor] data_source called", {
    openFiles: shared.editor.proxy.openFiles,
    activeFile: shared.editor.proxy.activeFile
  })

  const p = shared.editor.proxy

  return {
    openFiles: p.openFiles || [],
    activeFile: p.activeFile || null,
    fileContents: p.fileContents || {},
    _shared: shared,
  }
}
