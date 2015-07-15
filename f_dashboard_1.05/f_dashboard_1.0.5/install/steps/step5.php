<?php

//show step sections
$vars['wi_show_step'] = 5;

//include navigation css styler
include ('common.php');

//success control
$results5 = true;

//submit button or not
$vars['form_button'] = 1;

//flow control
$next = true;

if ($_POST['account_submit'] == 'yes') {

    //------validate form and create vars-------------------------------
    if ($next) {

        //create vars and check them
        foreach ($_POST as $key => $value) {
            $$key = $value;
        }

        //check fields
        if ($admin_name == '' || $admin_email == '' || $admin_password == '') {
            $vars['wi_notice_error'] = 1;
            $vars['notice'] = 'Fill in required fields';
            $next = false;
        }
    }

    //------update database-------------------------------
    if ($next) {

        //sme vars
        $team_profile_uniqueid = uniqid();
        $team_profile_full_name = $admin_name;
        $team_profile_email = $admin_email;
        $team_profile_password = md5($admin_password);

        //connect to database again
        $dbase = @mysql_connect($_SESSION['database_server'], $_SESSION['database_username'], $_SESSION['database_password'], true);
        @mysql_select_db($_SESSION['database_name']);
        
        
        //Update Database
        @mysql_query("UPDATE team_profile SET
                                     team_profile_uniqueid	='$team_profile_uniqueid',
									 team_profile_full_name	='$team_profile_full_name',
									 team_profile_email	='$team_profile_email',
                                     team_profile_password = '$team_profile_password'
                                     WHERE
                                   	 team_profile_id = 1");

        //did it pass
        /** FINAL RESULTS */
        if (!@mysql_error()) {

            //passed
            $_SESSION["step5"] = 'passed';

            //show next step
            $vars['wi_show_step'] = 6;
            $step = 6;

            //success
            $vars['wi_notice_success'] = 1;
            $vars['notice'] = 'Installation has completed successfully';

            //hide button
            $vars['form_button'] = 9;

            //url
            $vars['url'] = str_replace('/install/index.php', '', $url);

            //-------update system version------------------------------
            @mysql_query("DELETE FROM version");

            @mysql_query("INSERT INTO version (
                                     id,
                                     version,
                                     date_installed,
                                     install_type
                                     )VALUES(
                                     'default',
                                     '$version',
                                     NOW(),
                                     'new')");

            //-------register with server-------------------------------
            $ch = curl_init();
            $postdata = "product=freelance-dashboard&url=" . $vars['url'] . "&name=$team_profile_full_name&email=$team_profile_email&ip=" . $_SERVER['REMOTE_ADDR'];
            curl_setopt($ch, CURLOPT_URL, 'http://www.nextloop.net/licensing/register.php');
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
            $result = curl_exec($ch);
            curl_close($ch);

            //reload common for change in nav menu
            include ('common.php');

        } else {

            //database error
            $vars['wi_notice_error'] = 1;
            $vars['notice'] = 'Database error. Installation cannot complete.<br/><br/>' . @mysql_error();

            $_SESSION["step5"] = 'failed';
        }

    }

}
