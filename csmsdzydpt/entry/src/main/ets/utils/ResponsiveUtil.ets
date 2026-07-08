import { window } from '@kit.ArkUI';

export class BreakpointSystem {
  static readonly SM = 320;
  static readonly MD = 520;
  static readonly LG = 840;

  static currentWidth: number = 360;

  static getBreakpoint(): string {
    if (BreakpointSystem.currentWidth >= BreakpointSystem.LG) return 'lg';
    if (BreakpointSystem.currentWidth >= BreakpointSystem.MD) return 'md';
    return 'sm';
  }

  static isSm(): boolean {
    return BreakpointSystem.getBreakpoint() === 'sm';
  }

  static isMd(): boolean {
    return BreakpointSystem.getBreakpoint() === 'md';
  }

  static isLg(): boolean {
    return BreakpointSystem.getBreakpoint() === 'lg';
  }

  static init(context: window.WindowStage): void {
    const win = window.getLastWindow(context.getMainWindowSync().getUIContext());
    // Get initial size
    try {
      const props = window.getLastWindow(context.getMainWindowSync().getUIContext()).getWindowProperties();
      BreakpointSystem.currentWidth = props.windowRect.width;
    } catch {
      BreakpointSystem.currentWidth = 360;
    }
  }
}
