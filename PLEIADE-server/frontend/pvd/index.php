<?php 
    $user = $_SERVER['PHP_AUTH_USER'];
	header("Location: $user/");      
?>
