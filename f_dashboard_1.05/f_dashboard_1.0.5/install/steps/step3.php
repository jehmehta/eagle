<?php

//show step sections.
$vars['wi_show_step'] = 3;

//include navigation css styler
include_once ('common.php');

//success control
$results3 = true;

//submit button or not
$vars['form_button'] = 1;

//flow control
$next = true;

//------check directories are writeable-------------------------------
if ($next) {

    $directories = array(
        'database' => '../application/config/database.php',
        'updates' => '../updates',
        'files' => '../files',
        'avatars' => '../files/avatars',
        'backups' => '../files/backups',
        'captcha' => '../files/captcha',
        'projects' => '../files/projects',
        'temp' => '../files/temp',
        'tickets' => '../files/tickets',
        'logs' => '../application/logs',
        'cache' => '../application/cache');

    //loop and check each folder
    foreach ($directories as $key => $value) {

        if (is_writeable($value)) {
            //passed
            $vars["check_folder_$key"] = $passed;
        } else {
            //failed
            $vars["check_folder_$key"] = $failed;
            //this step has failed
            $results3 = false;

        }
    }
}

/** FINAL RESULTS */
if ($results3) {
    $_SESSION["step3"] = 'passed';
} else {
    $_SESSION["step3"] = 'failed';
    $vars['form_button'] = 0;
}
