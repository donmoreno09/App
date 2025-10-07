.pragma library

function getToolIndex(toolsModel, tool) {
    let count = 1
    for (let i = 0; i < toolsModel.count; i++) {
        let t = toolsModel.get(i)
        if (t.id === tool.id) break
        if (t.separator) continue
        count++
    }
    return count
}
