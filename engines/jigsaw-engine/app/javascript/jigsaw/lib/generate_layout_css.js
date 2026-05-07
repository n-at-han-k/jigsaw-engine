// Pure function: config object in, CSS + HTML strings out.
// No DOM, no Stimulus, no side effects.

export function generateLayoutCss(config) {
  if (config.type === "flex") return generateFlexCss(config)
  return generateGridCss(config)
}

export function generateLayoutHtml(config) {
  if (config.type === "flex") return generateFlexHtml(config)
  return generateGridHtml(config)
}

// --- Grid ---

function generateGridCss(c) {
  const hasAreas = c.areas?.length > 0 && c.areas.flat().some(a => a !== ".")
  if (hasAreas) return generateGridCssWithAreas(c)

  const rows = c.rows
  const cols = c.columns
  const gap = gridGapStr(c)

  let css = `.layout {\n  width: 100%;\n\n  display: grid;\n`
  css += `  grid-template-rows: ${trackListStr(rows)};\n`
  css += `  grid-template-columns: ${trackListStr(cols)};\n`
  css += `  gap: ${gap};\n`

  const flow = autoFlowStr(c)
  if (flow) css += `  grid-auto-flow: ${flow};\n`

  css += gridContainerAlignmentCss(c)
  css += gridChildrenAlignmentCss(c)
  css += `}`

  css += childPlacementCss(c)
  return css
}

function generateGridCssWithAreas(c) {
  const rows = c.rows || []
  const cols = c.columns
  const gap = gridGapStr(c)

  let rowLines
  if (Array.isArray(rows)) {
    rowLines = c.areas.map((areaRow, i) => {
      const size = trackStr(rows[i])
      return `    "${areaRow.join(" ")}" ${size}`
    })
  } else {
    const size = trackStr(rows)
    rowLines = c.areas.map((areaRow) => {
      return `    "${areaRow.join(" ")}" ${size}`
    })
  }

  const colLine = trackListStr(cols)

  let css = `.layout {\n  width: 100%;\n\n  display: grid;\n  grid:\n`
  css += rowLines.join("\n")
  css += `\n    / ${colLine};\n`
  css += `  gap: ${gap};\n`

  const flow = autoFlowStr(c)
  if (flow) css += `  grid-auto-flow: ${flow};\n`

  css += gridContainerAlignmentCss(c)
  css += gridChildrenAlignmentCss(c)
  css += `}\n`

  const uniqueAreas = [...new Set(c.areas.flat())].filter(a => a !== ".")
  for (const name of uniqueAreas) {
    css += `\n.${name} { grid-area: ${name}; }`
  }

  css += childPlacementCss(c)
  return css
}

export function autoFlowStr(c) {
  const direction = c.direction
  const dense = c.emptySpace === "fill"

  if (direction === "column" && dense) return "column dense"
  if (direction === "column") return "column"
  if (dense) return "dense"
  return null
}

function gridContainerAlignmentCss(c) {
  let css = ""
  const align = c.containerAlignment
  if (align) {
    if (align.horizontal && align.horizontal !== "stretch") {
      css += `  justify-content: ${align.horizontal};\n`
    }
    if (align.vertical && align.vertical !== "stretch") {
      css += `  align-content: ${align.vertical};\n`
    }
  }
  return css
}

function gridChildrenAlignmentCss(c) {
  let css = ""
  const align = c.childrenAlignment
  if (align) {
    if (align.horizontal && align.horizontal !== "stretch") {
      css += `  justify-items: ${align.horizontal};\n`
    }
    if (align.vertical && align.vertical !== "stretch") {
      css += `  align-items: ${align.vertical};\n`
    }
  }
  return css
}

function childPlacementCss(c) {
  if (!c.childPlacements || !c.childPlacements.some(p => p && (p.row || p.column))) return ""

  let css = ""
  const seen = new Set()

  for (const placement of c.childPlacements) {
    if (!placement || (!placement.row && !placement.column)) continue

    const className = placementClassName(placement)
    if (seen.has(className)) continue
    seen.add(className)

    let props = ""
    if (placement.row) props += `  grid-row: ${placement.row};\n`
    if (placement.column) props += `  grid-column: ${placement.column};\n`
    css += `\n\n.${className} {\n${props}}`
  }

  return css
}

function placementClassName(placement) {
  const parts = []
  if (placement.column) {
    parts.push("col" + placement.column.replace(/\s*\/\s*/g, "Last").replace(/-/g, ""))
  }
  if (placement.row) {
    parts.push("row" + placement.row.replace(/\s*\/\s*/g, "Last").replace(/-/g, ""))
  }
  return parts.join("")
}

function generateGridHtml(c) {
  const hasAreas = c.areas?.length > 0 && c.areas.flat().some(a => a !== ".")

  if (hasAreas) {
    const uniqueAreas = [...new Set(c.areas.flat())].filter(a => a !== ".")
    const children = uniqueAreas.map((name, i) =>
      `  <div class="${name}">${i + 1}</div>`
    ).join("\n")
    return `<section class="layout">\n${children}\n</section>`
  }

  const count = c.childrenCount || 9
  const placements = c.childPlacements || []
  const children = Array.from({ length: count }, (_, i) => {
    const placement = placements[i]
    if (placement && (placement.row || placement.column)) {
      const cls = placementClassName(placement)
      return `  <div class="${cls}">${i + 1}</div>`
    }
    return `  <div>${i + 1}</div>`
  }).join("\n")
  return `<section class="layout">\n${children}\n</section>`
}

// --- Flex ---

function generateFlexCss(c) {
  let css = `.layout {\n  width: 100%;\n\n  display: flex;\n`

  if (c.direction && c.direction !== "row") {
    css += `  flex-direction: ${c.direction};\n`
  }
  if (c.wrap && c.wrap !== "nowrap") {
    css += `  flex-wrap: ${c.wrap};\n`
  }

  if (c.gap > 0) {
    css += `  gap: ${c.gap}${c.gapUnit || "px"};\n`
  }

  const align = c.containerAlignment
  if (align) {
    if (align.mainAxis && align.mainAxis !== "flex-start") {
      css += `  justify-content: ${align.mainAxis};\n`
    }
    if (align.crossAxis && align.crossAxis !== "stretch") {
      css += `  align-items: ${align.crossAxis};\n`
    }
  }

  css += `}`

  css += flexChildrenCss(c)
  return css
}

function flexChildrenCss(c) {
  if (!c.children || !c.children.some(ch => ch.grow !== 0 || ch.shrink !== 1 || ch.basis !== "auto" || ch.margin)) return ""

  let css = ""
  const classMap = {}

  for (const child of c.children) {
    if (child.grow === 0 && child.shrink === 1 && child.basis === "auto" && !child.margin) continue

    const className = flexChildClassName(child)
    if (classMap[className]) continue

    let props = ""
    if (child.grow !== 0) props += `  flex-grow: ${child.grow};\n`
    if (child.shrink !== 1) props += `  flex-shrink: ${child.shrink};\n`
    if (child.basis && child.basis !== "auto") props += `  flex-basis: ${child.basis};\n`
    if (child.margin) props += `  margin-left: auto;\n`

    if (props) {
      classMap[className] = props
    }
  }

  for (const [className, props] of Object.entries(classMap)) {
    css += `\n\n.${className} {\n${props}}`
  }

  return css
}

function flexChildClassName(child) {
  if (child.margin) return "marginLeft"
  if (child.grow !== 0) return `grow${child.grow}`
  if (child.shrink !== 1) return `shrink${child.shrink}`
  return `basis${child.basis}`
}

function generateFlexHtml(c) {
  const count = c.childrenCount || 3
  const children = c.children || []

  const lines = Array.from({ length: count }, (_, i) => {
    const child = children[i] || { grow: 0, shrink: 1, basis: "auto", margin: false }
    if (child.grow !== 0 || child.shrink !== 1 || child.basis !== "auto" || child.margin) {
      const cls = flexChildClassName(child)
      return `  <div class="${cls}">${i + 1}</div>`
    }
    return `  <div>${i + 1}</div>`
  }).join("\n")

  return `<section class="layout">\n${lines}\n</section>`
}

// --- Helpers ---

export function trackStr(track) {
  if (!track) return "1fr"
  if (track.unit === "auto") return "auto"
  if (track.unit === "min-content") return "min-content"
  if (track.unit === "max-content") return "max-content"
  return `${track.value}${track.unit}`
}

export function trackListStr(tracks) {
  if (!tracks) return "1fr"
  if (!Array.isArray(tracks)) {
    const size = trackStr(tracks)
    return `repeat(${tracks.repeat}, ${size})`
  }
  if (tracks.length === 0) return "1fr"
  return tracks.map(t => trackStr(t)).join(" ")
}

export function gridGapStr(c) {
  const rowGap = `${c.rowGap}${c.rowGapUnit || "px"}`
  const colGap = `${c.colGap}${c.colGapUnit || "px"}`
  return rowGap === colGap ? rowGap : `${rowGap} ${colGap}`
}
