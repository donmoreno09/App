.pragma library

const pointPoiMenuItems = {
    GATE: {
        label: "Gates",
        values: [
            { key: "SECG", label: "Security gate" },
            { key: "TERG", label: "Terminal Gates" }
        ]
    },
    STRU: {
        label: "Structures",
        values: [
            { key: "SILO", label: "Silo" },
            { key: "CTOW", label: "Control Tower" },
            { key: "MOLI", label: "Moli" }
        ]
    },
    CRAN: {
        label: "Cranes (asset dinamico)",
        values: [
            { key: "MOCR", label: "Mobile crane" },
            { key: "GACR", label: "Gantry crane" },
            { key: "QUAY", label: "Quay crane" }
        ]
    }
};

const areaPoiMenuItems = {
    BUIL: {
        label: "Buildings",
        values: [
            { key: "OFFI", label: "Office" },
            { key: "FUEL", label: "Fuel Station" },
            { key: "MECH", label: "Mechanical workshop" },
            { key: "WORK", label: "Worksite" }
        ]
    },
    DOCK: {
        label: "Docking",
        values: [
            { key: "BANA", label: "Banchina A" },
            { key: "BANB", label: "Banchina B" }
        ]
    },
    TERM: {
        label: "Terminals",
        values: [
            { key: "TCON", label: "Terminal container" },
            { key: "TROR", label: "Terminal RO-RO" }
        ]
    },
    ARCO: {
        label: "AreaContainer",
        values: [
            { key: "ACCA", label: "AreaContainer Carico TIR" },
            { key: "ASCA", label: "AreaContainer scarico TIR" },
            { key: "ACON", label: "AreaContainer" }
        ]
    }
};
