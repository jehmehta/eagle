<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * class for perfoming all milestones related data abstraction
 *
 * @author   Nextloop.net
 * @access   public
 * @see      http://www.nextloop.net
 */
class Projects_model extends Super_Model
{

    var $debug_methods_trail;
    var $number_of_rows;

    // -- __construct ----------------------------------------------------------------------------------------------

    function __construct()
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        // Call the Model constructor
        parent::__construct();
    }

    // -- allProjects ----------------------------------------------------------------------------------------------
    /**
     * return array of all the rows of projects in table
     * accepts order_by and asc/desc values
     *
     * @param string $orderby sorting colum (optional) 
     * @param string $sort sorting order (optional) 
     * @param string $status 'in progress', 'completed', 'behind schedule' , 'all' (optional) 
     * @param numeric $clients_id: projects for specific client (optional) 
     * @return array
     */

    function allProjects($orderby = 'projects_title', $sort = 'ASC', $clients_id = '', $status = 'all')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //check if any specifi ordering was passed
        if (!$this->db->field_exists($orderby, 'projects')) {
            $orderby = 'projects_title';
        }

        //check if sorting type was passed
        $sort = ($sort == 'asc' || $sort == 'desc') ? $sort : 'ASC';

        //if project_id has been specified, show only for this project
        if (is_numeric($clients_id)) {
            $conditional_sql .= " AND projects_clients_id = $clients_id";
        }

        //has status been provided
        $status = str_replace('-', ' ', $status);
        if (in_array($status, array(
            'in progress',
            'completed',
            'behind schedule'))) {
            $conditional_sql .= " AND projects_status = $status";
        }

        //---------------URL QUERY - CONDITONAL SEARCH STATMENTS---------------
        //client id
        if (is_numeric($clients_id)) {
            $conditional_sql .= " AND projects_clients_id = $clients_id";
        }

        //clients dashboard limitation
        if (is_numeric($this->session->userdata('client_users_clients_id'))) {
            $conditional_sql .= " AND projects_clients_id = ".$this->session->userdata('client_users_clients_id');
        }
        
        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //----------monitor transaction start----------
        $this->db->trans_start();

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT *
                                          FROM projects 
                                          WHERE 1 = 1
                                          $conditional_sql
                                          ORDER BY $orderby $sort");

        $results = $query->result_array(); //multi row array

        //----------monitor transaction end----------
        $this->db->trans_complete();
        $transaction_result = $this->db->trans_status();
        if ($transaction_result === false) {

            //log this error
            $db_error = $this->db->_error_message();
            log_message('error', '[FILE: ' . __file__ . ']  [FUNCTION: ' . __function__ . ']  [LINE: ' . __line__ . "]  [MESSAGE: Database Error -  $db_error]");

            return false;
        }

        //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        return $results;

    }

    // -- searchProjects ----------------------------------------------------------------------------------------------
    /**
     * search projects table and return results as an array
     *
     * @param string $offset search pagination [optional - but required if paginated results]
     * @param string $type 'search', 'count', 'list'  [required] [search: only this option will provide pagination]
     * @param string $clients_id limit results to one clients projects  [optional] [overides any search form data for this value]
     * @param string $status limit projects status  [optional] [overides any search form data for this value]
     * @return mixed
     */

    function searchProjects($offset = 0, $type = 'search', $clients_id = '', $status = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';
        $limiting = '';

        //system page limit or set default 25
        $limit = (is_numeric($this->data['settings_general']['results_limit'])) ? $this->data['settings_general']['results_limit'] : 25;

        //---------------SEARCH FORM CONDITONAL STATMENTS------------------
        if ($this->input->get('clients_company_name')) {
            $client_id = $this->db->escape($this->input->get('clients_company_name'));
            $conditional_sql .= " AND projects.projects_clients_id = $client_id";
        }
        if ($this->input->get('projects_title')) {
            $projects_title = str_replace("'", "", $this->db->escape($this->input->get('projects_title')));
            $conditional_sql .= " AND projects.projects_title LIKE '%$projects_title%'";
        }
        if (is_numeric($this->input->get('projects_id'))) {
            $projects_id = $this->db->escape($this->input->get('projects_id'));
            $conditional_sql .= " AND projects.projects_id = $projects_id";
        }
        if ($this->input->get('projects_status') && $this->input->get('projects_status') != 'all') {
            $projects_status = $this->db->escape($this->input->get('projects_status'));
            $conditional_sql .= " AND projects.projects_status = $projects_status";
        }
        //---------------URL QUERY - CONDITONAL SEARCH STATMENTS---------------
        //client id
        if (is_numeric($clients_id)) {
            $conditional_sql .= " AND projects_clients_id = $clients_id";
        }

        //status
        if ($this->input->get('projects_status') == '') {
            $status = str_replace('-', ' ', $status);
            if (in_array($status, array(
                'in progress',
                'closed',
                'completed',
                'behind schedule'))) {
                $conditional_sql .= " AND projects_status = '$status'";
            }
        }

        //status
        if ($this->input->get('projects_status') == '') {
            if ($status == 'pending') {
                $conditional_sql .= " AND projects_status NOT IN('completed')";
            }
        }

        //---------------URL QUERY - ORDER BY STATMENTS-------------------------
        $sort_order = ($this->uri->segment(5) == 'desc') ? 'desc' : 'asc';
        $sort_columns = array(
            'sortby_projectid' => 'projects.projects_id',
            'sortby_duedate' => 'projects.project_deadline',
            'sortby_status' => 'projects.projects_status',
            'sortby_companyname' => 'clients.clients_company_name',
            'sortby_dueinvoices' => 'unpaid_invoices',
            'sortby_allinvoices' => 'all_invoices',
            'sortby_progress' => 'projects_progress');
        //validate if passed sort is valid
        $sort_by = (array_key_exists('' . $this->uri->segment(6), $sort_columns)) ? $sort_columns[$this->uri->segment(6)] : 'projects.projects_id';
        $sorting_sql = "ORDER BY $sort_by $sort_order";

        //---------------IF SEARCHING - LIMIT FOR PAGINATION----------------------
        if ($type == 'search') {
            $limiting = "LIMIT $limit OFFSET $offset";
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //----------monitor transaction start----------
        $this->db->trans_start();

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT projects.*,
                                          clients.*,
                                          projects.projects_progress_percentage AS projects_progress,
                                          (SELECT SUM(invoices.invoices_amount)
                                            FROM invoices
                                            WHERE invoices.invoices_project_id = projects.projects_id
                                            AND invoices.invoices_status NOT IN('paid'))
                                            AS unpaid_invoices,
                                          (SELECT SUM(invoices.invoices_amount)
                                            FROM invoices
                                            WHERE invoices.invoices_project_id = projects.projects_id)
                                            AS all_invoices,
                                          (SELECT SUM(timer.timer_seconds)
                                            FROM timer
                                            WHERE timer.timer_project_id = projects.projects_id)
                                            AS timer
                                          FROM projects
                                            LEFT OUTER JOIN clients
                                            ON clients.clients_id = projects.projects_clients_id
                                          WHERE 1 = 1
                                          $conditional_sql
                                          $sorting_sql
                                          $limiting");
        //results (search or rows)
        //rows are used by pagination class & results are used by tbs block merge
        if ($type == 'search') {
            $results = $query->result_array();
        } else {
            $results = $query->num_rows();
        }

        //----------monitor transaction end----------
        $this->db->trans_complete();
        $transaction_result = $this->db->trans_status();
        if ($transaction_result === false) {

            //log this error
            $db_error = $this->db->_error_message();
            log_message('error', '[FILE: ' . __file__ . ']  [FUNCTION: ' . __function__ . ']  [LINE: ' . __line__ . "]  [MESSAGE: Database Error -  $db_error]");

            return false;
        }

        //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        return $results;

    }

    // -- projectDetails ----------------------------------------------------------------------------------------------
    /**
     * loads the main details of a project
     *
     * @param string $id project id 
     * @return array
     */

    function projectDetails($id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //if no valie client id, return false
        if (!is_numeric($id)) {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [id=$group_id]", '');
            return false;
        }

        //escape params items
        $id = $this->db->escape($id);

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //----------monitor transaction start----------
        $this->db->trans_start();

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT projects.*, clients.*, team_profile.*,
                                          (SELECT COUNT(tasks_id) 
                                                  FROM tasks 
                                                  WHERE tasks_project_id = projects.projects_id)
                                                  AS count_tasks_all,
                                          (SELECT COUNT(milestones_id) 
                                                  FROM milestones 
                                                  WHERE milestones_project_id = projects.projects_id)
                                                  AS count_milestones_all,
                                         (SELECT COUNT(invoices_id) 
                                                  FROM invoices 
                                                  WHERE invoices_project_id = projects.projects_id)
                                                  AS count_invoices_all
                                          FROM projects
                                          LEFT OUTER JOIN clients
                                          ON  clients.clients_id = projects.projects_clients_id
                                          LEFT OUTER JOIN team_profile
                                          ON team_profile.team_profile_id = projects.projects_team_lead_id                                      
                                          WHERE projects_id = $id");

        $results = $query->row_array(); //single row array
        $count = $query->num_rows(); //count rows

        //----------monitor transaction end----------
        $this->db->trans_complete();
        $transaction_result = $this->db->trans_status();
        if ($transaction_result === false) {

            //log this error
            $db_error = $this->db->_error_message();
            log_message('error', '[FILE: ' . __file__ . ']  [FUNCTION: ' . __function__ . ']  [LINE: ' . __line__ . "]  [MESSAGE: Database Error -  $db_error]");

            return false;
        }

        //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        if ($count == 0) {
            return false;
        } else {
            return $results;
        }
    }

    // -- countProjects ----------------------------------------------------------------------------------------------
    /**
     * counts projects of various status and grouping
     *
     * @param numeric   [id] (optional)
     * @param   string    [count_by: reference for the provided ID, for conditional search] (optional)
     *                               - client
     *                               - all
     * @param   string    [status: project status] (optional)
     *                               - all
     *                               - all open
     *                               - in progress
     *                               - behind schedule
     *                               - completed
     * 
     * @return	numeric (rows count)
     */

    function countProjects($id = '', $count_by = 'all', $status = 'all')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //if no valid id, return false
        if (!is_numeric($id) && $id != '') {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [id=$id]", '');
            return false;
        }

        //conditional search for the ID param, using the $id_reference
        switch ($count_by) {

            case 'client':
                $conditional_sql = "AND projects_clients_id = $id";
                break;

        }

        //conditional search for the ID param, using the $id_reference
        switch ($status) {

            case 'in progress':
                $conditional_sql2 = "AND projects_status = 'in progress'";
                break;

            case 'completed':
                $conditional_sql2 = "AND projects_status = 'completed'";
                break;

            case 'behind schedule':
                $conditional_sql2 = "AND projects_status = 'behind schedule'";
                break;

            case 'all open':
                $conditional_sql2 = "AND projects_status NOT IN('completed')";
                break;
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //----------monitor transaction start----------
        $this->db->trans_start();

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT *
                                          FROM projects 
                                          WHERE 1 = 1
                                          $conditional_sql
                                          $conditional_sql2");

        $results = $query->num_rows(); //count rows

        //----------monitor transaction end----------
        $this->db->trans_complete();
        $transaction_result = $this->db->trans_status();
        if ($transaction_result === false) {

            //log this error
            $db_error = $this->db->_error_message();
            log_message('error', '[FILE: ' . __file__ . ']  [FUNCTION: ' . __function__ . ']  [LINE: ' . __line__ . "]  [MESSAGE: Database Error -  $db_error]");

            return false;
        }

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        if (is_numeric($results)) {
            return $results;
        } else {
            return 0;
        }
    }

    // -- allProjectsCounts ----------------------------------------------------------------------------------------------
    /**
     * count various projects based on status
     *
     * @param numeric $client_id optional; if provided, count will be limited to that clients 
     * @return array
     */

    function allProjectsCounts($client_id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //is this for a client
        if (is_numeric($client_id)) {
            $conditional_sql .= " AND projects_clients_id = '$client_id'";
        }
        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT (SELECT COUNT(projects_id)
                                                  FROM projects
                                                  WHERE projects_status = 'in progress'
                                                  $conditional_sql) AS in_progress,
                                          (SELECT COUNT(projects_id)
                                                  FROM projects
                                                  WHERE projects_status = 'completed'
                                                  $conditional_sql) AS completed,
                                          (SELECT COUNT(projects_id)
                                                  FROM projects
                                                  WHERE projects_status = 'behind schedule'
                                                  $conditional_sql) AS behind_schedule,
                                          (SELECT COUNT(projects_id)
                                                  FROM projects
                                                  WHERE projects_status NOT IN ('completed')
                                                  $conditional_sql) AS all_open,
                                          (SELECT COUNT(projects_id)
                                                  FROM projects
                                                  WHERE 1 = 1
                                                  $conditional_sql) AS all_projects
                                          FROM projects 
                                          WHERE 1 = 1
                                          LIMIT 1");

        //other results
        $results = $query->row_array(); //single row array

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //---return
        return $results;

    }

    // -- deleteProject ----------------------------------------------------------------------------------------------
    /**
     * delete a single project, based on project id (normally last step in deleting a project)
     *
     * @param numeric $id: quotation id 
     * @return bool
     */

    function deleteProject($id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //flow control
        $next = true;

        //validate id
        if (!is_numeric($id)) {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [id=$id]", '');
            return false;
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        if ($next) {
            $query = $this->db->query("DELETE FROM projects
                                          WHERE projects_id = $id");
        }
        $results = $this->db->affected_rows(); //affected rows

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //---return
        if (is_numeric($results)) {
            return true;
        } else {
            return false;
        }
    }

    // -- bulkDelete ----------------------------------------------------------------------------------------------
    /**
     * bulk delete based on list of project ID's
     * typically used when deleting project/s 
     * 
     * @param string $projects_list a mysql array/list formatted projects list [e.g. 1,2,3,4]
     * @return bool
     */

    function bulkDelete($projects_list = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //flow control
        $next = true;

        //sanity check - ensure we have a valid projects_list, with only numeric id's
        $lists = explode(',', $projects_list);
        for ($i = 0; $i < count($lists); $i++) {
            if (!is_numeric(trim($lists[$i]))) {
                //log error
                log_message('error', '[FILE: ' . __file__ . ']  [FUNCTION: ' . __function__ . ']  [LINE: ' . __line__ . "]  [MESSAGE: Bulk Deleting projects, for projects($clients_projects) failed. Invalid projects list]");
                //exit
                return false;
            }
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        if ($next) {
            $query = $this->db->query("DELETE FROM projects
                                          WHERE projects_id IN($projects_list)");
        }
        $results = $this->db->affected_rows(); //affected rows

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //---return
        if (is_numeric($results)) {
            return true;
        } else {
            return false;
        }
    }

    // -- addProject ----------------------------------------------------------------------------------------------
    /**
     * create a new project
     * 
     * @param numeric $id
     * @return numeric [new projects id]
     */

    function addProject($id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //escape all post item
        foreach ($_POST as $key => $value) {
            $$key = $this->db->escape($this->input->post($key));

            //remove single quotes from clients_optionalfield.*
            // these will have quotes added in sql below
            if (preg_match("%projects_optionalfield%", $key)) {
                $$key = str_replace("'", "", ($this->input->post($key)));
            }

        }

        //optional fields declare
        $projects_optionalfield1 = (isset($projects_optionalfield1)) ? $projects_optionalfield1 : '';
        $projects_optionalfield2 = (isset($projects_optionalfield2)) ? $projects_optionalfield2 : '';
        $projects_optionalfield3 = (isset($projects_optionalfield3)) ? $projects_optionalfield3 : '';
        $projects_optionalfield4 = (isset($projects_optionalfield4)) ? $projects_optionalfield4 : '';
        $projects_optionalfield5 = (isset($projects_optionalfield5)) ? $projects_optionalfield5 : '';

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("INSERT INTO projects (
                                          projects_clients_id,
                                          projects_title,
                                          project_deadline,
                                          projects_description,
                                          projects_optionalfield1,
                                          projects_optionalfield2,
                                          projects_optionalfield3,
                                          projects_optionalfield4,
                                          projects_optionalfield5,
                                          projects_date_created
                                          )VALUES(
                                          $projects_clients_id,
                                          $projects_title,
                                          $project_deadline,
                                          $projects_description,
                                          '$projects_optionalfield1',
                                          '$projects_optionalfield2',
                                          '$projects_optionalfield3',
                                          '$projects_optionalfield4',
                                          '$projects_optionalfield5',
                                          NOW())");

        $results = $this->db->insert_id();

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //---return
        if ($results > 0) {
            return $results;
        } else {
            return false;
        }

    }

    // -- editProject ----------------------------------------------------------------------------------------------
    /**
     * edit basic project details
     * @return bool
     */

    function editProject()
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //escape all post item
        foreach ($_POST as $key => $value) {
            $$key = $this->db->escape($this->input->post($key));
        }


        //optional fields
        $projects_optionalfield1 = $this->db->escape($this->input->post('projects_optionalfield1'));
        $projects_optionalfield2 = $this->db->escape($this->input->post('projects_optionalfield2'));
        $projects_optionalfield3 = $this->db->escape($this->input->post('projects_optionalfield3'));
        $projects_optionalfield4 = $this->db->escape($this->input->post('projects_optionalfield4'));
        $projects_optionalfield5 = $this->db->escape($this->input->post('projects_optionalfield5'));
        
        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("UPDATE projects
                                          SET 
                                          projects_title = $projects_title,
                                          project_deadline = $project_deadline,
                                          projects_description = $projects_description,
                                          projects_optionalfield1 = $projects_optionalfield1,
                                          projects_optionalfield2 = $projects_optionalfield2,
                                          projects_optionalfield3 = $projects_optionalfield3,
                                          projects_optionalfield4 = $projects_optionalfield4,
                                          projects_optionalfield5 = $projects_optionalfield5                                         
                                          WHERE projects_id = $projects_id");

        $results = $this->db->affected_rows(); //affected rows

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //---return
        if (is_numeric($results)) {
            return true;
        } else {
            return false;
        }
    }

    // -- updateProgress ----------------------------------------------------------------------------------------------
    /**
     * update project progress
     * @param numeric $project_id
     * @param numeric $progress
     * @return bool
     */

    function updateProgress($project_id = '', $progress = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //validate
        if (!is_numeric($project_id) || !is_numeric($progress)) {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [project id=$project_id] or [progress=$progress]", '');
            return false;
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("UPDATE projects
                                          SET 
                                          projects_progress_percentage = '$progress'
                                          WHERE projects_id = '$project_id'");
        $results = $this->db->affected_rows(); //affected rows

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end'); //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results); //----------sql & benchmarking end----------

        //---return
        if (is_numeric($results)) {
            return true;
        } else {
            return false;
        }
    }

    // -- updateProgress ----------------------------------------------------------------------------------------------
    /**
     * update project progress
     * @param numeric $project_id
     * @param numeric $status
     * @return bool
     */

    function updateStatus($project_id = '', $status = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //validate
        if (!is_numeric($project_id) || !in_array($status, array(
            'completed',
            'in progress',
            'behind schedule'))) {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [project id=$project_id] or [status=$status]", '');
            return false;
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start'); //_____SQL QUERY_______
        $query = $this->db->query("UPDATE projects
                                          SET 
                                          projects_status = '$status'
                                          WHERE projects_id = '$project_id'");
        $results = $this->db->affected_rows(); //affected rows

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end'); //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results); //----------sql & benchmarking end----------

        //---return
        if (is_numeric($results)) {
            return true;
        } else {
            return false;
        }
    }
}

/* End of file projects_model.php */
/* Location: ./application/models/projects_model.php */
