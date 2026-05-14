export function generateLayoutCss(config) {
  if (!config.areas || !config.areas.length) return ""
  return generateGridCss(config)
}

export function generateLayoutHtml(config) {
  if (!config.areas || !config.areas.length) return ""
  return generateGridHtml(config)
}

function generateGridCss(c) {
  let css = `.container {\n  display: grid;\n`
  css += `  width: ${c.gridWidth || "100%"};\n`
  css += `  height: ${c.gridHeight || "100%"};\n`

  const hasAreas = c.areas.flat().some(a => a !== ".")
  if (hasAreas) {
    css += `  grid-template-areas: ${c.areas.map(row => `"${row.join(" ")}"`).join("\n    ")};\n`
  }

  css += `  grid-template-columns: ${c.columns.join(" ")};\n`
  css += `  grid-template-rows: ${c.rows.join(" ")};\n`
  css += `  gap: ${c.rowGap}${c.rowGapUnit || "px"} ${c.colGap}${c.colGapUnit || "px"};\n`
  css += `}\n`

  if (hasAreas) {
    const uniqueAreas = [...new Set(c.areas.flat())].filter(a => a !== ".")
    for (const name of uniqueAreas) {
      css += `\n.${name} { grid-area: ${name}; }`
    }
  }

  return css
}

function generateGridHtml(c) {
  const hasAreas = c.areas?.flat().some(a => a !== ".")

  if (hasAreas) {
    const uniqueAreas = [...new Set(c.areas.flat())].filter(a => a !== ".")
    const children = uniqueAreas.map((name, i) =>
      `  <div class="${name}">${name}</div>`
    ).join("\n")
    return `<div class="container">\n${children}\n</div>`
  }

  const count = c.childrenCount || 9
  const children = Array.from({ length: count }, (_, i) =>
    `  <div>${i + 1}</div>`
  ).join("\n")
  return `<div class="container">\n${children}\n</div>`
}
