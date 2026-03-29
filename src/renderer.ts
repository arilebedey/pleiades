import './index.css';

declare global {
  interface Window {
    pleiades: {
      platform: string;
      versions: {
        chrome: string;
        electron: string;
        node: string;
      };
    };
  }
}

const platform = document.querySelector('#platform');
const electronVersion = document.querySelector('#electron-version');
const chromeVersion = document.querySelector('#chrome-version');
const nodeVersion = document.querySelector('#node-version');

document.body.dataset.platform = window.pleiades.platform;

if (platform) {
  platform.textContent = window.pleiades.platform;
}

if (electronVersion) {
  electronVersion.textContent = window.pleiades.versions.electron;
}

if (chromeVersion) {
  chromeVersion.textContent = window.pleiades.versions.chrome;
}

if (nodeVersion) {
  nodeVersion.textContent = window.pleiades.versions.node;
}
