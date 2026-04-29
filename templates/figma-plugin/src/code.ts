// Figma Plugin Code
// This runs in the Figma desktop app context

figma.showUI(__html__);

figma.ui.onmessage = (msg) => {
  if (msg.type === 'create-shapes') {
    const rect = figma.createRectangle();
    rect.fills = [{ type: 'SOLID', color: { r: 0, g: 0.5, b: 1 } }];
    figma.currentPage.appendChild(rect);
    figma.viewport.scrollAndZoomToView(rect);
  }
  figma.closePlugin();
};
