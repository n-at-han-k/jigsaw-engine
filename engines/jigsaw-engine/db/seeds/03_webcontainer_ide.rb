module Jigsaw
  IDE_CONFIG = {
    "type"    => "grid",
    "areas"   => [
      ["filetree", "editor",   "preview"],
      ["filetree", "terminal", "preview"]
    ],
    "columns" => ["220px", "1fr", "1fr"],
    "rows"    => ["1fr", "250px"],
    "gridWidth"  => "100vw",
    "gridHeight" => "100vh",
    "rowGap" => 0, "colGap" => 0,
    "rowGapUnit" => "px", "colGapUnit" => "px"
  }.freeze

  page = Page.find_or_initialize_by(path: "ide")
  page.title = "WebContainer IDE"
  page.save!

  layout = page.layout || page.build_layout
  layout.name = "IDE Layout"
  layout.config = IDE_CONFIG
  layout.save!
  layout.sync_slots

  # ─── Slot 1: filetree ───────────────────────────────────────────────

  layout.slots.find_by!(area_name: "filetree").update!(
    render_language: "jsx",
    shares: ["wc", "editor"],
    config: {},
    data_source: <<~JS,
      import { WebContainer } from "@webcontainer/api"

      const TEMPLATE = {
        "package.json": {
          file: {
            contents: JSON.stringify(
              {
                name: "vite-react-app",
                private: true,
                version: "0.0.0",
                type: "module",
                scripts: {
                  dev: "vite",
                  build: "vite build",
                  preview: "vite preview",
                },
                dependencies: {
                  react: "^18.2.0",
                  "react-dom": "^18.2.0",
                },
                devDependencies: {
                  "@types/react": "^18.2.43",
                  "@types/react-dom": "^18.2.17",
                  "@vitejs/plugin-react": "^4.2.1",
                  typescript: "^5.2.2",
                  vite: "^5.0.0",
                },
              },
              null,
              2
            ),
          },
        },
        ".npmrc": {
          file: {
            contents: "shamefully-hoist=true\\nstrict-peer-dependencies=false\\n",
          },
        },
        public: {
          directory: {
            "vite.svg": {
              file: {
                contents: '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class="iconify iconify--logos" width="31.88" height="32" preserveAspectRatio="xMidYMid meet" viewBox="0 0 256 257"><defs><linearGradient id="IconifyId1813088fe1fbc01fb466" x1="-.828%" x2="57.636%" y1="7.652%" y2="78.411%"><stop offset="0%" stop-color="#41D1FF"></stop><stop offset="100%" stop-color="#BD34FE"></stop></linearGradient><linearGradient id="IconifyId1813088fe1fbc01fb467" x1="43.376%" x2="50.316%" y1="2.242%" y2="89.03%"><stop offset="0%" stop-color="#FFEA83"></stop><stop offset="8.333%" stop-color="#FFDD35"></stop><stop offset="100%" stop-color="#FFA800"></stop></linearGradient></defs><path fill="url(#IconifyId1813088fe1fbc01fb466)" d="M255.153 37.938L134.897 252.976c-2.483 4.44-8.862 4.466-11.382.048L.875 37.958c-2.746-4.814 1.371-10.646 6.827-9.67l120.385 21.517a6.537 6.537 0 0 0 2.322-.004l117.867-21.483c5.438-.991 9.574 4.796 6.877 9.62Z"></path><path fill="url(#IconifyId1813088fe1fbc01fb467)" d="M185.432.063L96.44 17.501a3.268 3.268 0 0 0-2.634 3.014l-5.474 92.456a3.268 3.268 0 0 0 3.997 3.378l24.777-5.718c2.318-.535 4.413 1.507 3.936 3.838l-7.361 36.047c-.495 2.426 1.782 4.5 4.151 3.78l15.304-4.649c2.372-.72 4.652 1.36 4.15 3.788l-11.698 56.621c-.732 3.542 3.979 5.473 5.943 2.437l1.313-2.028l72.516-144.72c1.215-2.423-.88-5.186-3.54-4.672l-25.505 4.922c-2.396.462-4.435-1.77-3.759-4.114l16.646-57.705c.677-2.35-1.37-4.583-3.769-4.113Z"></path></svg>',
              },
            },
          },
        },
        "index.html": {
          file: {
            contents: [
              '<!doctype html>',
              '<html lang="en">',
              '  <head>',
              '    <meta charset="UTF-8" />',
              '    <meta name="viewport" content="width=device-width, initial-scale=1.0" />',
              '    <title>Vite + React</title>',
              '  </head>',
              '  <body>',
              '    <div id="root"></div>',
              '    <script type="module" src="/src/main.jsx"><\\/script>',
              '  </body>',
              '</html>',
            ].join("\\n"),
          },
        },
        "vite.config.js": {
          file: {
            contents: [
              "import { defineConfig } from 'vite'",
              "import react from '@vitejs/plugin-react'",
              "",
              "export default defineConfig({",
              "  plugins: [react()],",
              "})",
            ].join("\\n"),
          },
        },
        src: {
          directory: {
            assets: {
              directory: {
                "react.svg": {
                  file: {
                    contents: '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class="iconify iconify--logos" width="35.93" height="32" preserveAspectRatio="xMidYMid meet" viewBox="0 0 256 228"><path fill="#00D8FF" d="M210.483 73.824a171.49 171.49 0 0 0-8.24-2.597c.465-1.9.893-3.777 1.273-5.621c6.238-30.281 2.16-54.676-11.769-62.708c-13.355-7.7-35.196.329-57.254 19.526a171.23 171.23 0 0 0-6.375 5.848a155.866 155.866 0 0 0-4.241-3.917C100.759 3.829 77.587-4.822 63.673 3.233C50.33 10.957 46.379 33.89 51.995 62.588a170.974 170.974 0 0 0 1.892 8.48c-3.28.932-6.445 1.924-9.474 2.98C17.309 83.498 0 98.307 0 113.668c0 15.865 18.582 31.778 46.812 41.427a145.52 145.52 0 0 0 6.921 2.165a167.467 167.467 0 0 0-2.01 9.138c-5.354 28.2-1.173 50.591 12.134 58.266c13.744 7.926 36.812-.22 59.273-19.855a145.567 145.567 0 0 0 5.342-4.923a168.064 168.064 0 0 0 6.92 6.314c21.758 18.722 43.246 26.282 56.54 18.586c13.731-7.949 18.194-32.003 12.4-61.268a145.016 145.016 0 0 0-1.535-6.842c1.62-.48 3.21-.974 4.76-1.488c29.348-9.723 48.443-25.443 48.443-41.52c0-15.417-17.868-30.326-45.517-39.844Z"></path></svg>',
                  },
                },
              },
            },
            "main.jsx": {
              file: {
                contents: [
                  "import { StrictMode } from 'react'",
                  "import { createRoot } from 'react-dom/client'",
                  "import './index.css'",
                  "import App from './App.jsx'",
                  "",
                  "createRoot(document.getElementById('root')).render(",
                  "  <StrictMode>",
                  "    <App />",
                  "  </StrictMode>,",
                  ")",
                ].join("\\n"),
              },
            },
            "App.jsx": {
              file: {
                contents: [
                  "import { useState } from 'react'",
                  "import reactLogo from './assets/react.svg'",
                  "import viteLogo from '/vite.svg'",
                  "import './App.css'",
                  "",
                  "function App() {",
                  "  const [count, setCount] = useState(0)",
                  "",
                  "  return (",
                  "    <>",
                  "      <div>",
                  '        <a href=\\"https://vite.dev\\" target=\\"_blank\\">',
                  '          <img src={viteLogo} className=\\"logo\\" alt=\\"Vite logo\\" />',
                  "        </a>",
                  '        <a href=\\"https://react.dev\\" target=\\"_blank\\">',
                  '          <img src={reactLogo} className=\\"logo react\\" alt=\\"React logo\\" />',
                  "        </a>",
                  "      </div>",
                  "      <h1>Vite + React</h1>",
                  '      <div className=\\"card\\">',
                  "        <button onClick={() => setCount((count) => count + 1)}>",
                  "          count is {count}",
                  "        </button>",
                  "        <p>",
                  "          Edit <code>src/App.jsx</code> and save to test HMR",
                  "        </p>",
                  "      </div>",
                  '      <p className=\\"read-the-docs\\">',
                  "        Click on the Vite and React logos to learn more",
                  "      </p>",
                  "    </>",
                  "  )",
                  "}",
                  "",
                  "export default App",
                ].join("\\n"),
              },
            },
            "App.css": {
              file: {
                contents: [
                  "#root {",
                  "  max-width: 1280px;",
                  "  margin: 0 auto;",
                  "  padding: 2rem;",
                  "  text-align: center;",
                  "}",
                  "",
                  ".logo {",
                  "  height: 6em;",
                  "  padding: 1.5em;",
                  "  will-change: filter;",
                  "  transition: filter 300ms;",
                  "}",
                  ".logo:hover {",
                  "  filter: drop-shadow(0 0 2em #646cffaa);",
                  "}",
                  ".logo.react:hover {",
                  "  filter: drop-shadow(0 0 2em #61dafbaa);",
                  "}",
                  "",
                  "@keyframes logo-spin {",
                  "  from { transform: rotate(0deg); }",
                  "  to { transform: rotate(360deg); }",
                  "}",
                  "",
                  "@media (prefers-reduced-motion: no-preference) {",
                  "  a:nth-of-type(2) .logo {",
                  "    animation: logo-spin infinite 20s linear;",
                  "  }",
                  "}",
                  "",
                  ".card { padding: 2em; }",
                  ".read-the-docs { color: #888; }",
                ].join("\\n"),
              },
            },
            "index.css": {
              file: {
                contents: [
                  ":root {",
                  "  font-family: system-ui, Avenir, Helvetica, Arial, sans-serif;",
                  "  line-height: 1.5;",
                  "  font-weight: 400;",
                  "  color-scheme: light dark;",
                  "  color: rgba(255, 255, 255, 0.87);",
                  "  background-color: #242424;",
                  "  font-synthesis: none;",
                  "  text-rendering: optimizeLegibility;",
                  "  -webkit-font-smoothing: antialiased;",
                  "  -moz-osx-font-smoothing: grayscale;",
                  "}",
                  "",
                  "a { font-weight: 500; color: #646cff; text-decoration: inherit; }",
                  "a:hover { color: #535bf2; }",
                  "",
                  "body {",
                  "  margin: 0;",
                  "  display: flex;",
                  "  place-items: center;",
                  "  min-width: 320px;",
                  "  min-height: 100vh;",
                  "}",
                  "",
                  "h1 { font-size: 3.2em; line-height: 1.1; }",
                  "",
                  "button {",
                  "  border-radius: 8px;",
                  "  border: 1px solid transparent;",
                  "  padding: 0.6em 1.2em;",
                  "  font-size: 1em;",
                  "  font-weight: 500;",
                  "  font-family: inherit;",
                  "  background-color: #1a1a1a;",
                  "  cursor: pointer;",
                  "  transition: border-color 0.25s;",
                  "}",
                  "button:hover { border-color: #646cff; }",
                  "button:focus, button:focus-visible { outline: 4px auto -webkit-focus-ring-color; }",
                ].join("\\n"),
              },
            },
          },
        },
      }

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
        const wc = shared.wc.proxy
        const editor = shared.editor.proxy

        // Boot WebContainer singleton
        if (!window.__wc) {
          const { WebContainer } = await import("@webcontainer/api")
          wc.status = "booting"

          const container = await WebContainer.boot()
          window.__wc = container

          // Mount files
          wc.status = "mounting"
          await container.mount(TEMPLATE)

          // Build initial file tree
          const tree = await buildFileTree(container)
          wc.fileTree = tree

          // Install dependencies
          wc.status = "installing"
          const installProcess = await container.spawn("pnpm", ["install"])
          installProcess.output.pipeTo(
            new WritableStream({
              write(data) {
                if (window.__wcTermWrite) window.__wcTermWrite(data)
              },
            })
          )
          const installExitCode = await installProcess.exit
          if (installExitCode !== 0) {
            wc.status = "error"
            return { tree: wc.fileTree || [], activeFile: editor.activeFile, _shared: shared }
          }

          // Start dev server
          wc.status = "running"
          const devProcess = await container.spawn("pnpm", ["run", "dev"])
          devProcess.output.pipeTo(
            new WritableStream({
              write(data) {
                if (window.__wcTermWrite) window.__wcTermWrite(data)
              },
            })
          )

          container.on("server-ready", (_port, url) => {
            wc.previewUrl = url
            wc.status = "ready"
          })

          // Rebuild file tree after install
          wc.fileTree = await buildFileTree(container)

          // Poll for file tree changes
          setInterval(async () => {
            try {
              wc.fileTree = await buildFileTree(container)
            } catch {}
          }, 3000)
        }

        return {
          tree: wc.fileTree || [],
          activeFile: editor.activeFile,
          _shared: shared,
        }
      }
    JS
    render_source: <<~JSX,
      import React, { useState } from "react"
      import { createRoot } from "react-dom/client"
      import {
        ChevronRight,
        ChevronDown,
        File,
        Folder,
        FolderOpen,
        FilePlus,
        FolderPlus,
        Trash2,
      } from "lucide-react"
      import * as ContextMenu from "@radix-ui/react-context-menu"
      import * as Dialog from "@radix-ui/react-dialog"

      function FileTreeItem({ node, level, activeFile, onOpenFile, onRefresh }) {
        const [isExpanded, setIsExpanded] = useState(false)
        const [showNewFileDialog, setShowNewFileDialog] = useState(false)
        const [showNewFolderDialog, setShowNewFolderDialog] = useState(false)
        const [newItemName, setNewItemName] = useState("")

        const handleClick = async () => {
          if (node.type === "directory") {
            setIsExpanded(!isExpanded)
          } else {
            try {
              const content = await window.__wc.fs.readFile(node.path, "utf-8")
              onOpenFile(node.path, content)
            } catch (error) {
              console.error("Failed to read file:", error)
            }
          }
        }

        const handleCreateFile = async () => {
          if (!newItemName.trim()) return
          const newPath =
            node.type === "directory" ? node.path + "/" + newItemName : node.path + "/../" + newItemName
          try {
            await window.__wc.fs.writeFile(newPath, "")
            onRefresh()
            setShowNewFileDialog(false)
            setNewItemName("")
          } catch (error) {
            console.error("Failed to create file:", error)
          }
        }

        const handleCreateFolder = async () => {
          if (!newItemName.trim()) return
          const newPath =
            node.type === "directory" ? node.path + "/" + newItemName : node.path + "/../" + newItemName
          try {
            await window.__wc.fs.mkdir(newPath, { recursive: true })
            onRefresh()
            setShowNewFolderDialog(false)
            setNewItemName("")
          } catch (error) {
            console.error("Failed to create folder:", error)
          }
        }

        const handleDelete = async () => {
          if (!confirm("Are you sure you want to delete " + node.name + "?")) return
          try {
            await window.__wc.fs.rm(node.path, { recursive: true })
            onRefresh()
          } catch (error) {
            console.error("Failed to delete:", error)
          }
        }

        const isActive = activeFile === node.path

        return (
          <div>
            <ContextMenu.Root>
              <ContextMenu.Trigger asChild>
                <div
                  className={"flex items-center gap-1 px-2 py-1 cursor-pointer hover:bg-gray-700 " + (isActive ? "bg-blue-600" : "")}
                  style={{ paddingLeft: (level * 12 + 8) + "px" }}
                  onClick={handleClick}
                >
                  {node.type === "directory" ? (
                    <>
                      {isExpanded ? (
                        <ChevronDown size={16} className="text-gray-400 flex-shrink-0" />
                      ) : (
                        <ChevronRight size={16} className="text-gray-400 flex-shrink-0" />
                      )}
                      {isExpanded ? (
                        <FolderOpen size={16} className="text-blue-400 flex-shrink-0" />
                      ) : (
                        <Folder size={16} className="text-blue-400 flex-shrink-0" />
                      )}
                    </>
                  ) : (
                    <>
                      <span className="w-4 flex-shrink-0" />
                      <File size={16} className="text-gray-400 flex-shrink-0" />
                    </>
                  )}
                  <span className="text-sm text-gray-200 truncate">{node.name}</span>
                </div>
              </ContextMenu.Trigger>

              <ContextMenu.Portal>
                <ContextMenu.Content className="min-w-[180px] bg-gray-800 rounded-md overflow-hidden p-1 shadow-lg border border-gray-700">
                  <ContextMenu.Item
                    className="flex items-center gap-2 px-2 py-1.5 text-sm text-gray-200 cursor-pointer hover:bg-gray-700 rounded outline-none"
                    onClick={() => setShowNewFileDialog(true)}
                  >
                    <FilePlus size={16} />
                    New File
                  </ContextMenu.Item>
                  <ContextMenu.Item
                    className="flex items-center gap-2 px-2 py-1.5 text-sm text-gray-200 cursor-pointer hover:bg-gray-700 rounded outline-none"
                    onClick={() => setShowNewFolderDialog(true)}
                  >
                    <FolderPlus size={16} />
                    New Folder
                  </ContextMenu.Item>
                  <ContextMenu.Separator className="h-[1px] bg-gray-700 my-1" />
                  <ContextMenu.Item
                    className="flex items-center gap-2 px-2 py-1.5 text-sm text-red-400 cursor-pointer hover:bg-gray-700 rounded outline-none"
                    onClick={handleDelete}
                  >
                    <Trash2 size={16} />
                    Delete
                  </ContextMenu.Item>
                </ContextMenu.Content>
              </ContextMenu.Portal>
            </ContextMenu.Root>

            <Dialog.Root open={showNewFileDialog} onOpenChange={setShowNewFileDialog}>
              <Dialog.Portal>
                <Dialog.Overlay className="fixed inset-0 bg-black/50" />
                <Dialog.Content className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-gray-800 rounded-lg p-6 w-96 shadow-xl">
                  <Dialog.Title className="text-lg font-semibold text-white mb-4">
                    New File
                  </Dialog.Title>
                  <input
                    type="text"
                    value={newItemName}
                    onChange={(e) => setNewItemName(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleCreateFile()}
                    placeholder="filename.txt"
                    className="w-full px-3 py-2 bg-gray-900 text-white rounded border border-gray-700 focus:border-blue-500 outline-none"
                    autoFocus
                  />
                  <div className="flex justify-end gap-2 mt-4">
                    <button
                      onClick={() => setShowNewFileDialog(false)}
                      className="px-4 py-2 text-gray-400 hover:text-white"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleCreateFile}
                      className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                    >
                      Create
                    </button>
                  </div>
                </Dialog.Content>
              </Dialog.Portal>
            </Dialog.Root>

            <Dialog.Root open={showNewFolderDialog} onOpenChange={setShowNewFolderDialog}>
              <Dialog.Portal>
                <Dialog.Overlay className="fixed inset-0 bg-black/50" />
                <Dialog.Content className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-gray-800 rounded-lg p-6 w-96 shadow-xl">
                  <Dialog.Title className="text-lg font-semibold text-white mb-4">
                    New Folder
                  </Dialog.Title>
                  <input
                    type="text"
                    value={newItemName}
                    onChange={(e) => setNewItemName(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleCreateFolder()}
                    placeholder="folder-name"
                    className="w-full px-3 py-2 bg-gray-900 text-white rounded border border-gray-700 focus:border-blue-500 outline-none"
                    autoFocus
                  />
                  <div className="flex justify-end gap-2 mt-4">
                    <button
                      onClick={() => setShowNewFolderDialog(false)}
                      className="px-4 py-2 text-gray-400 hover:text-white"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleCreateFolder}
                      className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                    >
                      Create
                    </button>
                  </div>
                </Dialog.Content>
              </Dialog.Portal>
            </Dialog.Root>

            {node.type === "directory" && isExpanded && node.children && (
              <div>
                {node.children.map((child) => (
                  <FileTreeItem
                    key={child.path}
                    node={child}
                    level={level + 1}
                    activeFile={activeFile}
                    onOpenFile={onOpenFile}
                    onRefresh={onRefresh}
                  />
                ))}
              </div>
            )}
          </div>
        )
      }

      function FileTree({ tree, activeFile, onOpenFile, onRefresh }) {
        const [showNewFileDialog, setShowNewFileDialog] = useState(false)
        const [showNewFolderDialog, setShowNewFolderDialog] = useState(false)
        const [newItemName, setNewItemName] = useState("")

        const handleCreateFile = async () => {
          if (!newItemName.trim()) return
          try {
            await window.__wc.fs.writeFile(newItemName, "")
            onRefresh()
            setShowNewFileDialog(false)
            setNewItemName("")
          } catch (error) {
            console.error("Failed to create file:", error)
          }
        }

        const handleCreateFolder = async () => {
          if (!newItemName.trim()) return
          try {
            await window.__wc.fs.mkdir(newItemName, { recursive: true })
            onRefresh()
            setShowNewFolderDialog(false)
            setNewItemName("")
          } catch (error) {
            console.error("Failed to create folder:", error)
          }
        }

        return (
          <div className="h-full bg-gray-800 overflow-auto">
            <ContextMenu.Root>
              <ContextMenu.Trigger asChild>
                <div className="h-full">
                  <div className="p-2 border-b border-gray-700 flex items-center justify-between">
                    <h3 className="text-sm font-semibold text-gray-300">FILES</h3>
                    <div className="flex gap-1">
                      <button
                        onClick={() => setShowNewFileDialog(true)}
                        className="p-1 hover:bg-gray-700 rounded"
                        title="New File"
                      >
                        <FilePlus size={16} className="text-gray-400" />
                      </button>
                      <button
                        onClick={() => setShowNewFolderDialog(true)}
                        className="p-1 hover:bg-gray-700 rounded"
                        title="New Folder"
                      >
                        <FolderPlus size={16} className="text-gray-400" />
                      </button>
                    </div>
                  </div>
                  <div className="py-1">
                    {tree.map((node) => (
                      <FileTreeItem
                        key={node.path}
                        node={node}
                        level={0}
                        activeFile={activeFile}
                        onOpenFile={onOpenFile}
                        onRefresh={onRefresh}
                      />
                    ))}
                  </div>
                </div>
              </ContextMenu.Trigger>

              <ContextMenu.Portal>
                <ContextMenu.Content className="min-w-[180px] bg-gray-800 rounded-md overflow-hidden p-1 shadow-lg border border-gray-700">
                  <ContextMenu.Item
                    className="flex items-center gap-2 px-2 py-1.5 text-sm text-gray-200 cursor-pointer hover:bg-gray-700 rounded outline-none"
                    onClick={() => setShowNewFileDialog(true)}
                  >
                    <FilePlus size={16} />
                    New File
                  </ContextMenu.Item>
                  <ContextMenu.Item
                    className="flex items-center gap-2 px-2 py-1.5 text-sm text-gray-200 cursor-pointer hover:bg-gray-700 rounded outline-none"
                    onClick={() => setShowNewFolderDialog(true)}
                  >
                    <FolderPlus size={16} />
                    New Folder
                  </ContextMenu.Item>
                </ContextMenu.Content>
              </ContextMenu.Portal>
            </ContextMenu.Root>

            <Dialog.Root open={showNewFileDialog} onOpenChange={setShowNewFileDialog}>
              <Dialog.Portal>
                <Dialog.Overlay className="fixed inset-0 bg-black/50" />
                <Dialog.Content className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-gray-800 rounded-lg p-6 w-96 shadow-xl">
                  <Dialog.Title className="text-lg font-semibold text-white mb-4">
                    New File
                  </Dialog.Title>
                  <input
                    type="text"
                    value={newItemName}
                    onChange={(e) => setNewItemName(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleCreateFile()}
                    placeholder="filename.txt"
                    className="w-full px-3 py-2 bg-gray-900 text-white rounded border border-gray-700 focus:border-blue-500 outline-none"
                    autoFocus
                  />
                  <div className="flex justify-end gap-2 mt-4">
                    <button
                      onClick={() => setShowNewFileDialog(false)}
                      className="px-4 py-2 text-gray-400 hover:text-white"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleCreateFile}
                      className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                    >
                      Create
                    </button>
                  </div>
                </Dialog.Content>
              </Dialog.Portal>
            </Dialog.Root>

            <Dialog.Root open={showNewFolderDialog} onOpenChange={setShowNewFolderDialog}>
              <Dialog.Portal>
                <Dialog.Overlay className="fixed inset-0 bg-black/50" />
                <Dialog.Content className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-gray-800 rounded-lg p-6 w-96 shadow-xl">
                  <Dialog.Title className="text-lg font-semibold text-white mb-4">
                    New Folder
                  </Dialog.Title>
                  <input
                    type="text"
                    value={newItemName}
                    onChange={(e) => setNewItemName(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleCreateFolder()}
                    placeholder="folder-name"
                    className="w-full px-3 py-2 bg-gray-900 text-white rounded border border-gray-700 focus:border-blue-500 outline-none"
                    autoFocus
                  />
                  <div className="flex justify-end gap-2 mt-4">
                    <button
                      onClick={() => setShowNewFolderDialog(false)}
                      className="px-4 py-2 text-gray-400 hover:text-white"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleCreateFolder}
                      className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                    >
                      Create
                    </button>
                  </div>
                </Dialog.Content>
              </Dialog.Portal>
            </Dialog.Root>
          </div>
        )
      }

      export default function(data) {
        if (!this._root) this._root = createRoot(this.element)
        this._root.render(
          <FileTree
            tree={data.tree || []}
            activeFile={data.activeFile}
            onOpenFile={async (path, content) => {
              const p = data._shared.editor.proxy
              p.openFiles = [...new Set([...(p.openFiles || []), path])]
              p.activeFile = path
              p.fileContents = { ...(p.fileContents || {}), [path]: content }
            }}
            onRefresh={async () => {
              if (!window.__wc) return
              const { buildFileTree } = await import("@webcontainer/api").then(() => null).catch(() => null) || {}
              // Inline rebuild
              async function rebuild(container, p) {
                if (p === undefined) p = "."
                const entries = await container.fs.readdir(p, { withFileTypes: true })
                const nodes = []
                for (const entry of entries) {
                  if (entry.name === "node_modules" || entry.name === ".git") continue
                  const fullPath = p === "." ? entry.name : p + "/" + entry.name
                  if (entry.isDirectory()) {
                    nodes.push({ name: entry.name, path: fullPath, type: "directory", children: await rebuild(container, fullPath) })
                  } else {
                    nodes.push({ name: entry.name, path: fullPath, type: "file" })
                  }
                }
                return nodes.sort((a, b) => a.type === b.type ? a.name.localeCompare(b.name) : a.type === "directory" ? -1 : 1)
              }
              data._shared.wc.proxy.fileTree = await rebuild(window.__wc)
            }}
          />
        )
      }
    JSX
  )

  puts "[seeds] filetree slot updated"

  # ─── Slot 2: editor ─────────────────────────────────────────────────

  layout.slots.find_by!(area_name: "editor").update!(
    render_language: "jsx",
    shares: ["editor"],
    config: {},
    data_source: <<~JS,
      export default async function(shared, config) {
        const p = shared.editor.proxy
        return {
          openFiles: p.openFiles || [],
          activeFile: p.activeFile || null,
          fileContents: p.fileContents || {},
          _shared: shared,
        }
      }
    JS
    render_source: <<~JSX,
      import React, { useRef } from "react"
      import { createRoot } from "react-dom/client"
      import MonacoEditor from "@monaco-editor/react"
      import { X } from "lucide-react"

      function Editor({ openFiles, activeFile, fileContents, closeFile, setActiveFile, updateFileContent }) {
        const editorRef = useRef(null)

        const handleEditorChange = async (value) => {
          if (!activeFile || value === undefined) return

          updateFileContent(activeFile, value)

          // Auto-save to WebContainer
          try {
            await window.__wc.fs.writeFile(activeFile, value)
          } catch (error) {
            console.error("Failed to write file:", error)
          }
        }

        const getLanguage = (filename) => {
          const ext = filename.split(".").pop()?.toLowerCase()
          const languageMap = {
            js: "javascript",
            jsx: "javascript",
            ts: "typescript",
            tsx: "typescript",
            json: "json",
            html: "html",
            css: "css",
            md: "markdown",
          }
          return languageMap[ext || ""] || "plaintext"
        }

        return (
          <div className="h-full flex flex-col bg-gray-900">
            {/* Tabs */}
            <div className="flex items-center bg-gray-800 border-b border-gray-700 overflow-x-auto">
              {openFiles.length === 0 ? (
                <div className="flex-1 flex items-center justify-center text-gray-500 py-8">
                  <p>No file open. Select a file from the file tree.</p>
                </div>
              ) : (
                openFiles.map((file) => (
                  <div
                    key={file}
                    className={"flex items-center gap-2 px-4 py-2 border-r border-gray-700 cursor-pointer " +
                      (activeFile === file ? "bg-gray-900 text-white" : "bg-gray-800 text-gray-400")}
                    onClick={() => setActiveFile(file)}
                  >
                    <span className="text-sm whitespace-nowrap">{file.split("/").pop()}</span>
                    <button
                      onClick={(e) => {
                        e.stopPropagation()
                        closeFile(file)
                      }}
                      className="hover:bg-gray-700 rounded p-0.5"
                    >
                      <X size={14} />
                    </button>
                  </div>
                ))
              )}
            </div>

            {/* Editor */}
            <div className="flex-1">
              {activeFile && (
                <MonacoEditor
                  height="100%"
                  language={getLanguage(activeFile)}
                  value={fileContents[activeFile] || ""}
                  onChange={handleEditorChange}
                  theme="vs-dark"
                  options={{
                    minimap: { enabled: false },
                    fontSize: 14,
                    lineNumbers: "on",
                    automaticLayout: true,
                    tabSize: 2,
                  }}
                  onMount={(editor) => {
                    editorRef.current = editor
                  }}
                />
              )}
            </div>
          </div>
        )
      }

      export default function(data) {
        if (!this._root) this._root = createRoot(this.element)
        this._root.render(
          <Editor
            openFiles={data.openFiles}
            activeFile={data.activeFile}
            fileContents={data.fileContents}
            setActiveFile={(path) => {
              data._shared.editor.proxy.activeFile = path
            }}
            closeFile={(path) => {
              const p = data._shared.editor.proxy
              const newOpen = (p.openFiles || []).filter((f) => f !== path)
              const newContents = { ...(p.fileContents || {}) }
              delete newContents[path]
              p.openFiles = newOpen
              p.fileContents = newContents
              p.activeFile = p.activeFile === path ? newOpen[0] || null : p.activeFile
            }}
            updateFileContent={(path, content) => {
              const p = data._shared.editor.proxy
              p.fileContents = { ...(p.fileContents || {}), [path]: content }
            }}
          />
        )
      }
    JSX
  )

  puts "[seeds] editor slot updated"

  # ─── Slot 3: terminal ───────────────────────────────────────────────

  layout.slots.find_by!(area_name: "terminal").update!(
    render_language: "jsx",
    shares: ["wc"],
    config: {},
    data_source: <<~JS,
      export default async function(shared, config) {
        return { status: shared.wc.proxy.status || "waiting" }
      }
    JS
    render_source: <<~JSX,
      import React, { useEffect, useRef, useState } from "react"
      import { createRoot } from "react-dom/client"
      import { Terminal as TerminalIcon, Trash2, ArrowDown } from "lucide-react"

      function TerminalPanel() {
        const terminalRef = useRef(null)
        const xtermRef = useRef(null)
        const fitAddonRef = useRef(null)
        const [showScrollButton, setShowScrollButton] = useState(false)

        useEffect(() => {
          if (!terminalRef.current || xtermRef.current) return

          Promise.all([
            import("xterm"),
            import("xterm-addon-fit"),
            import("xterm-addon-web-links"),
          ]).then(([xtermMod, fitMod, webLinksMod]) => {
            const { Terminal } = xtermMod
            const { FitAddon } = fitMod
            const { WebLinksAddon } = webLinksMod

            // Load xterm CSS
            if (!document.getElementById("xterm-css")) {
              const link = document.createElement("link")
              link.id = "xterm-css"
              link.rel = "stylesheet"
              link.href = "https://esm.sh/xterm@5/css/xterm.css"
              document.head.appendChild(link)
            }

            const xterm = new Terminal({
              cursorBlink: true,
              cursorStyle: "block",
              fontSize: 14,
              fontFamily: '"Cascadia Code", Menlo, Monaco, "Courier New", monospace',
              theme: {
                background: "#0a0a0a",
                foreground: "#d4d4d4",
                cursor: "#00ff00",
                cursorAccent: "#000000",
                selectionBackground: "#3a3d41",
                black: "#000000",
                red: "#cd3131",
                green: "#0dbc79",
                yellow: "#e5e510",
                blue: "#2472c8",
                magenta: "#bc3fbc",
                cyan: "#11a8cd",
                white: "#e5e5e5",
                brightBlack: "#666666",
                brightRed: "#f14c4c",
                brightGreen: "#23d18b",
                brightYellow: "#f5f543",
                brightBlue: "#3b8eea",
                brightMagenta: "#d670d6",
                brightCyan: "#29b8db",
                brightWhite: "#ffffff",
              },
              scrollback: 10000,
              convertEol: true,
              allowProposedApi: true,
            })

            const fitAddon = new FitAddon()
            const webLinksAddon = new WebLinksAddon()

            xterm.loadAddon(fitAddon)
            xterm.loadAddon(webLinksAddon)
            xterm.open(terminalRef.current)

            xtermRef.current = xterm
            fitAddonRef.current = fitAddon

            // Register globally so other slots can write to terminal
            window.__wcTermWrite = (data) => xterm.write(data)

            // Delay fit to ensure container size is correct
            requestAnimationFrame(() => {
              requestAnimationFrame(() => {
                try { fitAddon.fit() } catch (e) { console.warn("Fit failed:", e) }
              })
            })

            // Watch scroll position
            let scrollTimeout
            xterm.onScroll(() => {
              clearTimeout(scrollTimeout)
              scrollTimeout = setTimeout(() => {
                try {
                  const buffer = xterm.buffer.active
                  if (buffer) {
                    const isAtBottom = buffer.viewportY >= buffer.baseY + buffer.cursorY - xterm.rows
                    setShowScrollButton(!isAtBottom)
                  }
                } catch (e) {}
              }, 100)
            })

            // Welcome banner
            setTimeout(() => {
              xterm.writeln("\\x1b[1;36m\\u2554\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2557\\x1b[0m")
              xterm.writeln("\\x1b[1;36m\\u2551   WebContainer IDE Terminal          \\u2551\\x1b[0m")
              xterm.writeln("\\x1b[1;36m\\u255a\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u2550\\u255d\\x1b[0m")
              xterm.writeln("")

              let currentLine = ""
              let isProcessRunning = false

              const writePrompt = () => {
                xterm.write("\\x1b[1;32m\\u279c\\x1b[0m \\x1b[1;36m~\\x1b[0m ")
              }

              writePrompt()

              xterm.onData((data) => {
                if (isProcessRunning) return

                const code = data.charCodeAt(0)

                if (code === 13) {
                  // Enter
                  const command = currentLine.trim()
                  currentLine = ""
                  xterm.write("\\r\\n")

                  if (command) {
                    isProcessRunning = true
                    ;(async () => {
                      try {
                        const container = window.__wc
                        if (!container) {
                          xterm.writeln("\\x1b[1;31m\\u2716 WebContainer not ready\\x1b[0m")
                          return
                        }
                        const parts = command.split(" ")
                        const cmd = parts[0]
                        const args = parts.slice(1)

                        const process = await container.spawn(cmd, args)

                        process.output.pipeTo(
                          new WritableStream({
                            write(chunk) {
                              xterm.write(chunk)
                            },
                          })
                        )

                        await process.exit
                      } catch (error) {
                        xterm.writeln("\\x1b[1;31m\\u2716 Error: " + error + "\\x1b[0m")
                      } finally {
                        isProcessRunning = false
                        writePrompt()
                      }
                    })()
                  } else {
                    writePrompt()
                  }
                } else if (code === 127) {
                  // Backspace
                  if (currentLine.length > 0) {
                    currentLine = currentLine.slice(0, -1)
                    xterm.write("\\b \\b")
                  }
                } else if (code === 3) {
                  // Ctrl+C
                  if (isProcessRunning) {
                    xterm.write("^C\\r\\n")
                    isProcessRunning = false
                    writePrompt()
                  } else {
                    xterm.write("^C\\r\\n")
                    currentLine = ""
                    writePrompt()
                  }
                } else if (code >= 32 && code <= 126) {
                  // Printable chars
                  currentLine += data
                  xterm.write(data)
                }
              })
            }, 100)

            // Responsive resize
            const resizeObserver = new ResizeObserver(() => {
              try { fitAddon.fit() } catch (e) {}
            })
            resizeObserver.observe(terminalRef.current)
          })
        }, [])

        const handleClear = () => {
          if (xtermRef.current) {
            xtermRef.current.clear()
            xtermRef.current.writeln("\\x1b[1;32m\\u2713 Terminal cleared\\x1b[0m")
            xtermRef.current.write("\\r\\n\\x1b[1;32m\\u279c\\x1b[0m \\x1b[1;36m~\\x1b[0m ")
          }
        }

        const scrollToBottom = () => {
          if (xtermRef.current) {
            xtermRef.current.scrollToBottom()
            setShowScrollButton(false)
          }
        }

        return (
          <div className="h-full flex flex-col bg-black" style={{ position: "relative" }}>
            <div className="flex items-center justify-between px-4 py-2 bg-gray-900 border-b border-gray-700">
              <div className="flex items-center gap-2">
                <TerminalIcon size={16} className="text-green-400" />
                <h3 className="text-sm font-semibold text-gray-300">TERMINAL</h3>
                <span className="text-xs text-gray-500">Buffer: 10k lines</span>
              </div>
              <button
                onClick={handleClear}
                className="p-1 hover:bg-gray-800 rounded transition-colors"
                title="Clear terminal"
              >
                <Trash2 size={14} className="text-gray-400 hover:text-gray-200" />
              </button>
            </div>
            <div
              ref={terminalRef}
              className="flex-1 overflow-hidden"
              style={{ backgroundColor: "#0a0a0a", padding: "12px" }}
            />
            {showScrollButton && (
              <button
                onClick={scrollToBottom}
                className="absolute bottom-6 right-6 p-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-full shadow-lg transition-all hover:scale-110"
                title="Scroll to bottom"
              >
                <ArrowDown size={18} />
              </button>
            )}
          </div>
        )
      }

      export default function(data) {
        if (!this._root) this._root = createRoot(this.element)
        this._root.render(<TerminalPanel />)
      }
    JSX
  )

  puts "[seeds] terminal slot updated"

  # ─── Slot 4: preview ────────────────────────────────────────────────

  layout.slots.find_by!(area_name: "preview").update!(
    render_language: "jsx",
    shares: ["wc"],
    config: {},
    data_source: <<~JS,
      export default async function(shared, config) {
        return { previewUrl: shared.wc.proxy.previewUrl || null }
      }
    JS
    render_source: <<~JSX,
      import React from "react"
      import { createRoot } from "react-dom/client"
      import { RefreshCw } from "lucide-react"

      function Preview({ previewUrl }) {
        const [key, setKey] = React.useState(0)

        const handleRefresh = () => {
          setKey((prev) => prev + 1)
        }

        return (
          <div className="h-full flex flex-col bg-gray-900">
            <div className="flex items-center justify-between px-4 py-2 bg-gray-800 border-b border-gray-700">
              <h3 className="text-sm font-semibold text-gray-300">PREVIEW</h3>
              {previewUrl && (
                <button
                  onClick={handleRefresh}
                  className="p-1 hover:bg-gray-700 rounded"
                  title="Refresh preview"
                >
                  <RefreshCw size={16} className="text-gray-400" />
                </button>
              )}
            </div>
            <div className="flex-1 bg-white">
              {previewUrl ? (
                <iframe
                  key={key}
                  src={previewUrl}
                  className="w-full h-full border-0"
                  title="Preview"
                  sandbox="allow-scripts allow-same-origin allow-forms allow-modals"
                />
              ) : (
                <div className="flex items-center justify-center h-full text-gray-500">
                  <p>Starting dev server...</p>
                </div>
              )}
            </div>
          </div>
        )
      }

      export default function(data) {
        if (!this._root) this._root = createRoot(this.element)
        this._root.render(<Preview previewUrl={data.previewUrl} />)
      }
    JSX
  )

  puts "[seeds] preview slot updated"
  puts "[seeds] WebContainer IDE page created: #{Page.count} pages, #{Slot.count} slots"
end
