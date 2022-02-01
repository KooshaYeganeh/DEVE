#!/usr/bin/perl

use boolean;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init(
	{
		level => $ERROR,
		file => ">> error_log",
	}
);	

sub iptables_rules_check{

	@iptables = qx/sudo iptables -nvL --line-numbers/;
	print("iptables New Rules are:\n@iptables");

	@drop = grep(/DROP/ , $_);
	@log = grep(/LOG/,$_);
	if (@drop){
		print("DROP Rules are : @drop\n");
	}elsif(@log){
		print("LOG Rules are:@log\n");
	}
	else{
		print("No rules Set For Drop and LOG\n");
	}

}



sub ssh{

	@ssh_arr = qx/sudo iptables -nvL --line-numbers/;
	@ssh_service = qx/sudo systemctl list-units --type service/;
	@sshd = grep(/sshd/,@ssh_service);
	@port_22 = grep(/22/,@ssh_arr);
	if (@sshd){
		if (@port_22){
				print("Rules For ssh Service is [OK]\n");
			}else{
				print("No Rules Set For ssh Service [ERROR]\n");
				ERROR("You Are Not Set Rules For SSH Service");
			}
	}else{
		print("sshd Service is Not Loaded\n");
	}
}




sub webserver{

	@webserver_arr = qx/sudo iptables -nvL --line-numbers/;
	@webserver_service = qx/sudo systemctl list-units --type service/;
	@webserver = grep(/httpd/,@webserver_service);
	@port_80 = grep(/80/,@webserver_arr);
	@port_443 = grep(/443/,@webserver_arr);
	if (@webserver){
		if (@port_80 or @port_443){
			print("Rules For webserver is [OK}\n");
		}else{
			print("No Rule Set for webserver in Firewall");
			ERROR("You Are Not Set Rules For WebServer (Apache pr Ngnix)");

		}
	}
	else{
		print("WebServer is Not Loaded\n");
	}
}




sub mariadb{

	@maria_arr = qx/sudo iptables -nvL --line-numbers/;
	@maria_service = qx/sudo systemctl list-units --type service/;
	@mariadb = grep(/mariadb/,@maria_service);
	@port_3306 = grep(/3306/,@maria_arr);
	@port_3360 = grep(/3360/,@maria_arr);
	if (@mariadb){
		if (@port_3360 or @port_3306){
			print("Rules For Database Server is [OK]\n");
		}else{
			print("No Rule Set For mariadb\n");
			ERROR("Yor Are Not Set Rule for maraidb server
			       connections");
	       }

	}else{
		print("Mariadb Service is Not Loaded\n");
	}
}





sub menu{

	print("1.Save New Rules\n");
	print("2.check Firewall Rules\n");
	print("3.Exit\n");
	$res = <STDIN>;
	if ($res == 1){
		
		iptables_rules_check();

	}elsif($res == 2){
		mariadb();
		ssh();
		webserver();
	}
	elsif($res == 3){
		exit 1;
	}else{
		print("Please Enter Valid Number\n");
		menu();
	}


}


menu();
