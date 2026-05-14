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

  const refreshFileTree = async () => {
    onRefresh()
  }

  const handleCreateFile = async () => {
    if (!newItemName.trim()) return
    const newPath =
      node.type === "directory" ? `${node.path}/${newItemName}` : `${node.path}/../${newItemName}`
    try {
      await window.__wc.fs.writeFile(newPath, "")
      await refreshFileTree()
      setShowNewFileDialog(false)
      setNewItemName("")
    } catch (error) {
      console.error("Failed to create file:", error)
    }
  }

  const handleCreateFolder = async () => {
    if (!newItemName.trim()) return
    const newPath =
      node.type === "directory" ? `${node.path}/${newItemName}` : `${node.path}/../${newItemName}`
    try {
      await window.__wc.fs.mkdir(newPath, { recursive: true })
      await refreshFileTree()
      setShowNewFolderDialog(false)
      setNewItemName("")
    } catch (error) {
      console.error("Failed to create folder:", error)
    }
  }

  const handleDelete = async () => {
    if (!confirm(`Are you sure you want to delete ${node.name}?`)) return
    try {
      await window.__wc.fs.rm(node.path, { recursive: true })
      await refreshFileTree()
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
            className={`tw-flex tw-items-center tw-gap-1 tw-px-2 tw-py-1 tw-cursor-pointer hover:tw-bg-gray-700 ${
              isActive ? "tw-bg-blue-600" : ""
            }`}
            style={{ paddingLeft: `${level * 12 + 8}px` }}
            onClick={handleClick}
          >
            {node.type === "directory" ? (
              <>
                {isExpanded ? (
                  <ChevronDown size={16} className="tw-text-gray-400 tw-flex-shrink-0" />
                ) : (
                  <ChevronRight size={16} className="tw-text-gray-400 tw-flex-shrink-0" />
                )}
                {isExpanded ? (
                  <FolderOpen size={16} className="tw-text-blue-400 tw-flex-shrink-0" />
                ) : (
                  <Folder size={16} className="tw-text-blue-400 tw-flex-shrink-0" />
                )}
              </>
            ) : (
              <>
                <span className="tw-w-4 tw-flex-shrink-0" />
                <File size={16} className="tw-text-gray-400 tw-flex-shrink-0" />
              </>
            )}
            <span className="tw-text-sm tw-text-gray-200 tw-truncate">{node.name}</span>
          </div>
        </ContextMenu.Trigger>

        <ContextMenu.Portal>
          <ContextMenu.Content className="tw-min-w-[180px] tw-bg-gray-800 tw-rounded-md tw-overflow-hidden tw-p-1 tw-shadow-lg tw-border tw-border-gray-700">
            <ContextMenu.Item
              className="tw-flex tw-items-center tw-gap-2 tw-px-2 tw-py-1.5 tw-text-sm tw-text-gray-200 tw-cursor-pointer hover:tw-bg-gray-700 tw-rounded tw-outline-none"
              onClick={() => setShowNewFileDialog(true)}
            >
              <FilePlus size={16} />
              New File
            </ContextMenu.Item>
            <ContextMenu.Item
              className="tw-flex tw-items-center tw-gap-2 tw-px-2 tw-py-1.5 tw-text-sm tw-text-gray-200 tw-cursor-pointer hover:tw-bg-gray-700 tw-rounded tw-outline-none"
              onClick={() => setShowNewFolderDialog(true)}
            >
              <FolderPlus size={16} />
              New Folder
            </ContextMenu.Item>
            <ContextMenu.Separator className="tw-h-[1px] tw-bg-gray-700 tw-my-1" />
            <ContextMenu.Item
              className="tw-flex tw-items-center tw-gap-2 tw-px-2 tw-py-1.5 tw-text-sm tw-text-red-400 tw-cursor-pointer hover:tw-bg-gray-700 tw-rounded tw-outline-none"
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
          <Dialog.Overlay className="tw-fixed tw-inset-0 tw-bg-black/50" style={{ zIndex: 9998 }} />
          <Dialog.Content className="tw-fixed tw-top-1/2 tw-left-1/2 -tw-translate-x-1/2 -tw-translate-y-1/2 tw-bg-gray-800 tw-rounded-lg tw-p-6 tw-w-96 tw-shadow-xl" style={{ zIndex: 9999 }}>
            <Dialog.Title className="tw-text-lg tw-font-semibold tw-text-white tw-mb-4">
              New File
            </Dialog.Title>
            <Dialog.Description className="tw-sr-only">Enter a name for the new file</Dialog.Description>
            <input
              type="text"
              value={newItemName}
              onChange={(e) => setNewItemName(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleCreateFile()}
              placeholder="filename.txt"
              className="tw-w-full tw-px-3 tw-py-2 tw-bg-gray-900 tw-text-white tw-rounded tw-border tw-border-gray-700 focus:tw-border-blue-500 tw-outline-none"
              autoFocus
            />
            <div className="tw-flex tw-justify-end tw-gap-2 tw-mt-4">
              <button
                onClick={() => setShowNewFileDialog(false)}
                className="tw-px-4 tw-py-2 tw-text-gray-400 hover:tw-text-white"
              >
                Cancel
              </button>
              <button
                onClick={handleCreateFile}
                className="tw-px-4 tw-py-2 tw-bg-blue-600 tw-text-white tw-rounded hover:tw-bg-blue-700"
              >
                Create
              </button>
            </div>
          </Dialog.Content>
        </Dialog.Portal>
      </Dialog.Root>

      <Dialog.Root open={showNewFolderDialog} onOpenChange={setShowNewFolderDialog}>
        <Dialog.Portal>
          <Dialog.Overlay className="tw-fixed tw-inset-0 tw-bg-black/50" style={{ zIndex: 9998 }} />
          <Dialog.Content className="tw-fixed tw-top-1/2 tw-left-1/2 -tw-translate-x-1/2 -tw-translate-y-1/2 tw-bg-gray-800 tw-rounded-lg tw-p-6 tw-w-96 tw-shadow-xl" style={{ zIndex: 9999 }}>
            <Dialog.Title className="tw-text-lg tw-font-semibold tw-text-white tw-mb-4">
              New Folder
            </Dialog.Title>
            <Dialog.Description className="tw-sr-only">Enter a name for the new folder</Dialog.Description>
            <input
              type="text"
              value={newItemName}
              onChange={(e) => setNewItemName(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleCreateFolder()}
              placeholder="folder-name"
              className="tw-w-full tw-px-3 tw-py-2 tw-bg-gray-900 tw-text-white tw-rounded tw-border tw-border-gray-700 focus:tw-border-blue-500 tw-outline-none"
              autoFocus
            />
            <div className="tw-flex tw-justify-end tw-gap-2 tw-mt-4">
              <button
                onClick={() => setShowNewFolderDialog(false)}
                className="tw-px-4 tw-py-2 tw-text-gray-400 hover:tw-text-white"
              >
                Cancel
              </button>
              <button
                onClick={handleCreateFolder}
                className="tw-px-4 tw-py-2 tw-bg-blue-600 tw-text-white tw-rounded hover:tw-bg-blue-700"
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
    <div className="tw-h-full tw-bg-gray-800 tw-overflow-auto">
      <ContextMenu.Root>
        <ContextMenu.Trigger asChild>
          <div className="tw-h-full">
            <div className="tw-p-2 tw-border-b tw-border-gray-700 tw-flex tw-items-center tw-justify-between">
              <h3 className="tw-text-sm tw-font-semibold tw-text-gray-300">FILES</h3>
              <div className="tw-flex tw-gap-1">
                <button
                  onClick={() => setShowNewFileDialog(true)}
                  className="tw-p-1 hover:tw-bg-gray-700 tw-rounded"
                  title="New File"
                >
                  <FilePlus size={16} className="tw-text-gray-400" />
                </button>
                <button
                  onClick={() => setShowNewFolderDialog(true)}
                  className="tw-p-1 hover:tw-bg-gray-700 tw-rounded"
                  title="New Folder"
                >
                  <FolderPlus size={16} className="tw-text-gray-400" />
                </button>
              </div>
            </div>
            <div className="tw-py-1">
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
          <ContextMenu.Content className="tw-min-w-[180px] tw-bg-gray-800 tw-rounded-md tw-overflow-hidden tw-p-1 tw-shadow-lg tw-border tw-border-gray-700">
            <ContextMenu.Item
              className="tw-flex tw-items-center tw-gap-2 tw-px-2 tw-py-1.5 tw-text-sm tw-text-gray-200 tw-cursor-pointer hover:tw-bg-gray-700 tw-rounded tw-outline-none"
              onClick={() => setShowNewFileDialog(true)}
            >
              <FilePlus size={16} />
              New File
            </ContextMenu.Item>
            <ContextMenu.Item
              className="tw-flex tw-items-center tw-gap-2 tw-px-2 tw-py-1.5 tw-text-sm tw-text-gray-200 tw-cursor-pointer hover:tw-bg-gray-700 tw-rounded tw-outline-none"
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
          <Dialog.Overlay className="tw-fixed tw-inset-0 tw-bg-black/50" style={{ zIndex: 9998 }} />
          <Dialog.Content className="tw-fixed tw-top-1/2 tw-left-1/2 -tw-translate-x-1/2 -tw-translate-y-1/2 tw-bg-gray-800 tw-rounded-lg tw-p-6 tw-w-96 tw-shadow-xl" style={{ zIndex: 9999 }}>
            <Dialog.Title className="tw-text-lg tw-font-semibold tw-text-white tw-mb-4">
              New File
            </Dialog.Title>
            <Dialog.Description className="tw-sr-only">Enter a name for the new file</Dialog.Description>
            <input
              type="text"
              value={newItemName}
              onChange={(e) => setNewItemName(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleCreateFile()}
              placeholder="filename.txt"
              className="tw-w-full tw-px-3 tw-py-2 tw-bg-gray-900 tw-text-white tw-rounded tw-border tw-border-gray-700 focus:tw-border-blue-500 tw-outline-none"
              autoFocus
            />
            <div className="tw-flex tw-justify-end tw-gap-2 tw-mt-4">
              <button
                onClick={() => setShowNewFileDialog(false)}
                className="tw-px-4 tw-py-2 tw-text-gray-400 hover:tw-text-white"
              >
                Cancel
              </button>
              <button
                onClick={handleCreateFile}
                className="tw-px-4 tw-py-2 tw-bg-blue-600 tw-text-white tw-rounded hover:tw-bg-blue-700"
              >
                Create
              </button>
            </div>
          </Dialog.Content>
        </Dialog.Portal>
      </Dialog.Root>

      <Dialog.Root open={showNewFolderDialog} onOpenChange={setShowNewFolderDialog}>
        <Dialog.Portal>
          <Dialog.Overlay className="tw-fixed tw-inset-0 tw-bg-black/50" style={{ zIndex: 9998 }} />
          <Dialog.Content className="tw-fixed tw-top-1/2 tw-left-1/2 -tw-translate-x-1/2 -tw-translate-y-1/2 tw-bg-gray-800 tw-rounded-lg tw-p-6 tw-w-96 tw-shadow-xl" style={{ zIndex: 9999 }}>
            <Dialog.Title className="tw-text-lg tw-font-semibold tw-text-white tw-mb-4">
              New Folder
            </Dialog.Title>
            <Dialog.Description className="tw-sr-only">Enter a name for the new folder</Dialog.Description>
            <input
              type="text"
              value={newItemName}
              onChange={(e) => setNewItemName(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleCreateFolder()}
              placeholder="folder-name"
              className="tw-w-full tw-px-3 tw-py-2 tw-bg-gray-900 tw-text-white tw-rounded tw-border tw-border-gray-700 focus:tw-border-blue-500 tw-outline-none"
              autoFocus
            />
            <div className="tw-flex tw-justify-end tw-gap-2 tw-mt-4">
              <button
                onClick={() => setShowNewFolderDialog(false)}
                className="tw-px-4 tw-py-2 tw-text-gray-400 hover:tw-text-white"
              >
                Cancel
              </button>
              <button
                onClick={handleCreateFolder}
                className="tw-px-4 tw-py-2 tw-bg-blue-600 tw-text-white tw-rounded hover:tw-bg-blue-700"
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
  console.log("[filetree] render called", data)
  if (!this._root) this._root = createRoot(this.element)

  const rebuildTree = async () => {
    if (!window.__wc) return
    async function build(container, path = ".") {
      const entries = await container.fs.readdir(path, { withFileTypes: true })
      const nodes = []
      for (const entry of entries) {
        if (entry.name === "node_modules" || entry.name === ".git") continue
        const fullPath = path === "." ? entry.name : path + "/" + entry.name
        if (entry.isDirectory()) {
          nodes.push({ name: entry.name, path: fullPath, type: "directory", children: await build(container, fullPath) })
        } else {
          nodes.push({ name: entry.name, path: fullPath, type: "file" })
        }
      }
      return nodes.sort((a, b) => a.type === b.type ? a.name.localeCompare(b.name) : a.type === "directory" ? -1 : 1)
    }
    data._shared.wc.proxy.fileTree = await build(window.__wc)
  }

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
      onRefresh={rebuildTree}
    />
  )
}
