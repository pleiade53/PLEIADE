<?php

	function get_string($name)
	{
		$browser_lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
		if($browser_lang == "" || !file_exists("/pcc/strings/$browser_lang"))
		{
			$browser_lang='en';
		}
		$browser_lang='fr';
		$str = shell_exec("/bin/grep -e \"^$name >=<\" /var/www/html/pcc/strings/$browser_lang | /bin/awk -F' >=< ' '{print $2}'");
		return rtrim($str, "\n");
	}
	function pcc_get_machine_ip($mac)
	{
		foreach(pcc_get_machinelist() as $machine)
		{
			$entry = explode(" ; ", $machine);
			if($entry[0] == $mac)
				return $entry[1];
		}
	}
	
	function pcc_generate_machinelist()
	{
		$htmllist="";
		foreach(pcc_get_machinelist() as $machine)
		{
			if($machine == "")
				continue;
			$splitted = explode(" ; ", $machine);
			$htmllist .= pcc_view_machineentry($splitted[0], $splitted[1], ($splitted[2] == "true"));
		}
		return htmllist;	
	}
	
	function pcc_is_user($user)
	{
		if(shell_exec("/bin/grep \"^$user:\" /var/www/html/pcc/.htpasswd") == "")
			return false;
		else
			return true;
	}

	function pcc_is_machine($machine)
	{
		if(shell_exec("run_root /bin/pleiade-is-machine.sh $machine") == "")
			return false;
		else
			return true;
	}

	function pcc_get_machinelist()
	{
		return array_diff(explode("\n", shell_exec("/bin/run_root /bin/pleiade-get-machinelist.sh")), array(""));
	}

	function pcc_get_modulelist()
	{
		$list = explode("\n", shell_exec("/bin/ls -l /var/www/html | /bin/grep \"^d\" | /bin/awk '{ print $9}'"));
		$list = array_diff($list, array("pvd", ""));

		return $list;
	}
	
	function pcc_get_userslist()
	{
		return array_diff(explode("\n", shell_exec("/bin/cat /var/www/html/pcc/.htpasswd | /bin/cut -d':' -f1")), array(""));
	}
	
	function pcc_get_usermodules($user)
	{
		$rawusermodules = shell_exec("/bin/run_root /bin/pleiade-get-usermodules.sh $user");
		$moduleslist = array();
		foreach (explode("\n", $rawusermodules) as $row)
		{
			if (strpos($row, '/pvd/resources/browser.png') == false && $row != "") {
   				array_push($moduleslist, explode(" ; ", $row)[0]); 
			}
		}
		return $moduleslist;
	}
	
	// Generate an array ( "module1" => "checked", "module2" => "", ...)
	function pcc_generate_modulecheckbox_user($user){
		$generallist = pcc_get_modulelist();
		$userlist = pcc_get_usermodules($user);
		
		$result = array();
		// generate array with empty values
		foreach ($generallist as $module)
		{
			$result["$module"] = "";
		}
		// fill values with "checked" when relevant
		foreach ($userlist as $module)
		{
			$result["$module"] = "checked";
		}
		
		return $result;
	}

	function pcc_get_machinemodules($machine)
	{
		$rawmachinemodules = shell_exec("/bin/run_root /bin/pleiade-get-machinemodules.sh $machine");
		$moduleslist = array();
		foreach (explode("\n", $rawmachinemodules) as $row)
		{
			if ($row != "") {
   				array_push($moduleslist, $row); 
			}
		}
		return $moduleslist;
	}

	// Generate an array ( "module1" => "checked", "module2" => "", ...)
	function pcc_generate_modulecheckbox_machine($machine){
		$generallist = pcc_get_modulelist();
		$machinelist = pcc_get_machinemodules($machine);
		
		$result = array();
		// generate array with empty values
		foreach ($generallist as $module)
		{
			$result["$module"] = "";
		}
		// fill values with "checked" when relevant
		foreach ($machinelist as $module)
		{
			$result["$module"] = "checked";
		}
		
		return $result;
	}
?>