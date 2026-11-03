(() => {
  const reader = document.getElementById('page-reader');
  if (!reader) return;
  const summary = reader.querySelector('summary');
  const textOnly = new URLSearchParams(location.search).get('view') === 'text';
  let expectedTitle = document.title;
  let currentPath = location.pathname;
  let serial = 0;
  if (textOnly) document.body.classList.add('text-only');
  function readerLabel() {
    summary.textContent = reader.open ? 'Return to interactive view' : 'Read page as text';
  }
  reader.addEventListener('toggle', readerLabel);
  document.addEventListener('nib-app-ready', () => {
    if (!textOnly) reader.open = false;
    document.title = expectedTitle;
    readerLabel();
  });
  document.addEventListener('nib-app-failed', () => {
    reader.open = true;
    summary.textContent = 'Interactive view unavailable — text is ready';
  });
  // Flutter also writes the browser title. Keep it aligned with this route's HTML.
  new MutationObserver(() => {
    if (document.title !== expectedTitle) document.title = expectedTitle;
  }).observe(document.querySelector('title'), {childList:true,subtree:true});
  async function syncRoute() {
    if (currentPath === location.pathname) return;
    currentPath = location.pathname;
    const request = ++serial;
    try {
      const response = await fetch(currentPath, {headers: {Accept:'text/html'}});
      const next = new DOMParser().parseFromString(await response.text(), 'text/html');
      if (request !== serial) return;
      const content = next.getElementById('page-content');
      if (!content) return;
      document.getElementById('page-content').replaceWith(content);
      expectedTitle = next.title;
      document.title = expectedTitle;
      document.querySelectorAll('[data-page-meta]').forEach(node => node.remove());
      next.querySelectorAll('[data-page-meta]').forEach(node => document.head.append(node));
    } catch (_) {
      // Never show a previous lesson as the current one if the network fails.
      const article = document.getElementById('page-content');
      article.replaceChildren();
      const link = document.createElement('a');
      link.href = location.pathname + '?view=text';
      link.textContent = 'Reload this page in text view';
      article.append(link);
    }
  }
  for (const method of ['pushState', 'replaceState']) {
    const original = history[method];
    history[method] = function(...args) {
      const result = original.apply(this,args);
      syncRoute();
      return result;
    };
  }
  addEventListener('popstate',syncRoute);
})();
