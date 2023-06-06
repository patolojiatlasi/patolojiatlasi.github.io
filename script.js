// Function to generate a random index
function getRandomIndex(max) {
    return Math.floor(Math.random() * max);
}

// Function to load web page URLs from a text file
function loadWebPagesFromFile(file, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            var webPages = xhr.responseText.split("\n");
            callback(webPages);
        }
    };
    xhr.open("GET", file, true);
    xhr.send();
}

// Set a random web page as the src of the iframe
function setRandomWebPage(webPages) {
    var randomIndex = getRandomIndex(webPages.length);
    var iframe = document.getElementById("randomIframe");
    iframe.src = webPages[randomIndex];

    var iframeContainer = document.getElementById("iframeContainer");
    var headingLink = document.createElement("a");
    headingLink.href = webPages[randomIndex];
    headingLink.textContent = "Case of The Day";

    var heading = document.createElement("h1");
    heading.appendChild(headingLink);
    iframeContainer.insertBefore(heading, iframe);
}

// Load web page URLs from a text file and set a random web page
loadWebPagesFromFile("webpages.txt", setRandomWebPage);
