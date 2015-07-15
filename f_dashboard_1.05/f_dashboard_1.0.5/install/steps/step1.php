<?php

//only for step 1
session_unset();

//show step sections
$vars['wi_show_step'] = 1;

//include navigation css styler
include_once ('common.php');

//this step has passed
$vars['form_button'] = 1;

//this step has passed
$_SESSION["step1"] = 'passed';
