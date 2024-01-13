console.log("JS started");
const scroll = new LocomotiveScroll({
  el: document.querySelector("body"),
  smooth: true,
  //multiplier: 0.5,
});
Shery.mouseFollower();
Shery.imageEffect("#back", {
  style: 5,
  config: {
    a: { value: 2, range: [0, 30] },
    b: { value: -0.98, range: [-1, 1] },
    zindex: { value: -9996999, range: [-9999999, 9999999] },
    aspect: { value: 2.0251334805070296 },
    ignoreShapeAspect: { value: true },
    shapePosition: { value: { x: 0, y: 0 } },
    shapeScale: { value: { x: 0.5, y: 0.5 } },
    shapeEdgeSoftness: { value: 0, range: [0, 0.5] },
    shapeRadius: { value: 0, range: [0, 2] },
    currentScroll: { value: 0 },
    scrollLerp: { value: 0.07 },
    gooey: { value: true },
    infiniteGooey: { value: true },
    growSize: { value: 4, range: [1, 15] },
    durationOut: { value: 1, range: [0.1, 5] },
    durationIn: { value: 1.5, range: [0.1, 5] },
    displaceAmount: { value: 0.5 },
    masker: { value: false },
    maskVal: { value: 1, range: [1, 5] },
    scrollType: { value: 0 },
    geoVertex: { range: [1, 64], value: 1 },
    noEffectGooey: { value: true },
    onMouse: { value: 0 },
    noise_speed: { value: 0.2, range: [0, 10] },
    metaball: { value: 0.199666, range: [0, 2], _gsap: { id: 5 } },
    discard_threshold: { value: 0.99, range: [0, 1] },
    antialias_threshold: { value: 0, range: [0, 0.1] },
    noise_height: { value: 0.47, range: [0, 2] },
    noise_scale: { value: 10, range: [0, 100] },
  },
  gooey: true,
});

// Get all the h2 elements
var headings = document.querySelectorAll(".innerheadings h2");

// Hide all the h2 elements except the first one
for (var i = 1; i < headings.length; i++) {
  headings[i].style.display = "none";
}

// Initialize the current heading index
var currentHeadingIndex = 0;

// Add a click event listener to the container
document.querySelector(".homecontainer").addEventListener("click", function () {
  // Animate the current heading out
  gsap.to(headings[currentHeadingIndex], {
    duration: 0.5,
    opacity: 0,
    onComplete: showNextHeading,
  });
});

function showNextHeading() {
  // Hide the current heading
  headings[currentHeadingIndex].style.display = "none";

  // Move to the next heading
  currentHeadingIndex++;

  // If we've reached the end of the headings, go back to the first one
  if (currentHeadingIndex === headings.length) {
    currentHeadingIndex = 0;
  }

  // Show the next heading
  headings[currentHeadingIndex].style.display = "block";

  // Animate the next heading in
  gsap.fromTo(
    headings[currentHeadingIndex],
    { opacity: 0 },
    { duration: 0.5, opacity: 1 }
  );
}

//blockchain

async function connect() {
  if (window.ethereum.isConnected()) {
    if (typeof window.ethereum !== "undefined") {
      try {
        await ethereum.request({ method: "eth_requestAccounts" });
        document.getElementById("connectButton").innerHTML = "Connected";
        const accounts = await ethereum.request({ method: "eth_accounts" });
        console.log(accounts);
      } catch (error) {
        console.log(error);
      }
    } else {
      document.getElementById("connectButton").innerHTML =
        "Please install MetaMask";
    }
  } else {
    document.getElementById("connectButton").innerHTML = "Link Wallet";
  }
}
