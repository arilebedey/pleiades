const platform = document.querySelector("#platform");
const electronVersion = document.querySelector("#electron-version");
const chromeVersion = document.querySelector("#chrome-version");
const nodeVersion = document.querySelector("#node-version");

platform.textContent = window.pleiades.platform;
electronVersion.textContent = window.pleiades.versions.electron;
chromeVersion.textContent = window.pleiades.versions.chrome;
nodeVersion.textContent = window.pleiades.versions.node;
