const { contextBridge } = require("electron");

contextBridge.exposeInMainWorld("pleiades", {
  platform: process.platform,
  versions: process.versions
});
