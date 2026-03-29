import { existsSync } from 'fs';
import path from 'path';

type NativeSidebarModule = {
  setWindowLayout: (
    nativeWindowHandle: Buffer,
    sidebarWidth: number,
    titlebarHeight: number,
    titlebarMarginRight?: number
  ) => void;
  setWindowAnimationBehavior: (nativeWindowHandle: Buffer, isDocument: boolean) => void;
};

declare const __non_webpack_require__: NodeRequire | undefined;

const nativeRequire =
  typeof __non_webpack_require__ === 'function' ? __non_webpack_require__ : require;

const candidatePaths = [
  path.resolve(process.cwd(), 'build', 'Release', 'NativeExtension.node'),
  path.resolve(__dirname, '..', 'build', 'Release', 'NativeExtension.node'),
  path.resolve(process.resourcesPath, 'app.asar.unpacked', 'build', 'Release', 'NativeExtension.node'),
];

export const loadNativeSidebar = (): NativeSidebarModule | null => {
  if (process.platform !== 'darwin') {
    return null;
  }

  for (const candidatePath of candidatePaths) {
    if (!existsSync(candidatePath)) {
      continue;
    }

    try {
      return nativeRequire(candidatePath) as NativeSidebarModule;
    } catch (error) {
      console.warn(`Failed to load native sidebar module from ${candidatePath}`, error);
    }
  }

  console.warn('Native sidebar module was not found. Falling back to the single-surface Electron layout.');
  return null;
};
