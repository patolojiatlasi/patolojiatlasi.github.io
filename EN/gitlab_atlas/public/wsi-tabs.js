// Initialize marked WSI documents only after their tab has usable layout dimensions.
(() => {
  const loadVisibleViewers = () => {
    document.querySelectorAll('iframe[data-wsi-src]').forEach((frame) => {
      if (frame.hasAttribute('src')) return;
      const bounds = frame.getBoundingClientRect();
      if (bounds.width > 0 && bounds.height > 0 && frame.getClientRects().length) {
        frame.src = frame.dataset.wsiSrc;
      }
    });
  };
  const afterLayout = () => requestAnimationFrame(loadVisibleViewers);
  document.addEventListener('DOMContentLoaded', afterLayout);
  document.addEventListener('shown.bs.tab', afterLayout);
  window.addEventListener('resize', afterLayout);
})();
