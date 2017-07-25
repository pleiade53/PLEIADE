<?php
	require('controller.php');

	function pcc_add_machine($MAC, $modules, $config, $unit=""){
		if(pcc_is_machine($MAC))
		{
			echo "<script>alert(\"" . get_string("alreadym") . "\");</script>";
			echo "<meta http-equiv=\"refresh\" content=\"0; url=/pcc/?view=machine\"/>";
			return;
		}
		$module_str = "";
		foreach($modules as $m)
			$module_str .= "$m ";
		$config_str = "";
		foreach($config as $c)
			$config_str .= "$c ";
		echo shell_exec("/bin/pleiade-setup-client.sh \"$module_str\" \"$config_str\" 2>&1");
		//echo "<meta http-equiv=\"refresh\" content=\"0; url=/pcc/?view=machine\"/>";
		return;

	}

	function pcc_modify_machine($MAC, $modules, $config){
		
	}
	function pcc_delete_machine($MAC){
		
	}
	function pcc_add_user($username, $modules){

	}
	function pcc_modify_user($username, $modules){
		
	}
	function pcc_delete_user($username){
		
	}

	$machine_mac = "";
	if(!empty($_POST['mac_address']))
	{
		$machine_mac = filter_var($_POST['mac_address'], FILTER_VALIDATE_MAC);
		if ($machine_mac == false){
			// This is not a mac address
			echo "<meta http-equiv=\"refresh\" content=\"0; url=/pcc/?view=error\"/>";
			return;
		}
	}

	$username = "";
	if(!empty($_POST['username']))
	{
		$username = filter_var($_POST['username'], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH);
		if ($username == false){
			// This is not a valid username
			echo "<meta http-equiv=\"refresh\" content=\"0; url=/pcc/?view=error\"/>";
			return;
		}
	}
	$password = "";
	if(!empty($_POST['password']))
	{
		$password = filter_var($_POST['password'], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH);
		if ($password == false){
			// This is not a valid username
			echo "<meta http-equiv=\"refresh\" content=\"0; url=/pcc/?view=error\"/>";
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
			echo "<meta http-equiv=\"refresh\" content=\"0; url=/pcc/?view=error\"/>";
			return;
		}
	}

	$config = array();
	if (!empty($_POST['machine_type']))
	{
		$config['type'] = $_POST['machine_type'];
	}
	if (!empty($_POST['con_req']))
	{
		$config['con_req'] = filter_var($_POST['con_req'], FILTER_VALIDATE_BOOLEAN);
	}
	if ($config['type'] == "kiosk" && !empty($_POST['kiosk_url']))
	{
		$config['url'] = filter_var($_POST['kiosk_url'], FILTER_VALIDATE_URL);
		if ($config['url'] == false){
			// This is not a valid url
			echo "<meta http-equiv=\"refresh\" content=\"0; url=/pcc/?view=error\"/>";
			return;
		}
	}

	echo "<ul>
		<li>$machine_mac</li>
		<li>$username</li>
		<li>" . var_dump($config) . "</li>
		<li>" . var_dump($_POST['module_check']) . "</li>
	</ul>";

	if(isset($_POST['add_machine']))
		pcc_add_machine($machine_mac, $checked_modules, $config, $unit);
	if(isset($_POST['modify_machine']))
		pcc_modify_machine($machine_mac, $checked_modules, $config);
	if(isset($_POST['delete_machine']))
		pcc_delete_machine($machine_mac);
	if(isset($_POST['add_user']))
		pcc_add_user();
	if(isset($_POST['modify_user']))
		pcc_modify_user();
	if(isset($_POST['delete_user']))
		pcc_delete_user();
?>