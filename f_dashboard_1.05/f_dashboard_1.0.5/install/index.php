<?php

//error_reporting(E_ALL);
error_reporting(0);
session_start();

/** INCLUDES */
include_once ('libs/tbs_class.php');
include_once ('libs/functions.php');

/** VARIABLES */
$version = '1.05';
$template = 'template.html';
$last = '';
$url = $actual_link = "http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";

/** BASICS */
$debug = 0;
$vars = array();
$next = true;
$total_steps = 6; //edit me
$step = '';

/** RESULTS LABELS */
$passed = '<label class="label label-success pull-right">passed</label>';
$failed = '<label class="label label-danger pull-right">failed</label>';
$warning = '<label class="label label-warning pull-right">warning</label>';

/** GET STEPS */
if ($next) {
    if (isset($_GET['step'])) {
        $step = $_GET['step'];
    }
    if (isset($_POST['next_step'])) {
        $step = $_POST['next_step'];
    }

    if (!is_numeric($step)) {
        $step = 1;
    }
    //name the file
    $step_file = "step$step.php";

    //save is vars for debugging
    $vars['step'] = $step;
}

/** VALIDATE STEP FILE */
if ($next) {
    if (!is_file("steps/$step_file")) {

        //load step 1
        include_once ('steps/step1.php');

        //show error
        $vars['wi_notice_error'] = 1;
        $vars['notice'] = 'The request step is not valid. Please stat again';

        //halt
        $next = false;
    }
}

/** VALIDATE PREVIOUS STEPS PASSED */
if ($next) {
    if ($step != 1) {
        for ($i = 1; $i < $step; $i++) {
            //check if previous steps passed (look at sessions)
            $previous = $step - $i;
            if ($_SESSION["step$previous"] != 'passed') {
                $next = false;
            }
        }

        //chec results
        if ($next) {
            //all is ok, load the step
            include_once ("steps/step$step.php");
        } else {
            //reset step
            $step = 1;

            //load step 1
            include_once ('steps/step1.php');

            //show error
            $vars['wi_notice_error'] = 1;
            $vars['notice'] = 'Some installatin steps have not been completed. Please start again';
        }
    } else {
        //load step 1
        include_once ('steps/step1.php');
    }

}

$TBS = new clsTinyButStrong;
$TBS->NoErr = true;
$TBS->LoadTemplate($template);
$TBS->MergeField('vars', $vars);
$TBS->Render = TBS_OUTPUT;
$TBS->Show();

/** DEBUGGING */
if ($debug == 1) {
    echo "<pre>";
    print_r($vars);
    echo "</pre>";

    echo "<pre>";
    print_r($_SESSION);
    echo "</pre>";
}

?>
