<?php

//-----first reset all steps as pending-----------
for ($i = 1; $i <= $total_steps; $i++) {
    $css = "nav_step_$i";
    $vars[$css] = 'pending';

    //reset session steps
    if (isset($_SESSION["step$last"])) {
        $_SESSION["step$last"] = '';
    }
}

//-----set all previous steps as completed--------
for ($i = 1; $i < $step; $i++) {
    //set previous steps css as 'completed'
    $laststep = $step - $i;
    $css = "nav_step_$laststep";
    $vars[$css] = 'completed';
}

//-----set current step as active------------------
$css = "nav_step_$step";
$vars[$css] = 'active';

//-----reset all previous sessions--------------------------
for ($i = 1; $i < $step; $i++) {
    //set previous steps css as 'completed'
    $last = $step - $i;
    $_SESSION["step$last"] = 'passed';
}
