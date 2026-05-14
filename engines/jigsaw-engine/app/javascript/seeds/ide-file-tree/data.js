import { WebContainer } from "@webcontainer/api"

async function buildFileTree(container, path = ".") {
  const entries = await container.fs.readdir(path, { withFileTypes: true })
  const nodes = []
  for (const entry of entries) {
    if (entry.name === "node_modules" || entry.name === ".git") continue
    const fullPath = path === "." ? entry.name : path + "/" + entry.name
    if (entry.isDirectory()) {
      nodes.push({ name: entry.name, path: fullPath, type: "directory", children: await buildFileTree(container, fullPath) })
    } else {
      nodes.push({ name: entry.name, path: fullPath, type: "file" })
    }
  }
  return nodes.sort((a, b) => {
    if (a.type === b.type) return a.name.localeCompare(b.name)
    return a.type === "directory" ? -1 : 1
  })
}

export default async function(shared, config) {
  console.log("[filetree] data_source called")
  const wc = shared.wc.proxy
  const editor = shared.editor.proxy

  if (!window.__wc && !window.__wcBooting) {
    try {
      window.__wcBooting = true
      console.log("[filetree] booting WebContainer...")
      wc.status = "booting"
      const container = await WebContainer.boot()
      window.__wc = container
      console.log("[filetree] WebContainer booted", container)
      wc.status = "ready"
      console.log("[filetree] building file tree...")
      wc.fileTree = await buildFileTree(container)
      console.log("[filetree] file tree built", wc.fileTree)
    } catch (err) {
      console.error("[filetree] ERROR during boot:", err)
      wc.status = "error"
    }
  }

  console.log("[filetree] returning data", { tree: wc.fileTree, activeFile: editor.activeFile })
  return {
    tree: wc.fileTree || [],
    activeFile: editor.activeFile,
    _shared: shared,
  }
}
