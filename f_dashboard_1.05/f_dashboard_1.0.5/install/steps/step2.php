<?php

//show step sections
$vars['wi_show_step'] = 2;

//include navigation css styler
include_once ('common.php');

//success control
$results2 = true;

//submit button or not
$vars['form_button'] = 1;

//flow control
$next = true;

//------check PHP Vervsion----------------------------------
if ($next) {
    if (version_compare(PHP_VERSION, '5.3.0') >= 0) {
        //passed
        $vars['check_php_version'] = $passed;
    } else {
        //failed
        $vars['check_php_version'] = $failed;
        //this step has failed
        $results2 = false;
    }
}

//------check curl------------------------------------------
if ($next) {
    if (function_exists('curl_version')) {
        //passed
        $vars['check_php_curl'] = $passed;
    } else {
        //php failed
        $vars['check_php_curl'] = $failed;
        //this step has failed
        $results2 = false;
    }

}

//------check GD-------------------------------------------
if ($next) {
    if (extension_loaded('gd') && function_exists('gd_info')) {
        //passed
        $vars['check_php_gd'] = $passed;
    } else {
        //php failed
        $vars['check_php_gd'] = $failed;
        //this step has failed
        $results2 = false;
    }
}

//------check MYSQL-------------------------------------------
if ($next) {
    if (function_exists('mysql_connect') || function_exists('mysqli_connect')) {
        //passed
        $vars['check_php_mysql'] = $passed;
    } else {
        //php failed
        $vars['check_php_mysql'] = $failed;
        //this step has failed
        $results2 = false;
    }

}

/** FINAL RESULTS */
if ($results2) {
    $_SESSION["step2"] = 'passed';
} else {
    $_SESSION["step2"] = 'failed';
    $vars['form_button'] = 0;
}
