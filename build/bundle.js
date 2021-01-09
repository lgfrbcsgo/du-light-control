const yaml = require('js-yaml')
const fs = require("fs")
const glob = require("glob")
const path = require("path")
const luabundle = require("luabundle")

const SRC_DIR = "src"
const DIST_DIR = "dist"

function bundleConfigHandlers(luaConfig) {
    const doc = yaml.safeLoad(fs.readFileSync(luaConfig, "utf8"));

    for (const handler of doc.handlers) {
        const bundledCode = luabundle.bundleString(handler.code, { paths: [`${SRC_DIR}/?.lua`] })
        handler.code = bundledCode.split("\t").join("    ")
    }

    fs.writeFileSync(`${DIST_DIR}/${path.basename(luaConfig)}`, yaml.safeDump(doc, {lineWidth: 1000}))
}

glob.sync(`${SRC_DIR}/*.yaml`).forEach(bundleConfigHandlers)




