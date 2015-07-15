<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * class for perfoming all timers related functions
 *
 * @author   Nextloop.net
 * @access   public
 * @see      http://www.nextloop.net
 */
class Timers extends MY_Controller
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
        $this->data['template_file'] = PATHS_ADMIN_THEME . 'timers.html';

        //css settings
        if (is_numeric($this->uri->segment(4))) {
            $this->data['vars']['css_menu_heading_mytimers'] = 'heading-menu-active'; //menu
            $this->data['vars']['css_menu_mytimers'] = 'open'; //menu
            //set page title
            $this->data['vars']['main_title'] = 'My Project Timers';
            //for search
            $this->data['vars']['timers_view_type'] = $this->uri->segment(4);

        } else {
            $this->data['vars']['css_menu_topnav_timers'] = 'nav_alternative_controls_active'; //menu
            //set page title
            $this->data['vars']['main_title'] = 'All Project Timers';
            //for search
            $this->data['vars']['timers_view_type'] = 'all';
            //visble members list
            $this->data['visible']['all_members'] = 1;
        }

        //default page title
        $this->data['vars']['main_title_icon'] = '<i class="icon-time"></i>';
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
        $this->__commonAdmin_LoggedInCheck();

        //create pulldown lists
        $this->__pulldownLists();

        //get the action from url
        $action = $this->uri->segment(3);

        //route the rrequest
        switch ($action) {

            case 'view':
                $this->__timersView();
                break;

            case 'edit-timer':
                $this->__editTimer();
                break;

            case 'search-timers':
                $this->__cachedFormSearch();
                break;

            default:
                $this->__timersView();
                break;
        }

        //load view
        $this->__flmView('admin/main');

    }

    /**
     * load timers
     */
    function __timersView($view = 'all')
    {

        /* --------------URI SEGMENTS---------------
        * [example]
        * /admin/timers/view/all/54/asc/sortby_id/2
        * (2)->controller
        * (3)->router
        * (4)->view-type
        * (5)->search id
        * (6)->sort_order
        * (7)->sort_by_column
        * (8)->offset
        ** -----------------------------------------*/

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //uri segments
        $view_type = $this->uri->segment(4);
        $search_id = (is_numeric($this->uri->segment(5))) ? $this->uri->segment(5) : 0;
        $sort_by = ($this->uri->segment(6) == 'desc') ? 'desc' : 'asc';
        $sort_by_column = ($this->uri->segment(7) == '') ? 'sortby_time' : $this->uri->segment(7);
        $offset = (is_numeric($this->uri->segment(8))) ? $this->uri->segment(8) : 0;

        //load the original posted search into $_get array
        $this->input->load_query($search_id);

        //get results and save for tbs block merging
        $this->data['reg_blocks'][] = 'timers';
        $this->data['blocks']['timers'] = $this->timer_model->viewTimers($offset, 'search', $view_type);
        $this->data['debug'][] = $this->timer_model->debug_data;

        //count results rows - used by pagination class
        $rows_count = $this->timer_model->viewTimers($offset, 'count', $view_type);
        $this->data['debug'][] = $this->timer_model->debug_data;
        $this->data['vars']['count_timers'] = $rows_count;

        //pagination
        $config = pagination_default_config(); //
        $config['base_url'] = site_url("admin/timers/view/$view_type/$search_id/$sort_by/$sort_by_column");
        $config['total_rows'] = $rows_count;
        $config['per_page'] = $this->data['settings_general']['results_limit'];
        $config['uri_segment'] = 8; //the offset var
        $this->pagination->initialize($config);
        $this->data['vars']['pagination'] = $this->pagination->create_links();

        //sorting links for menus on the top of the table
        $link_sort_by = ($sort_by == 'asc') ? 'desc' : 'asc'; //flip the sort_by
        $link_sort_by_column = array(
            'sortby_time',
            'sortby_project',
            'sortby_assigned_to');
        foreach ($link_sort_by_column as $column) {
            $this->data['vars'][$column] = site_url("admin/timers/view/$view_type/$search_id/$link_sort_by/$column/$offset");
        }

        //visibility
        if ($rows_count > 0) {
            //show side menu
            $this->data['visible']['wi_timers_table'] = 1;
        } else {
            //show mothing found
            $this->notifications('wi_notification', $this->data['lang']['lang_no_results_found']);
        }

        //set hidden value of current url (used for redirect on timer edits)
        $this->data['vars']['current_url'] = current_url();

        //final data preps
        $this->data['blocks']['timers'] = $this->__prepTimers($this->data['blocks']['timers']);
    }

    /**
     * Additional process of timers array
     *
     * 
     * @param	array [thedata]
     * @return	array
     */
    function __prepTimers($thedata)
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        /* -----------------------PREPARE TASKS DATA ----------------------------------------/
        *  Loop through all the tasks in this array and for each task:
        *  -----------------------------------------------------------
        *  (1) add visibility for the [control] buttons
        *
        *------------------------------------------------------------------------------------*/

        for ($i = 0; $i < count($thedata); $i++) {
            if ($thedata[$i]['timer_status'] == 'running') {
                $thedata[$i]['css_start_timer_btn'] = 'invisible';
                $thedata[$i]['css_stop_timer_btn'] = 'visible';
            } else {
                $thedata[$i]['css_start_timer_btn'] = 'visible';
                $thedata[$i]['css_stop_timer_btn'] = 'invisible';
            }

        }

        //return the data
        return $thedata;

    }

    /**
     * edit project timer
     *
     */
    function __editTimer()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //prevent direct access
        if (!isset($_POST['submit'])) {
            redirect('/admin/timers/view/all');
        }

        //flow control
        $next = true;

        //validate time
        if ($next) {
            if (!$this->__flmFormValidation('edit_timer')) {
                //show error
                $this->notices('error', $this->form_processor->error_message, 'noty');
                //halt
                $next = false;
            }
        }

        //PERMISSION CHECK
        //is this my timer
        if ($next) {
            if ($this->data['vars']['my_group'] != 1) {
                $owner_id = $this->timer_model->timerOwner($this->input->post('edit_timer_id'));
                $this->data['debug'][] = $this->timer_model->debug_data;

                if ($owner_id != $this->data['vars']['my_id']) {
                    //show error
                    $this->notices('error', $this->data['lang']['lang_permission_denied'], 'noty');
                    //halt
                    $next = false;
                }
            }
        }

        //update time
        if ($next) {

            //change time(hours) to seconds
            $new_time = $this->input->post('new_time') * 3600;

            //update
            $result = $this->timer_model->updateTimerTime($this->input->post('edit_timer_id'), $new_time);
            $this->data['debug'][] = $this->timer_model->debug_data;

            if ($result) {
                //sucess
                $this->session->set_flashdata('notice-success', $this->data['lang']['lang_request_has_been_completed']);
                //redirect
                redirect($this->input->post('ref_url'));
            } else {
                //show error
                $this->notices('error', $this->data['lang']['lang_request_could_not_be_completed'], 'noty');
            }
        }
    }

    /**
     * Generates various pulldown (<option>...</option>) lists for ready use in HTML
     * Output is set to e.g. $this->data['lists']['milestones']
     *
     */
    function __pulldownLists()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //[all_projects]
        $data = $this->projects_model->allProjects('projects_title', 'ASC');
        $this->data['debug'][] = $this->projects_model->debug_data;
        $this->data['lists']['all_projects'] = create_pulldown_list($data, 'projects', 'id');

        //[all_team_members]
        $data = $this->teamprofile_model->allTeamMembers('team_profile_full_name', 'ASC');
        $this->data['debug'][] = $this->teamprofile_model->debug_data;
        $this->data['lists']['all_team_members'] = create_pulldown_list($data, 'team_members', 'id');

    }

    /**
     * takes all posted (search form) data and saves it to an array
     * array is then saved in database
     * the unique id of the database record is now used in redirect for all page results
     *
     */
    function __cachedFormSearch()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //create array containg all post data in format:: array('name'=>$this->input->post('name));
        $search_array = array();
        foreach ($_POST as $key => $value) {
            $search_array[$key] = $this->input->post($key);
        }

        //save serch query in database & get id of database record
        $search_id = $this->input->save_query($search_array);

        //change url to "list" and redirect with cached search id.
        redirect("/admin/timers/view/" . $this->uri->segment(4) . "/$search_id");

    }

    /**
     * validates forms for various methods in this class
     * @param	string $form identify the form to validate
     */
    function __flmFormValidation($form = '')
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //form validation
        if ($form == 'edit_timer') {

            //check required fields
            $fields = array('new_time' => $this->data['lang']['lang_time']);
            if (!$this->form_processor->validateFields($fields, 'numeric')) {
                return false;
            }

            //everything ok
            return true;
        }

        //nothing specified - return false & error message
        $this->form_processor->error_message = $this->data['lang']['lang_form_validation_error'];
        return false;
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

/* End of file timers.php */
/* Location: ./application/controllers/admin/timers.php */
