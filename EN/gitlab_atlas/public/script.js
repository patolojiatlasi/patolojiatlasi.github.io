window.addEventListener('DOMContentLoaded', function() {
  // "Case of The Day" exists only on the home page.
  const iframe = document.getElementById('randomIframe');
  if (!iframe) return;

  const url = webPages[Math.floor(Math.random() * webPages.length)];
  iframe.src = url;

  const headingLink = document.createElement('a');
  headingLink.href = url;
  headingLink.textContent = 'Case of The Day';
  headingLink.target = "_blank"; // Open in a new window or tab

  document.getElementById('heading').appendChild(headingLink);
});
