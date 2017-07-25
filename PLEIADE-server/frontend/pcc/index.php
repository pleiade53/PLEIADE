<?php
	require('view.php');
	$view="";
	$action="";
	$subject="";
	if(isset($_GET['view'])){
		$view = $_GET['view'];
	}
	if(isset($_GET['action']))
		$action = $_GET['action'];
	if(isset($_GET['subject']))
		$subject = $_GET['subject'];
	pcc_view_selector($view, $action, $subject);
?>
