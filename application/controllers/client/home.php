<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * class for perfoming all Home related functions
 *
 * @author   Nextloop.net
 * @access   public
 * @see      http://www.nextloop.net
 */
class Home extends MY_Controller
{

    /**
     * constructor method
     */
    public function __construct()
    {

        parent::__construct();

        //profiling::
        $this->data['controller_profiling'][] = __function__;

        //template file
        $this->data['template_file'] = PATHS_CLIENT_THEME . '/home.html';

        //css settings
        $this->data['vars']['css_menu_dashboard'] = 'open'; //menu

    }

    /**
     * This is our re-routing function and is the inital function called
     *
     * 
     */
    function index()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //login check
        $this->__commonClient_LoggedInCheck();

        //uri - action segment
        $action = $this->uri->segment(3);

        //default page title
        $this->data['vars']['main_title'] = $this->data['lang']['lang_dashboard']; //lang

        //re-route to correct method
        switch ($action) {

            default:
                $this->__loadHome();
        }

        //load view
        $this->__flmView('client/main');

    }

    /**
     * show the home page 
     *
     */
    function __loadHome()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //load members projects
        $this->__clientsProjects();

        //due invoices
        $this->__dueInvoices();

        //display timeline
        $this->__getEventsTimeline();

    }

    /**
     * eload 2 of my projects
     */
    function __clientsProjects()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        $projects = $this->projects_model->allProjects('project_deadline', 'DESC', $this->data['vars']['my_client_id'], 'all');
        $this->data['debug'][] = $this->projects_model->debug_data;

        //first project
        $this->data['reg_fields'][] = 'project_one';
        $this->data['fields']['project_one'] = (isset($projects[0]))? $projects[0] : array();

        //second project
        $this->data['reg_fields'][] = 'project_two';
        $this->data['fields']['project_two'] = (isset($projects[1]))? $projects[1] : array();
        
        //visibility of first project
        if (is_array($this->data['fields']['project_one']) && !empty($this->data['fields']['project_one'])) {
            $this->data['visible']['wi_project_one'] = 1;
        } else {
            $this->data['visible']['wi_project_none'] = 1;
        }

        //visibility of second project
        if (is_array($this->data['fields']['project_two']) && !empty($this->data['fields']['project_two'])) {
            $this->data['visible']['wi_project_two'] = 1;
        }

    }

    /**
     * eload 2 of my projects
     */
    function __dueInvoices()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //sum up all 'due' invoices
        $due_invoices = $this->invoices_model->dueInvoices($this->data['vars']['my_client_id'], 'client', 'due');
        $this->data['debug'][] = $this->invoices_model->debug_data;
        $this->data['vars']['due_invoices'] = '';
        for ($i = 0; $i < count($due_invoices); $i++) {
            $this->data['vars']['due_invoices'] += $due_invoices[$i]['amount_due'];
        }

        //sum up all 'overdue' invoices
        $overdue_invoices = $this->invoices_model->dueInvoices($this->data['vars']['my_client_id'], 'client', 'overdue');
        $this->data['debug'][] = $this->invoices_model->debug_data;
        $this->data['vars']['overdue_invoices'] = '';
        for ($i = 0; $i < count($overdue_invoices); $i++) {
            $this->data['vars']['overdue_invoices'] += $overdue_invoices[$i]['amount_due'];
        }

    }

    /**
     * get ann events from clients projects
     */
    function __getEventsTimeline()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //flow control
        $next = true;

        //try to create 'comma separated' list of clients projects
        if ($next) {

            //check if client has projects
            if ($this->data['vars']['my_clients_project_list']) {

                //get project events (timeline)
                $this->data['reg_blocks'][] = 'timeline';
                $this->data['blocks']['timeline'] = $this->project_events_model->getEvents($this->data['vars']['my_clients_project_list'], 'project-list');
                $this->data['debug'][] = $this->project_events_model->debug_data;

                //further process events data
                $this->data['blocks']['timeline'] = $this->__prepEvents($this->data['blocks']['timeline']);

                //show timeline
                $this->data['visible']['show_timeline'] = 1;

            } else {

                //show no events found
                $this->data['visible']['show_no_timeline'] = 1;

            }

        }

    }

    /**
     * additional data preparations project events (timeline) data
     *
     */
    function __prepEvents($thedata = '')
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //check if data is not empty
        if (count($thedata) == 0 || !is_array($thedata)) {
            return $thedata;
        }

        /* -----------------------PREPARE FILES DATA ----------------------------------------/
        *  Loop through all the files in this array and for each file:
        *  -----------------------------------------------------------
        *  (1) process user names ('event by' data)
        *  (2) add back the language for the action carried out
        *
        *
        *------------------------------------------------------------------------------------*/
        for ($i = 0; $i < count($thedata); $i++) {

            //--team member---------------------
            if ($thedata[$i]['project_events_user_type'] == 'team') {
                $thedata[$i]['user_name'] = $thedata[$i]['team_profile_full_name'];
            }

            //--client user---------------------
            if ($thedata[$i]['project_events_user_type'] == 'client') {
                $thedata[$i]['user_name'] = $thedata[$i]['client_users_full_name'];
            }

            //add back langauge
            $word = $thedata[$i]['project_events_action'];
            $thedata[$i]['project_events_action_lang'] = $this->data['lang'][$word];

            //add #hash to numbers (e.g invoice number) and create a new key called 'project_events_item'
            if (is_numeric($thedata[$i]['project_events_details'])) {
                $thedata[$i]['project_events_item'] = '#' . $thedata[$i]['project_events_details'];
            } else {
                $thedata[$i]['project_events_item'] = $thedata[$i]['project_events_details'];
            }

        }

        //retun the processed data
        return $thedata;
    }

    /**
     * loads the view
     *
     * @param string $view the view to load
     */
    function __flmView($view = '')
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //template::
        $this->data['template_file'] = help_verify_template($this->data['template_file']);

        //complete the view
        $this->__commonAll_View($view);
    }

}

/* End of file home.php */
/* Location: ./application/controllers/client/home.php */
