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
        xterm.writeln("\x1b[1;36m\u2554\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2557\x1b[0m")
        xterm.writeln("\x1b[1;36m\u2551   WebContainer IDE Terminal          \u2551\x1b[0m")
        xterm.writeln("\x1b[1;36m\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u255d\x1b[0m")
        xterm.writeln("")

        let currentLine = ""
        let isProcessRunning = false

        const writePrompt = () => {
          xterm.write("\x1b[1;32m\u279c\x1b[0m \x1b[1;36m~\x1b[0m ")
        }

        writePrompt()

        xterm.onData((data) => {
          if (isProcessRunning) return

          const code = data.charCodeAt(0)

          if (code === 13) {
            // Enter
            const command = currentLine.trim()
            currentLine = ""
            xterm.write("\r\n")

            if (command) {
              isProcessRunning = true
              ;(async () => {
                try {
                  const container = window.__wc
                  if (!container) {
                    xterm.writeln("\x1b[1;31m\u2716 WebContainer not ready\x1b[0m")
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
                  xterm.writeln("\x1b[1;31m\u2716 Error: " + error + "\x1b[0m")
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
              xterm.write("\b \b")
            }
          } else if (code === 3) {
            // Ctrl+C
            if (isProcessRunning) {
              xterm.write("^C\r\n")
              isProcessRunning = false
              writePrompt()
            } else {
              xterm.write("^C\r\n")
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
      xtermRef.current.writeln("\x1b[1;32m\u2713 Terminal cleared\x1b[0m")
      xtermRef.current.write("\r\n\x1b[1;32m\u279c\x1b[0m \x1b[1;36m~\x1b[0m ")
    }
  }

  const scrollToBottom = () => {
    if (xtermRef.current) {
      xtermRef.current.scrollToBottom()
      setShowScrollButton(false)
    }
  }

  return (
    <div className="tw-h-full tw-flex tw-flex-col tw-bg-black tw-relative">
      <div className="tw-flex tw-items-center tw-justify-between tw-px-4 tw-py-2 tw-bg-gray-900 tw-border-b tw-border-gray-700">
        <div className="tw-flex tw-items-center tw-gap-2">
          <TerminalIcon size={16} className="tw-text-green-400" />
          <h3 className="tw-text-sm tw-font-semibold tw-text-gray-300">TERMINAL</h3>
          <span className="tw-text-xs tw-text-gray-500">Buffer: 10k lines</span>
        </div>
        <button
          onClick={handleClear}
          className="tw-p-1 hover:tw-bg-gray-800 tw-rounded tw-transition-colors"
          title="Clear terminal"
        >
          <Trash2 size={14} className="tw-text-gray-400 hover:tw-text-gray-200" />
        </button>
      </div>
      <div
        ref={terminalRef}
        className="tw-flex-1 tw-overflow-hidden"
        style={{ backgroundColor: "#0a0a0a", padding: "12px" }}
      />
      {showScrollButton && (
        <button
          onClick={scrollToBottom}
          className="tw-absolute tw-bottom-6 tw-right-6 tw-p-2.5 tw-bg-blue-600 hover:tw-bg-blue-700 tw-text-white tw-rounded-full tw-shadow-lg tw-transition-all hover:tw-scale-110"
          title="Scroll to bottom"
        >
          <ArrowDown size={18} />
        </button>
      )}
    </div>
  )
}

export default function(data) {
  console.log("[terminal] render called", data)
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<TerminalPanel />)
}
