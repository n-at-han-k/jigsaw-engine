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
    <div className="tw-h-full tw-flex tw-flex-col tw-bg-gray-900">
      {/* Tabs */}
      <div className="tw-flex tw-items-center tw-bg-gray-800 tw-border-b tw-border-gray-700 tw-overflow-x-auto">
        {openFiles.length === 0 ? (
          <div className="tw-flex-1 tw-flex tw-items-center tw-justify-center tw-text-gray-500 tw-py-8">
            <p>No file open. Select a file from the file tree.</p>
          </div>
        ) : (
          openFiles.map((file) => (
            <div
              key={file}
              className={`tw-flex tw-items-center tw-gap-2 tw-px-4 tw-py-2 tw-border-r tw-border-gray-700 tw-cursor-pointer ${
                activeFile === file ? "tw-bg-gray-900 tw-text-white" : "tw-bg-gray-800 tw-text-gray-400"
              }`}
              onClick={() => setActiveFile(file)}
            >
              <span className="tw-text-sm tw-whitespace-nowrap">{file.split("/").pop()}</span>
              <button
                onClick={(e) => {
                  e.stopPropagation()
                  closeFile(file)
                }}
                className="hover:tw-bg-gray-700 tw-rounded tw-p-0.5"
              >
                <X size={14} />
              </button>
            </div>
          ))
        )}
      </div>

      {/* Editor */}
      <div className="tw-flex-1">
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
  console.log("[editor] render called", data)
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
