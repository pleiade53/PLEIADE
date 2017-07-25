<?php
	
	require('controller.php');	
	
	// Disconnect
	function pcc_disconnect_user($user)
	{
		return "<script>
			function logout() {
				$.ajax({
						type: \"GET\",
						url: \"/pcc\",
						dataType: 'json',
						async: true,
						username: \"some_username_that_doesn't_exist\",
						password: \"any_stupid_password\",
						data: '{ \"comment\" }'
				})
				.done(function(){
					// If we don't get an error, we actually got an error as we expect an 401!
					alert(\"Something went wrong, I didn't receive an error\");
				})
				.fail(function(){
					window.location = \"/pvd\";
				});
			 
				return false;
			}
		</script>";
	
	}
	
	// Generate navbar html
	// TODO: add other configurable modules 
	function pcc_view_navbar($selected){
		$viewed=array("machines" => "", "users" => "");
		if(isset($selected))
			$viewed["$selected"] = "selected";
		return "
		<div class=\"navbar\">
			<div class=\"disconnect\" onclick=\"logout();\"><img src=\"/pvd/resources/disconnect.png\"><span class=\"infobulle\">" . get_string("disconnect") . " " . $_SERVER['PHP_AUTH_USER'] . "</span></div>
			<ul>
				<li><a href=\"https://9.0.0.1:9090\">Cockpit <span class=\"infobulle\">" . get_string("cockpit") . "</span></a></li>
				<li><a class=\"". $viewed["machines"] . "\" href=\"/pcc/?view=machines\">" . get_string("machines") . "<span class=\"infobulle\">" . get_string("amdm") . "</span></a></li>
				<li><a class=\"". $viewed["users"] . "\" href=\"/pcc/?view=users\">" . get_string("users") . "<span class=\"infobulle\">" . get_string("amdu") . "</span></a></li>		
			</ul>
		</div>
		";
	}
	
	
	
	function pcc_view_listmachines($machines){
		return "
			<table>
				<tr>
					<th>MAC</th>
					<th>IP (VPN)</th>
					<th>Action</th>
				</tr>
				$machines
				<tr>
					<td>------</td>
					<td>------</td>
					<td><a href=\"/pcc?view=machines&action=add\"><img src=\"resources/add.png\"><span class=\"infobulle\">" . get_string("addm") . "</span></a></td>
				<tr>
			</table>
		";		
	}
	
	
	
	function pcc_view_listusers($users){
		return "
			<table>
				<tr>
					<th>" . get_string("username") . "</th>
					<th>Action</th>
				</tr>
				$users
				<tr>
					<td>------</td>
					<td><a href=\"/pcc?view=users&action=add\"><img src=\"resources/add.png\"><span class=\"infobulle\">" . get_string("addu") . "</span></a></td>
				<tr>
			</table>
		";
	}
	
	function pcc_view_userentry($user)
	{
		return "
		<tr>
			<td>$user</td>
			<td><a href=\"/pcc?view=users&action=modify&subject=$user\"><img src=\"resources/edit.png\"><span class=\"infobulle\">" . get_string("modu") . "</span></a><a href=\"/pcc?view=users&action=delete&subject=$user\"><img src=\"resources/delete.svg\"><span class=\"infobulle\">" . get_string("delu") . "</span></a></td>
		</tr>
		";
	}
	function pcc_view_useradd()
	{
		$list = pcc_get_modulelist();
		$array_list = array();
		foreach($list as $module)
		{
			$array_list["$module"] = "";
		}
		$modules_list = pcc_view_modulecheckbox($array_list);
		return "
			<form action=\"handler.php\" method=\"post\" ><br>
				<input required type=\"text\" name=\"username\" placeholder=\"" . get_string("username") . "\">
				<input required type=\"password\" name=\"password\" placeholder=\"" . get_string("password") . "\">
				<fieldset>
					<legend>Modules:</legend>
					$modules_list					
				</fieldset>
				<input type=\"submit\" name=\"add_user\" value=\"OK\">
			</form>
		";
	}
	
	function pcc_view_usermodify($user)
	{
		$modules_list = pcc_view_modulecheckbox(pcc_generate_modulecheckbox_user($user));
		return "
			<form action=\"handler.php\" method=\"post\"><br>
				<input type=\"text\" name=\"username\" value=\"$user\" readonly>
				<input type=\"password\" name=\"password\" placeholder=\"" . get_string("password") . "\">
				<fieldset>
					<legend>Modules:</legend>
					$modules_list					
				</fieldset>
				<input type=\"submit\" name=\"modify_user\" value=\"OK\">
			</form>
		";
	}
	
	function pcc_view_userdelete($user)
	{
		return "
			<form action=\"handler.php\" method=\"post\"><br>
				" . get_string("realy") . " $user?<br>
				<input type=\"submit\" name=\"delete_user\" value=\"OK\">
			</form>
		";
	}
	
	function pcc_view_users($action, $subject){
		if ($action == "")
		{
			$htmlusers="";
			foreach(pcc_get_userslist() as $user)
			{
				$htmlusers .= pcc_view_userentry($user);
			}
			return pcc_view_listusers($htmlusers);
		
		}
		if ($action == "add")
		{
			return pcc_view_useradd();
		}
		if (!pcc_is_user($subject))
			return pcc_view_users("", "");
		if($action == "modify")
		{
			return pcc_view_usermodify($subject);
		}
		if($action == "delete")
		{
			return pcc_view_userdelete($subject);
		}
		return pcc_view_users("", "");
	}

	function pcc_view_machineentry($MAC, $IP, $is_online)
	{
		$online_class="";
		if ($is_online == "true")
			$online_class="class=\"online\"";
		return "
		<tr $online_class>
			<td>$MAC</td>
			<td>$IP</td>
			<td><a href=\"/pcc?view=machines&action=modify&subject=$MAC\"><img src=\"resources/edit.png\"><span class=\"infobulle\">" . get_string("modm") . "</span></a><a href=\"/pcc?view=machines&action=delete&subject=$MAC\"><img src=\"resources/delete.svg\"><span class=\"infobulle\">" . get_string("delm") . "</span></a></td>
		</tr>
		";
	}
	function pcc_view_machineadd()
	{
		$list = pcc_get_modulelist();
		$array_list = array();
		foreach($list as $module)
		{
			$array_list["$module"] = "";
		}
		$modules_list = pcc_view_modulecheckbox($array_list);

		return "
			<form action=\"handler.php\" method=\"post\" ><br>
				<input required type=\"text\" name=\"mac_address\" placeholder=\"" . get_string("MAC") . "\">
				<fieldset>
					<legend>Modules:</legend>
					$modules_list					
				</fieldset>
				<br>
				<fieldset>
					<legend>Configuration:</legend>
					<br>
					<select required name=\"machine_type\">
						<option selected disabled>Type</option>
						<option value=\"user\">" . get_string("full") . "</option>
						<option value=\"kiosk\">Kiosk</option>
					</select><br><br>
					<input type=\"checkbox\" name=\"con_req\" value=\"true\">" . get_string("bootcon") . "<br><br>
					<input type=\"text\" name=\"kiosk_url\" placeholder=\"" . get_string("kioskurl") . "\"><br><br>	
				</fieldset><br>
				<input type=\"text\" name=\"unit\" placeholder=\"" . get_string("unit") . "\"><br><br>
				<input type=\"submit\" name=\"add_machine\" value=\"OK\"><br>
			</form>
		";
	}
	
	function pcc_view_machinemodify($MAC)
	{
		$modules_list = pcc_view_modulecheckbox(pcc_generate_modulecheckbox_machine($MAC));
		return "
			<form action=\"handler.php\" method=\"post\"><br>
				<input type=\"text\" name=\"mac_address\" value=\"$MAC\" readonly>
				<fieldset>
					<legend>Modules:</legend>
					$modules_list					
				</fieldset>
				<br>
				<fieldset>
					<legend>Configuration:</legend>
					<br>
					<select required name=\"machine_type\">
						<option selected disabled>Type</option>
						<option value=\"user\">" . get_string("full") . "</option>
						<option value=\"kiosk\">Kiosk</option>
					</select><br><br>
					<input type=\"checkbox\" name=\"con_req\" value=\"con_req\">" . get_string("bootcon") . "<br><br>
					<input type=\"text\" name=\"kiosk_url\" placeholder=\"" . get_string("kioskurl") . "\"><br><br>	
				</fieldset><br><br>
				<input type=\"submit\" name=\"modify_machine\" value=\"OK\"><br>
			</form>
		";
	}
	
	function pcc_view_machinedelete($MAC)
	{
		return "
			<form action=\"handler.php\" method=\"post\"><br>
				" . get_string("realy") . " $MAC?<br>
				<input type=\"submit\" name=\"delete_machine\" value=\"OK\">
			</form>
		";
	}

	function pcc_view_machines($action, $subject){
		if ($action == "")
		{
			$htmlmachines="";
			foreach(pcc_get_machinelist() as $machine)
			{
				$entry = explode(" ; ", $machine);
				$htmlmachines .= pcc_view_machineentry($entry[0], $entry[1], $entry[2]);
			}
			return pcc_view_listmachines($htmlmachines);
		
		}
		if ($action == "add")
		{
			return pcc_view_machineadd();
		}
		if (!pcc_is_machine($subject))
			return pcc_view_machines("", "");
		if($action == "modify")
		{
			return pcc_view_machinemodify($subject);
		}
		if($action == "delete")
		{
			return pcc_view_machinedelete($subject);
		}
		return pcc_view_machines("", "");
	}
	
	
	
	// Pass an array ( "module1" => "checked", "module2" => "", ...)
	// If module is "checked", return checked checkbox
	function pcc_view_modulecheckbox($modules)
	{
		$str = "";
		foreach (array_keys($modules) as $module)
		{
			$str .= "<input type=\"checkbox\" name=\"module_check[]\" value=\"$module\" " . $modules["$module"] . "> $module<br>";
		}
		return $str;
	}
	
	
	function pcc_view_page($content)
	{
		echo "<!DOCTYPE html>
		
		<html>
			<head>
				<title>Pleiade Control Center</title>
				<link rel=\"stylesheet\" type=\"text/css\" href=\"/pcc/css/pcc.css\">
				<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js\"></script>
				" . pcc_disconnect_user($_SERVER['PHP_AUTH_USER']) . "
				
			</head>
			<body>
				$content
			</body>
		</html>";
	}

	function pcc_view_error(){
			return "
			<div class=\"error\">
				<p>
					" . get_string("notallowed") . " 
				</p>
			</div>
		";
	}
	
	// Urls are of the form:
	// pcc?view=...&action=...&subject=...
	// View might be: user, machines
	// action: add, modify, delete
	// subject: username or MAC @
	function pcc_view_selector($view, $action, $subject)
	{
		if (!isset($view))
			return pcc_view_page(pcc_view_navbar(""));
		if ($view == "users")
		{
			return pcc_view_page(pcc_view_navbar("users") . pcc_view_users($action, $subject));
		}
		elseif ($view == "machines")
		{
			return pcc_view_page(pcc_view_navbar("machines") . pcc_view_machines($action, $subject));
		}
		elseif ($view == "error")
		{
			return pcc_view_page(pcc_view_navbar("") . pcc_view_error());
		}
		else
		{
			return pcc_view_page(pcc_view_navbar(""));
		}
		
	}
	
?>
