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
  const gap = gapStr(c)

  let css = `.layout {\n  width: 100%;\n\n  display: grid;\n`
  css += `  grid-template-rows: ${trackListStr(rows)};\n`
  css += `  grid-template-columns: ${trackListStr(cols)};\n`
  css += `  gap: ${gap};\n`

  const flow = autoFlowStr(c)
  if (flow) css += `  grid-auto-flow: ${flow};\n`

  css += containerAlignmentCss(c)
  css += itemAlignmentCss(c)
  css += `}`

  css += childPlacementCss(c)
  return css
}

function generateGridCssWithAreas(c) {
  const rows = c.rows || []
  const cols = c.columns
  const gap = gapStr(c)

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

  css += containerAlignmentCss(c)
  css += itemAlignmentCss(c)
  css += `}\n`

  const uniqueAreas = [...new Set(c.areas.flat())].filter(a => a !== ".")
  for (const name of uniqueAreas) {
    css += `\n.${name} { grid-area: ${name}; }`
  }

  css += childPlacementCss(c)
  return css
}

function autoFlowStr(c) {
  const direction = c.direction
  const dense = c.dense

  if (direction === "column" && dense) return "column dense"
  if (direction === "column") return "column"
  if (dense) return "dense"
  return null
}

function containerAlignmentCss(c) {
  let css = ""
  if (c.justifyContent && c.justifyContent !== "stretch") {
    css += `  justify-content: ${c.justifyContent};\n`
  }
  if (c.alignContent && c.alignContent !== "stretch") {
    css += `  align-content: ${c.alignContent};\n`
  }
  return css
}

function itemAlignmentCss(c) {
  let css = ""
  if (c.justifyItems && c.justifyItems !== "stretch") {
    css += `  justify-items: ${c.justifyItems};\n`
  }
  if (c.alignItems && c.alignItems !== "stretch") {
    css += `  align-items: ${c.alignItems};\n`
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
  if (c.justifyContent && c.justifyContent !== "start") {
    css += `  justify-content: ${c.justifyContent};\n`
  }
  if (c.alignItems && c.alignItems !== "stretch") {
    css += `  align-items: ${c.alignItems};\n`
  }
  if (c.alignContent && c.alignContent !== "stretch") {
    css += `  align-content: ${c.alignContent};\n`
  }

  const rowGap = c.rowGap > 0 ? `${c.rowGap}${c.rowGapUnit || "px"}` : null
  const colGap = c.colGap > 0 ? `${c.colGap}${c.colGapUnit || "px"}` : null

  if (rowGap && colGap && rowGap === colGap) {
    css += `  gap: ${rowGap};\n`
  } else {
    if (rowGap) css += `  row-gap: ${rowGap};\n`
    if (colGap) css += `  column-gap: ${colGap};\n`
  }

  css += `}`

  css += flexChildPlacementCss(c)
  return css
}

function flexChildPlacementCss(c) {
  if (!c.childPlacements || !c.childPlacements.some(p => p && Object.keys(p).length > 0)) return ""

  let css = ""
  c.childPlacements.forEach((placement, i) => {
    if (!placement || Object.keys(placement).length === 0) return

    let props = ""
    if (placement.flexGrow != null) props += `  flex-grow: ${placement.flexGrow};\n`
    if (placement.flexShrink != null) props += `  flex-shrink: ${placement.flexShrink};\n`
    if (placement.flexBasis) props += `  flex-basis: ${placement.flexBasis};\n`
    if (placement.alignSelf) props += `  align-self: ${placement.alignSelf};\n`
    if (placement.order != null) props += `  order: ${placement.order};\n`
    if (props) {
      css += `\n\n.layout > :nth-child(${i + 1}) {\n${props}}`
    }
  })

  return css
}

function generateFlexHtml(c) {
  const count = c.childrenCount || 3
  const children = Array.from({ length: count }, (_, i) =>
    `  <div>${i + 1}</div>`
  ).join("\n")
  return `<section class="layout">\n${children}\n</section>`
}

// --- Helpers ---

function trackStr(track) {
  if (!track) return "1fr"
  if (track.unit === "auto") return "auto"
  if (track.unit === "min-content") return "min-content"
  if (track.unit === "max-content") return "max-content"
  return `${track.value}${track.unit}`
}

function trackListStr(tracks) {
  if (!tracks) return "1fr"
  // Repeat object: { repeat: "auto-fit"|"auto-fill", value, unit }
  if (!Array.isArray(tracks)) {
    const size = trackStr(tracks)
    return `repeat(${tracks.repeat}, ${size})`
  }
  if (tracks.length === 0) return "1fr"
  return tracks.map(t => trackStr(t)).join(" ")
}

function gapStr(c) {
  const rowGap = `${c.rowGap}${c.rowGapUnit || "px"}`
  const colGap = `${c.colGap}${c.colGapUnit || "px"}`
  return rowGap === colGap ? rowGap : `${rowGap} ${colGap}`
}
