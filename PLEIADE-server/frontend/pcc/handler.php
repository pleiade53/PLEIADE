<?php
	require('controller.php');

	function pcc_add_machine($MAC, $modules, $config, $unit=""){
		if(pcc_is_machine($MAC))
		{
			echo "<script>alert(\"" . get_string("alreadym") . "\");</script>";
			echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=machines\"/>";
			return;
		}
		$module_str = "";
		foreach($modules as $m)
			$module_str .= "$m ";
		$config_str = "";
		foreach($config as $c)
			$config_str .= "$c ";
		echo "/bin/run_root /bin/pleiade-setup-client.sh $MAC \"$module_str\" \"$config_str\" : <br>";
		echo shell_exec("/bin/run_root /bin/pleiade-setup-client.sh $MAC \"$module_str\" \"$config_str\" 2>&1");
		echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=machines\"/>";
		return;

	}

	function pcc_modify_machine($MAC, $modules, $config){
		if(!pcc_is_machine($MAC))
		{
			echo "<script>alert(\"$MAC " . get_string("notm") . "\");</script>";
			echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=machines\"/>";
			return;
		}

		$ip = pcc_get_machine_ip($MAC);
		
		// remove all module and then re-enable them
		foreach (pcc_get_machinemodules($MAC) as $mod) {
			shell_exec("/bin/run_root /bin/pleiade-allow-module.sh disallow $ip $mod");
		}
		foreach($modules as $m)
			shell_exec("/bin/run_root /bin/pleiade-allow-module.sh allow $ip $m");

		// generate argument list for configurator
		$config_str = "--mode=" . $config["type"] . " --con_req=" . $config["con_req"];
		if($config["type"] && !empty($config["url"]))
			$config_str .= "--kiosk_url=" . $config["url"];

		shell_exec("/bin/run_root /bin/pleiade-write-userconfig.sh $MAC $config_str");
		echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=machines\"/>";
		return;
	}
	function pcc_delete_machine($MAC){
		echo $MAC;
		if(!pcc_is_machine($MAC))
		{
			echo "<script>alert(\"" . get_string("notm") . "\");</script>";
			echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=machines\"/>";
			return;
		}
		echo shell_exec("/bin/run_root /bin/pleiade-setup-client.sh $MAC delete 2>&1");
		echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=machines\"/>";
	}
	function pcc_add_user($username, $password, $modules){
		if(empty($password) || empty($username))
		{
			echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=users\"/>";
			return;
		}
		$module_str = "";
		foreach($modules as $m)
		{
			$module_str .= " addmodule=$m";
		}
		shell_exec("/bin/run_root /bin/pleiade-user-manager.sh add \"username=$username password=$password $module_str\"");
		echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=users\"/>";
		return;
	}
	function pcc_modify_user($username, $password, $modules){
		if(empty($username))
		{
			echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=users\"/>";
			return;
		}
		$module_str = "";
		//delete the ones that was in previous module list but are not in the new
		echo "del:<br>";
		var_dump($modules);
		var_dump(pcc_get_usermodules($username));
		foreach(array_diff(pcc_get_usermodules($username), $modules) as $m)
		{
			echo "$m <br>";
			$module_str .= " delmodule=$m";
		}
		// Add the ones that was not in previous module list but are not in the new
		echo "add:<br>";
		foreach(array_diff($modules, pcc_get_usermodules($username)) as $m)
		{
			
			echo "$m <br>";
			$module_str .= " addmodule=$m";
		}
		$password_str = "";
		if (!empty($password))
			$password_str = "password=$password";

		shell_exec("/bin/run_root /bin/pleiade-user-manager.sh add \"username=$username $password_str $module_str\"");
		//echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=users\"/>";
		return;
	}
	function pcc_delete_user($username){
		
	}

	$machine_mac = "";
	if(!empty($_POST['mac_address']))
	{
		$machine_mac = filter_var($_POST['mac_address'], FILTER_VALIDATE_MAC);
		echo "<script>alert(\"" . $_POST['mac_address'] . "\");</script>";
		if ($machine_mac == false){
			// This is not a mac address
			//echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=error\"/>";
			return;
		}
	}

	$username = "";
	if(!empty($_POST['username']))
	{
		$username = filter_var($_POST['username'], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH);
		if ($username == false){
			// This is not a valid username
			echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=error\"/>";
			return;
		}
	}
	$password = "";
	if(!empty($_POST['password']))
	{
		$password = filter_var($_POST['password'], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH);
		if ($password == false){
			// This is not a valid username
			echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=error\"/>";
			return;
		}
	}

	$checked_modules = array();
	if(!empty($_POST['module_check'])){
		foreach ($_POST['module_check'] as $mod) {
			array_push($checked_modules, filter_var($mod, FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH));
		}
	}

	$unit = "";
	if(!empty($_POST['unit']))
	{
		$unit = filter_var($_POST['unit'], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH);
		if ($unit == false){
			// This is not a valid username
			echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=error\"/>";
			return;
		}
	}

	$config = array();
	if (!empty($_POST['machine_type']))
	{
		$config['type'] = $_POST['machine_type'];
		if ($config['type'] == "kiosk" && !empty($_POST['kiosk_url']))
		{
			$config['url'] = filter_var($_POST['kiosk_url'], FILTER_VALIDATE_URL);
			if ($config['url'] == false){
				// This is not a valid url
				echo "<meta http-equiv=\"refresh\" content=\"10; url=/pcc/?view=error\"/>";
				return;
			}
		}
	}
	if (!empty($_POST['con_req']))
	{
		$config['con_req'] = filter_var($_POST['con_req'], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH);
	}
	

	if(isset($_POST['add_machine']))
		pcc_add_machine($machine_mac, $checked_modules, $config, $unit);
	if(isset($_POST['modify_machine']))
		pcc_modify_machine($machine_mac, $checked_modules, $config);
	if(isset($_POST['delete_machine']))
		pcc_delete_machine($machine_mac);
	if(isset($_POST['add_user']))
		pcc_add_user($username, $password, $checked_modules);
	if(isset($_POST['modify_user']))
		pcc_modify_user($username, $password, $checked_modules);
	if(isset($_POST['delete_user']))
		pcc_delete_user($username);
?>