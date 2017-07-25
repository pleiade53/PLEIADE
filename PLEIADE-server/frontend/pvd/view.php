<?php
	
	function get_string($name)
	{
		$browser_lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
		if($browser_lang == "" || !file_exists("/pvd/strings/$browser_lang")
		{
			$browser_lang='en';
		}
		$str = shell_exec("/bin/grep -e \"^$name >=<\" /var/www/html/pvd/strings/$browser_lang | /bin/awk -F' >=< ' '{print $2}'");
		return rtrim($str, "\n");
	}

	function pvd_view_headbanner($user)
	{
		$str = "<div class=\"header\">
			<div class=\"welcome\">
				" . get_string("welcome") . ", $user
			</div>
			<div class=\"disconnect\" onclick=\"logout();return false;\"><img src=\"/pvd/resources/disconnect.png\"\"><span class=\"infobulle\"> " . get_string("disconnect") . " $user</span></div>
		</div>";
		return $str;
	}
	function pvd_view_icons_box($icons)
	{
		$str = "<div class=\"icons_box\">
			$icons
		</div>";
		return $str;
	}
	function pvd_view_icon($label, $image, $info, $link)
	{
		return "<a target=\"_blank\" class=\"module_icon\" href=\"$link\">
			<img src=\"$image\" alt=\"$info\"><span class=\"icon_name\">$label</span><span class=\"infobulle\">$info</span></a>";
	}
	function pvd_view_icons_list($list)
	{
		$result = "<ul>";
		foreach ($list as $icon){
			$result .= "<li>$icon</li>";
		}
		return $result . "</ul>";
	}
	
	function pvd_disconnect_user($user)
	{
		return "<script>
			function logout() {
				$.ajax({
						type: \"GET\",
						url: \"/pvd/$user\",
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
					// We expect to get an 401 Unauthorized error! In this case we are successfully 
						// logged out and we redirect the user.
					window.location = \"/pvd\";
				});
			 
				return false;
			}
		</script>";
	
	}
	
	//Draw <html>, <body>, ...
	function pvd_view_page($content)
	{
		echo "<!DOCTYPE html>
		
		<html>
			<head>
				<title>Pleiade Virtual Desktop</title>
				<link rel=\"stylesheet\" type=\"text/css\" href=\"/pvd/css/pvd.css\">
				<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js\"></script>
				
			</head>
			<body>
				$content
			</body>
		</html>";
	}
	
	function pvd_controller_generate_list($user){		
		
		// retrieve user modules info
		$modules_list = shell_exec("/bin/pleiade-get-usermodules.sh $user");
		$html_modules_list= array();
		foreach(explode("\n", $modules_list) as $module)
		{		
			if($module == "")
			{
				continue;
			}
			// format: label ; image ; info ; link
			$splited_mod = explode(" ; ", $module);
			$icon = pvd_view_icon($splited_mod[0], $splited_mod[1], $splited_mod[2], $splited_mod[3]);
			array_push($html_modules_list, $icon);
		}
		return $html_modules_list;
	}
	function pvd_draw_page()
	{
		$user = $_SERVER['PHP_AUTH_USER'];
		$headbanner = pvd_view_headbanner($user);
		$modules_list = pvd_controller_generate_list($user);
		$icons_box = pvd_view_icons_box(pvd_view_icons_list($modules_list));
		
		pvd_view_page(pvd_disconnect_user($user) . $headbanner . $icons_box);
	}
?>
