<?php
	
	//if(isset($_POST["Distance"])) {
		$distance = $_POST["Distance"];
	//}
	$file = 'distances.txt';
	//$distance .= "\n" .
	if(isset($distance)) {
		$distance .= file_get_contents($file);
		file_put_contents($file, $distance);
	}
		
	echo $distance . "\n";
	
?>


<html>


<head>
	<meta http-equiv="refresh" content="35">
	<meta http-equiv="cache-control" content="no-cache, must-revalidate, post-check=0, pre-check=0" />
	<meta http-equiv="cache-control" content="max-age=0" />
	<meta http-equiv="expires" content="0" />
	<meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT" />
	<meta http-equiv="pragma" content="no-cache" />
	<link href="background.css" rel="stylesheet" type="text/css">
	<link href="https://fonts.googleapis.com/css?family=Rubik" rel="stylesheet">
	
</head>


<body>
	<div class="bg">
		<div class="position">
			<ul style="list-style: none;">
				<li><strong>First Place   ..........  </strong><strong id="list1"></strong>mi  <textarea id="first"> </textarea></li>
				<li><strong>Second Place  ..........  </strong><strong id="list2"></strong>mi  <textarea id="second"> </textarea></li>
				<li><strong>Third Place  .......... </strong><strong id="list3"></strong>mi  <textarea id="third"> </textarea></li>
			</ul>
		</div>
	</div>
</body>
<script src="update.js" type="text/javascript"></script>
<html>	