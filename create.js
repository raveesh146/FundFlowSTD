// Global array to store proposal data
var proposals = [];

document.getElementById("createButton").addEventListener("click", function () {
  // Get values from input fields
  var proposalName = document.getElementById("proposalName").value;
  var shortDescription = document.getElementById("shortDescription").value;
  var amountToRaise = document.getElementById("amountToRaise").value;
  var milestones = document.getElementById("milestones").value;
  var deadline = document.getElementById("deadline").value;

  // Create an object with the input values
  var proposal = {
    name: proposalName,
    description: shortDescription,
    amount: amountToRaise,
    milestones: milestones,
    deadline: deadline,
  };

  // Store the proposal object in the global array
  proposals.push(proposal);

  // Log the current state of the proposals array (for demonstration purposes)
  console.log(proposals);
  document.getElementById("proposalName").innerHTML = "";
  document.getElementById("shortDescription").innerHTML = "";
  document.getElementById("amountToRaise").innerHTML = "";
  document.getElementById("milestones").innerHTML = "";
  document.getElementById("deadline").innerHTML = "";
});
