import { contextBridge } from 'electron';

contextBridge.exposeInMainWorld('pleiades', {
  platform: process.platform,
  versions: {
    chrome: process.versions.chrome,
    electron: process.versions.electron,
    node: process.versions.node,
  },
});
