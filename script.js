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


// Your unique key
const key = "patolojiatlasi_com_home";

// Fetch the current count
fetch(`https://api.countapi.xyz/get/${key}`)
    .then(response => response.json())
    .then(data => {
        const count = data.value;
        document.getElementById("visitorCount").innerText = count;

        // Increment the count for the next visitor
        fetch(`https://api.countapi.xyz/hit/${key}`);
    })
    .catch(console.error);
