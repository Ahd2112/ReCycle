"use strict";
var leader1 = parseFloat(document.getElementById("first").innerHTML);
var leader2 = parseFloat(document.getElementById("second").innerHTML);
var leader3 = parseFloat(document.getElementById("third").innerHTML);
var previous = -1;

(function () {
	window.onload = function () {
		var client = new XMLHttpRequest();
		client.open('GET', 'http://students.washington.edu/bharatis/distances.txt');
		client.onreadystatechange = function() {
			var response = client.responseText;
			var nums = response.split(";", 20);
			nums.sort(function(a, b){return parseFloat(b)-parseFloat(a)});
			//document.getElementById("list1").innerHTML = nums[nums.length - 2];
			//document.getElementById("list2").innerHTML = nums[nums.length - 3];
			//document.getElementById("list3").innerHTML = nums[nums.length - 4];
			document.getElementById("list1").innerHTML = nums[0];
			document.getElementById("list2").innerHTML = nums[1];
			document.getElementById("list3").innerHTML = nums[2];
			
		}
		client.send();
	}
	
	function updateboard(newScore) {
		
		if(newScore > leader1) {
			document.getElementById("third").innerHTML = leader2;
			document.getElementById("second").innerHTML = leader1;
			document.getElementById("first").innerHTML = newScore;
		} else if(newScore > leader2) {
			document.getElementById("third").innerHTML = leader2;
			document.getElementById("second").innerHTML = newScore;
		} else if(newScore > leader3) {
			document.getElementById("third").innerHTML = newScore;
		}
	}	
	
})();