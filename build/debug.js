const yaml = require("js-yaml");
const fs = require("fs");
const glob = require("glob");
const path = require("path");

const SRC_DIR = "src";
const DEBUG_DIR = "debug";

const wrapInErrorHandler = (code) =>
  `local ok, msg = xpcall(function ()
${code
  .trim()
  .split("\n")
  .map((line) => `    ${line}`)
  .join("\n")}
end, traceback)

if not ok then
    system.print(msg)
    unit.exit()
end`;

function wrapConfigHandlers(luaConfigPath) {
  const doc = yaml.safeLoad(fs.readFileSync(luaConfigPath, "utf8"));

  for (const handler of doc.handlers) {
    handler.code = wrapInErrorHandler(handler.code);
  }

  fs.writeFileSync(
    `${DEBUG_DIR}/${path.basename(luaConfigPath)}`,
    yaml.safeDump(doc, { lineWidth: -1 })
  );
}

if (!fs.existsSync(DEBUG_DIR)) {
  fs.mkdirSync(DEBUG_DIR);
}

glob.sync(`${SRC_DIR}/*.yaml`).forEach(wrapConfigHandlers);
