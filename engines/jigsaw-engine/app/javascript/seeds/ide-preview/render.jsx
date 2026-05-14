import React from "react"
import { createRoot } from "react-dom/client"
import { RefreshCw } from "lucide-react"

function Preview({ previewUrl }) {
  const [key, setKey] = React.useState(0)

  const handleRefresh = () => {
    setKey((prev) => prev + 1)
  }

  return (
    <div className="tw-h-full tw-flex tw-flex-col tw-bg-gray-900">
      <div className="tw-flex tw-items-center tw-justify-between tw-px-4 tw-py-2 tw-bg-gray-800 tw-border-b tw-border-gray-700">
        <h3 className="tw-text-sm tw-font-semibold tw-text-gray-300">PREVIEW</h3>
        {previewUrl && (
          <button
            onClick={handleRefresh}
            className="tw-p-1 hover:tw-bg-gray-700 tw-rounded"
            title="Refresh preview"
          >
            <RefreshCw size={16} className="tw-text-gray-400" />
          </button>
        )}
      </div>
      <div className="tw-flex-1 tw-bg-white">
        {previewUrl ? (
          <iframe
            key={key}
            src={previewUrl}
            className="tw-w-full tw-h-full tw-border-0"
            title="Preview"
            sandbox="allow-scripts allow-same-origin allow-forms allow-modals"
          />
        ) : (
          <div className="tw-flex tw-items-center tw-justify-center tw-h-full tw-text-gray-500">
            <p>Starting dev server...</p>
          </div>
        )}
      </div>
    </div>
  )
}

export default function(data) {
  console.log("[preview] render called", data)
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<Preview previewUrl={data.previewUrl} />)
}
