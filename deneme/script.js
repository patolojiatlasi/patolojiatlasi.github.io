// List of web pages
var webPages = [
"https://images.patolojiatlasi.com/myxoidliposarcoma/HE.html",
"https://images.patolojiatlasi.com/acute-appendicitis/HE.html",
"https://images.patolojiatlasi.com/amyloid/crystalviolet.html",
"https://images.patolojiatlasi.com/congored/congored.html",
"https://images.patolojiatlasi.com/ampullary-adenocarcinoma/HE.html",
];

// Function to generate a random index
function getRandomIndex(max) {
    return Math.floor(Math.random() * max);
}

// Set a random web page as the src of the iframe
var randomIndex = getRandomIndex(webPages.length);
var iframe = document.getElementById("randomIframe");
iframe.src = webPages[randomIndex];
