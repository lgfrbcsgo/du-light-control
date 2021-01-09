const yaml = require("js-yaml");
const fs = require("fs");
const glob = require("glob");
const path = require("path");
const luabundle = require("luabundle");

const SRC_DIR = "src";
const DIST_DIR = "dist";

const REQUIRE_REGEX = /require\(?["'].*["']\)?/;

function bundleCode(code) {
  const lines = code.split("\n");

  const requireIndex = lines.findIndex((line) => REQUIRE_REGEX.test(line));
  if (requireIndex === undefined) {
    return code;
  }

  const unbundled = lines.slice(0, requireIndex).join("\n");
  const bundled = luabundle.bundleString(lines.slice(requireIndex).join("\n"), {
    paths: [`${SRC_DIR}/?.lua`],
  });

  return `${unbundled}\n${bundled}`;
}

function bundleConfigHandlers(luaConfigPath) {
  const doc = yaml.safeLoad(fs.readFileSync(luaConfigPath, "utf8"));

  for (const handler of doc.handlers) {
    const bundledCode = bundleCode(handler.code);
    handler.code = bundledCode.split("\t").join("    ");
  }

  fs.writeFileSync(
    `${DIST_DIR}/${path.basename(luaConfigPath)}`,
    yaml.safeDump(doc, { lineWidth: -1 })
  );
}

if (!fs.existsSync(DIST_DIR)){
  fs.mkdirSync(DIST_DIR);
}

glob.sync(`${SRC_DIR}/*.yaml`).forEach(bundleConfigHandlers);
