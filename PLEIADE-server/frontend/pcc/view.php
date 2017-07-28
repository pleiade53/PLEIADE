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
	function pcc_view_navbar($selected="dashboard"){
		$viewed=array("machines" => "", "users" => "", "dashboard" => "", "logs" => "");
		if(isset($selected))
			$viewed["$selected"] = "class=\"active\"";
		return "
		<nav class=\"navbar navbar-inverse navbar-fixed-top\" role=\"navigation\">
			
			<div class=\"navbar-header\">
                <button type=\"button\" class=\"navbar-toggle\" data-toggle=\"collapse\" data-target=\".navbar-ex1-collapse\">
                    <span class=\"sr-only\">Toggle navigation</span>
                    <span class=\"icon-bar\"></span>
                    <span class=\"icon-bar\"<span>
                    <span class=\"icon-bar\"></span>
                </button>
                <a class=\"navbar-brand\" href=\"index.php\">Pleiade Control Center</a>
            </div>
			<ul class=\"nav navbar-right top-nav\">
				<li class=\"dropdown\">
                    <a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\"><i class=\"fa fa-user\"></i> " . $_SERVER['PHP_AUTH_USER'] . " <b class=\"caret\"></b></a>
                    <ul class=\"dropdown-menu\">
                        <li>
                            <a href=\"#\"><i class=\"fa fa-fw fa-envelope\"></i>(WIP) Inbox</a>
                        </li>
                        <li class=\"divider\"></li>
                        <li>
                            <a href=\"#\" onclick=\"logout();\"><i class=\"fa fa-fw fa-power-off\"></i>" . get_string("disconnect") . $_SERVER['PHP_AUTH_USER'] . "</a>
                        </li>
                    </ul>
                </li>
			</ul>
			<div class=\"collapse navbar-collapse navbar-ex1-collapse\">
                <ul class=\"nav navbar-nav side-nav\">
                    <li " . $viewed["dashboard"] . ">
                        <a href=\"index.php\"><i class=\"fa fa-fw fa-dashboard\"></i> Dashboard</a>
                    </li>
                    <li>
                        <a href=\"https://9.0.0.1:9090\"><i class=\"fa fa-fw fa-dashboard\"></i> Cockpit</a>
                    </li>
                    <li " . $viewed["machines"] . ">
                        <a href=\"/pcc/?view=machines\" ". "data-toggle=\"tooltip\" data-placement=\"right\" title=\"" . get_string("amdm") . "\"><i class=\"fa fa-fw fa-desktop\"></i> " . get_string("machines") . "</a>
                    </li>
                    <li " . $viewed["users"] . ">
                        <a href=\"/pcc/?view=users\"" . "data-toggle=\"tooltip\" data-placement=\"right\" title=\"" . get_string("amdu") . "\"><i class=\"fa fa-fw fa-user\"></i> " . get_string("users") . "</a>
                    </li>
                    <li " . $viewed["logs"] . ">
                        <a href=\"index.php\"><i class=\"fa fa-fw fa-file\"></i> Logs (WIP)</a>
                    </li>
                </ul>
            </div>
		</nav>
		";
	}
	
	
	
	function pcc_view_listmachines($machines){
		return "
			<div class=\"row\">
				<div class=\"col-lg-2\">
				</div>
                <div class=\"col-lg-8\">
                    <h2>" . get_string("amdm") . "</h2>
					<div class=\"table-responsive\">
			            <table class=\"table table-bordered table-hover table-striped\">
							<tr>
								<th>MAC</th>
								<th>IP (VPN)</th>
								<th>Action</th>
							</tr>
							$machines
							<tr>
								<td>------</td>
								<td>------</td>
								<td><a href=\"/pcc?view=machines&action=add\"" . "data-toggle=\"tooltip\" data-placement=\"right\" title=\"" . get_string("addm") . "\"><img src=\"resources/add.png\"></a></td>
							<tr>
						</table>
					</div>
				</div>
			</div>

		";		
	}
	
	
	
	function pcc_view_listusers($users){
		return "
			<div class=\"row\">
				<div class=\"col-lg-2\">
				</div>
                <div class=\"col-lg-8\">
                    <h2>" . get_string("amdu") . "</h2>
					<div class=\"table-responsive\">
			            <table class=\"table table-bordered table-hover table-striped\">
							<tr>
								<th>" . get_string("username") . "</th>
					<th>Action</th>
							</tr>
							$users
							<tr>
								<td>------</td>
					<td><a href=\"/pcc?view=users&action=add\"" . "data-toggle=\"tooltip\" data-placement=\"right\" title=\"" . get_string("addu") . "\"><img src=\"resources/add.png\"></a></td>
							<tr>
						</table>
					</div>
				</div>
			</div>";
	}
	
	function pcc_view_userentry($user)
	{
		return "
		<tr>
			<td>$user</td>
			<td><a href=\"/pcc?view=users&action=modify&subject=$user\" " . "data-toggle=\"tooltip\" data-placement=\"right\" title=\"" . get_string("modu") . "\"><img src=\"resources/edit.png\"> </a><a href=\"/pcc?view=users&action=delete&subject=$user\" " . "data-toggle=\"tooltip\" data-placement=\"right\" title=\"" . get_string("delu") . "\"><img src=\"resources/delete.svg\"></a></td>
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
		<div class=\"form-group\">
			<form action=\"handler.php\" method=\"post\" ><br>
				<input required type=\"text\" name=\"username\" placeholder=\"" . get_string("username") . "\">
				<input required type=\"password\" name=\"password\" placeholder=\"" . get_string("password") . "\">
				<fieldset>
					<legend>Modules:</legend>
					$modules_list					
				</fieldset>
				<input type=\"submit\" name=\"add_user\" value=\"OK\">
			</form>
		</div>
		";
	}
	
	function pcc_view_usermodify($user)
	{
		$modules_list = pcc_view_modulecheckbox(pcc_generate_modulecheckbox_user($user));
		return "
		<div class=\"form-group\">
			<form action=\"handler.php\" method=\"post\"><br>
				<input type=\"text\" name=\"username\" value=\"$user\" readonly>
				<input type=\"password\" name=\"password\" placeholder=\"" . get_string("password") . "\">
				<fieldset>
					<legend>Modules:</legend>
					$modules_list					
				</fieldset>
				<input type=\"submit\" name=\"modify_user\" value=\"OK\">
			</form>
		</div>
		";
	}
	
	function pcc_view_userdelete($user)
	{
		return "
		<div class=\"form-group\">
			<form action=\"handler.php\" method=\"post\"><br>
				" . get_string("realy") . " $user?<br>
				<input type=\"submit\" name=\"delete_user\" value=\"OK\">
			</form>
		</div>
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
			$online_class="class=\"valid\"";
		return "
		<tr $online_class>
			<td>$MAC</td>
			<td>$IP</td>
			<td><a href=\"/pcc?view=machine&action=modify&subject=$MAC\" " . "data-toggle=\"tooltip\" data-placement=\"right\" title=\"" . get_string("modm") . "\"><img src=\"resources/edit.png\"> </a><a href=\"/pcc?view=machine&action=delete&subject=$MAC\" " . "data-toggle=\"tooltip\" data-placement=\"right\" title=\"" . get_string("delm") . "\"><img src=\"resources/delete.svg\"></a></td>
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
			<div class=\"form-group\">
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
			</div>
		";
	}
	
	function pcc_view_machinemodify($MAC)
	{
		$modules_list = pcc_view_modulecheckbox(pcc_generate_modulecheckbox_machine($MAC));
		return "
		<div class=\"form-group\">
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
		</div>
		";
	}
	
	function pcc_view_machinedelete($MAC)
	{
		return "
		<div class=\"form-group\">
			<form action=\"handler.php\" method=\"post\"><br>
				" . get_string("realy") . " $MAC?<br>
				<input type=\"text\" name=\"mac_address\" value=\"$MAC\" readonly hidden>
				<input type=\"submit\" name=\"delete_machine\" value=\"OK\">
			</form>
		</div>
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
				
				" . pcc_disconnect_user($_SERVER['PHP_AUTH_USER']) . "
				<meta charset=\"utf-8\">
			    <meta http-equiv\"X-UA-Compatible\" content=\"IE=edge\">
			    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
			    <meta name=\"description\" content=\"\">
			    <meta name=\"author\" content=\"\">

			    <title>SB Admin - Bootstrap Admin Template</title>

			    <!-- Bootstrap Core CSS -->
			    <link href=\"css/bootstrap.min.css\" rel=\"stylesheet\">

			    <!-- Custom CSS -->
			    <link href=\"css/sb-admin.css\" rel=\"stylesheet\">

			    <!-- Morris Charts CSS -->
			    <link href=\"css/plugins/morris.css\" rel=\"stylesheet\">

			    <!-- Custom Fonts -->
			    <link href=\"font-awesome/css/font-awesome.min.css\" rel=\"stylesheet\" type=\"text/css\">

			    <link rel=\"stylesheet\" type=\"text/css\" href=\"/pcc/css/pcc.css\">
			    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
			    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
			    <!--[if lt IE 9]>
			        <script src=\"https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js\"></script>
			        <script src=\"https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js\"></script>
    			<![endif]-->

    			<script src=\"js/jquery.js\"></script>

			    <!-- Bootstrap Core JavaScript -->
			    <script src=\"js/bootstrap.min.js\"></script>

			    <!-- Morris Charts JavaScript -->
			    <script src=\"js/plugins/morris/raphael.min.js\"></script>
			    <script src=\"js/plugins/morris/morris.min.js\"></script>
			    <script src=\"js/plugins/morris/morris-data.js\"></script>
			    <script>
					$(document).ready(function(){
					    $('[data-toggle=\"tooltip\"]').tooltip();   
					});
				</script>
				
			</head>
			<body>
				<div id=\"wrapper\">
					<div id=\"page-wrapper\" style=\"min-height:94vh\">

	            		<div class=\"container-fluid\">
							$content
						</div>
					</div>
				</div>
				
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

	function pcc_view_dashboard()
	{
		return "
			<div class=\"row\">
                <div class=\"col-lg-12\">
                    <h1 class=\"page-header\">
                        Dashboard
                    </h1>
                    <ol class=\"breadcrumb\">
                        <li class=\"active\">
                            <i class=\"fa fa-dashboard\"></i> Dashboard
                        </li>
                    </ol>
                </div>
            </div>

            <div class=\"row\">
                <div class=\"col-lg-3 col-md-6\">
                    <div class=\"panel panel-primary\">
                        <div class=\"panel-heading\">
                            <div class=\"row\">
                                <div class=\"col-xs-3\">
                                    <i class=\"fa fa-dashboard fa-5x\"></i>
                                </div>
                                <div class=\"col-xs-9 text-right\">
                                    <div>Cockpit</div>
                                </div>
                            </div>
                        </div>
                        <a href=\"https://9.0.0.1:9090\">
                            <div class=\"panel-footer\">
                                <span class=\"pull-left\">" . get_string("gothere") . "</span>
                                <span class=\"pull-right\"><i class=\"fa fa-arrow-circle-right\"></i></span>
                                <div class=\"clearfix\"></div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class=\"col-lg-3 col-md-6\">
                    <div class=\"panel panel-green\">
                        <div class=\"panel-heading\">
                            <div class=\"row\">
                                <div class=\"col-xs-3\">
                                    <i class=\"fa fa-desktop fa-5x\"></i>
                                </div>
                                <div class=\"col-xs-9 text-right\">
                                    <div>" . get_string("machines") . "</div>
                                </div>
                            </div>
                        </div>
                        <a href=\"/pcc/?view=machines\">
                            <div class=\"panel-footer\">
                                <span class=\"pull-left\">" . get_string("gothere") . "</span>
                                <span class=\"pull-right\"><i class=\"fa fa-arrow-circle-right\"></i></span>
                                <div class=\"clearfix\"></div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class=\"col-lg-3 col-md-6\">
                    <div class=\"panel panel-yellow\">
                        <div class=\"panel-heading\">
                            <div class=\"row\">
                                <div class=\"col-xs-3\">
                                    <i class=\"fa fa-user fa-5x\"></i>
                                </div>
                                <div class=\"col-xs-9 text-right\">
                                    <div>" . get_string("users") . "</div>
                                </div>
                            </div>
                        </div>
                        <a href=\"/pcc/?view=users\">
                            <div class=\"panel-footer\">
                                <span class=\"pull-left\">" . get_string("gothere") . "</span>
                                <span class=\"pull-right\"><i class=\"fa fa-arrow-circle-right\"></i></span>
                                <div class=\"clearfix\"></div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class=\"col-lg-3 col-md-6\">
                    <div class=\"panel panel-red\">
                        <div class=\"panel-heading\">
                            <div class=\"row\">
                                <div class=\"col-xs-3\">
                                    <i class=\"fa fa-file fa-5x\"></i>
                                </div>
                                <div class=\"col-xs-9 text-right\">
                                    <div>Logs</div>
                                </div>
                            </div>
                        </div>
                        <a href=\"/pcc/?view=logs\">
                            <div class=\"panel-footer\">
                                <span class=\"pull-left\">" . get_string("gothere") . "</span>
                                <span class=\"pull-right\"><i class=\"fa fa-arrow-circle-right\"></i></span>
                                <div class=\"clearfix\"></div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            <div class=\"row\">
                <div class=\"col-lg-6\">
                    <div class=\"panel panel-default\">
                        <div class=\"panel-heading\">
                            <h3 class=\"panel-title\"><i class=\"fa fa-bar-chart-o fa-fw\"></i> Some Activity chart here</h3>
                        </div>
                        <div class=\"panel-body\">
                            <div id=\"morris-area-chart\"></div>
                            <div class=\"text-right\">
                                <a href=\"/pcc/?view=logs\">" . get_string("gothere") . "<i class=\"fa fa-arrow-circle-right\"></i></a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class=\"col-lg-6\">
                    <div class=\"panel panel-default\">
                        <div class=\"panel-heading\">
                            <h3 class=\"panel-title\"><i class=\"fa fa-long-arrow-right fa-fw\"></i> Even more log chart</h3>
                        </div>
                        <div class=\"panel-body\">
                            <div id=\"morris-donut-chart\"></div>
                            <div class=\"text-right\">
                                <a href=\"/pcc/?view=logs\">" . get_string("gothere") . "<i class=\"fa fa-arrow-circle-right\"></i></a>
                            </div>
                        </div>
                    </div>
                </div>
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
			return pcc_view_page(pcc_view_navbar("dashboard") . pcc_view_dashboard());
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
			return pcc_view_page(pcc_view_navbar("dashboard") . pcc_view_dashboard());
		}
		
	}
	
?>
