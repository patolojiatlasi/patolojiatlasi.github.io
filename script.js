window.addEventListener('DOMContentLoaded', function() {
  // Function to generate a random index
  function getRandomIndex(max) {
    return Math.floor(Math.random() * max);
  }

  // Get a random webpage index
  const randomIndex = getRandomIndex(webPages.length);

  // Display the random webpage
  const iframe = document.getElementById('randomIframe');
  iframe.src = webPages[randomIndex];

  const headingLink = document.createElement('a');
  headingLink.href = webPages[randomIndex];
  headingLink.textContent = 'Case of The Day';
  headingLink.target = "_blank"; // Open in a new window or tab

  const heading = document.getElementById('heading');
  heading.appendChild(headingLink);
});
