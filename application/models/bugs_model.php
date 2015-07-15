<?php

if (! defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * class for perfoming all bugs related data abstraction
 *
 * @author   Nextloop.net
 * @access   public
 * @see      http://www.nextloop.net
 */
class Bugs_model extends Super_Model
{

    var $debug_methods_trail;
    var $number_of_rows;

    // -- __construct ----------------------------------------------------------------------------------------------
    /**
     * no action
     *
     * 
     */
    function __construct()
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        // Call the Model constructor
        parent::__construct();
    }

    // -- searchBugs ----------------------------------------------------------------------------------------------
    /**
     * search bugs
     *
     * 
     * @param numeric   $offset  pagination
     * @param	string    $type 'search', 'count'
     * @return	array
     */

    function searchBugs($offset = 0, $type = 'search')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';
        $limiting = '';

        //system page limit or set default 25
        $limit = (is_numeric($this->data['settings_general']['results_limit'])) ? $this->data['settings_general']['results_limit'] : 25;

        //---is there any search data-----------------
        if (in_array($this->input->get('bugs_status'), array(
            'new-bug',
            'in-progress',
            'resolved',
            'not-a-bug'))) {
            $bugs_status = $this->db->escape($this->input->get('bugs_status'));
            $conditional_sql .= " AND bugs.bugs_status = $bugs_status";
        }
        if (is_numeric($this->input->get('bugs_project_id'))) {
            $bugs_project_id = $this->db->escape($this->input->get('bugs_project_id'));
            $conditional_sql .= " AND bugs.bugs_project_id = $bugs_project_id";
        }
        if (is_numeric($this->input->get('bugs_client_id'))) {
            $bugs_client_id = $this->db->escape($this->input->get('bugs_client_id'));
            $conditional_sql .= " AND bugs.bugs_client_id = $bugs_client_id";
        }

        //create the order by sql additional condition
        //these sorting keys are passed in the url and must be same as the ones used in the controller.
        $sort_order = ($this->uri->segment(5) == 'desc') ? 'desc' : 'asc';
        $sort_columns = array(
            'sortby_client' => 'bugs.bugs_client_id',
            'sortby_project' => 'bugs.bugs_project_id',
            'sortby_date' => 'bugs.bugs_date',
            'sortby_status' => 'bugs.bugs_status');
        $sort_by = (array_key_exists(''.$this->uri->segment(6), $sort_columns)) ? $sort_columns[$this->uri->segment(6)] : 'bugs.bugs_id';
        $sorting_sql = "ORDER BY $sort_by $sort_order";

        //are we searching records or just counting rows
        //row count is used by pagination class
        if ($type == 'search' || $type == 'results') {
            $limiting = "LIMIT $limit OFFSET $offset";
        }

        //CLIENT-PANEL: limit to this clients data
        if (is_numeric($this->client_id) || $this->uri->segment(1) == 'client') {
            $client_id = $this->client_id;
            $conditional_sql .= " AND bugs.bugs_client_id = '$client_id'";
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT bugs.*, projects.*, clients.*, client_users.*, team_profile.*
                                             FROM bugs
                                             LEFT OUTER JOIN projects
                                             ON bugs.bugs_project_id = projects.projects_id
                                             LEFT OUTER JOIN clients
                                             ON bugs.bugs_client_id = clients.clients_id
                                             LEFT OUTER JOIN client_users
                                             ON bugs.bugs_reported_by_id = client_users.client_users_id
                                             LEFT OUTER JOIN team_profile
                                             ON bugs.bugs_resolved_by_id = team_profile.team_profile_id
                                             WHERE 1 = 1
                                             $conditional_sql
                                             $sorting_sql
                                             $limiting");
        //results (search or rows)
        //rows are used by pagination class & results are used by tbs block merge
        if ($type == 'search' || $type == 'results') {
            $results = $query->result_array();
        } else {
            $results = $query->num_rows();
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

    // -- allBugsCounts ----------------------------------------------------------------------------------------------
    /**
     * count various bugs based on status
     *
     * 
     * @param numeric   $client_id optional; if provided, count will be limited to that clients
     * @return	array
     */

    function allBugsCounts($client_id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //is this for a client
        if (is_numeric($client_id)) {
            $conditional_sql .= " AND bugs_client_id = '$client_id'";
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT (SELECT COUNT(bugs_id)
                                                  FROM bugs
                                                  WHERE bugs_status = 'new-bug'
                                                  $conditional_sql) AS new,
                                          (SELECT COUNT(bugs_id)
                                                  FROM bugs
                                                  WHERE bugs_status = 'resolved'
                                                  $conditional_sql) AS resolved,
                                          (SELECT COUNT(bugs_id)
                                                  FROM bugs
                                                  WHERE bugs_status = 'in-progress'
                                                  $conditional_sql) AS in_progress,
                                          (SELECT COUNT(bugs_id)
                                                  FROM bugs
                                                  WHERE bugs_status = 'not-a-bug'
                                                  $conditional_sql) AS not_a_bug,
                                          (SELECT COUNT(bugs_id)
                                                  FROM bugs
                                                  WHERE bugs_status NOT IN('resolved', 'not-a-bug')
                                                  $conditional_sql) all_open,
                                          (SELECT COUNT(bugs_id)
                                                  FROM bugs
                                                  WHERE 1 = 1
                                                  $conditional_sql) AS all_bugs
                                          FROM bugs 
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

    // -- getBug ----------------------------------------------------------------------------------------------
    /**
     * load a bug based on bug id
     *
     * 
     * @param numeric $bug_id bug id
     * @return	array
     */

    function getBug($bug_id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //validate id
        if (! is_numeric($bug_id)) {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [bug id=$bug_id]", '');
            return false;
        }

        //escape params items
        $bug_id = $this->db->escape($bug_id);

        //CLIENT-PANEL: limit to this clients data
        if (is_numeric($this->client_id) || $this->uri->segment(1) == 'client') {
            $client_id = $this->client_id;
            $conditional_sql .= " AND bugs.bugs_client_id = '$client_id'";
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT bugs.*, projects.*, clients.*, client_users.*, team_profile.*
                                          FROM bugs
                                          LEFT OUTER JOIN projects
                                          ON projects.projects_id = bugs.bugs_project_id
                                          LEFT OUTER JOIN clients
                                          ON clients.clients_id = bugs.bugs_client_id
                                          LEFT OUTER JOIN client_users
                                          ON client_users.client_users_id = bugs.bugs_reported_by_id    
                                          LEFT OUTER JOIN team_profile
                                          ON bugs.bugs_resolved_by_id = team_profile.team_profile_id
                                          WHERE bugs.bugs_id = $bug_id
                                          $conditional_sql");

        $results = $query->row_array();

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //---return
        return $results;

    }

    // -- updateBug ----------------------------------------------------------------------------------------------
    /**
     * update a bugs status and comment
     *
     * 
     * @return	bool
     */

    function updateBug()
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //escape all post item
        foreach ($_POST as $key => $value) {
            $$key = $this->db->escape($this->input->post($key));
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //get my id
        $my_id = $this->data['vars']['my_id'];

        //_____SQL QUERY_______
        $query = $this->db->query("UPDATE bugs
                                          SET 
                                          bugs_status = $bugs_status,
                                          bugs_comment = $bugs_comment,
                                          bugs_resolved_by_id = '$my_id'
                                          WHERE bugs_id = $bugs_id");

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

    // -- addBug ----------------------------------------------------------------------------------------------
    /**
     * add new bug
     *
     * 
     * @return	bool
     */

    function addBug()
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //escape all post item
        foreach ($_POST as $key => $value) {
            $$key = $this->db->escape($this->input->post($key));
        }

        //CLIENT-PANEL: limit to this clients data
        if (is_numeric($this->client_id) || $this->uri->segment(1) == 'client') {
            $client_id = $this->client_id;
            $my_id = $this->data['vars']['my_id'];
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("INSERT INTO bugs (
                                          bugs_project_id,
                                          bugs_client_id,
                                          bugs_title,
                                          bugs_description,
                                          bugs_reported_by_id,
                                          bugs_date
                                          )VALUES(
                                          $bugs_project_id,
                                          '$client_id',
                                          $bugs_title,
                                          $bugs_description,
                                          '$my_id',
                                          NOW())");

        $results = $this->db->insert_id(); //last item insert id

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

    // -- deleteBug ----------------------------------------------------------------------------------------------
    /**
     * delete a single bug
     *
     * 
     * @param numeric $bug_id bugs id
     * @return	bool
     */

    function deleteBug($bug_id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //validate id
        if (! is_numeric($bug_id)) {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [bug id=$bug_id]", '');
            return false;
        }

        //escape params items
        $bug_id = $this->db->escape($bug_id);

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("DELETE FROM bugs
                                          WHERE bugs_id = $bug_id");

        $results = $this->db->affected_rows();

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);

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
     * 
     * @param	string $projects_list a mysql array/list formatted projects list [e.g. 1,2,3,4]
     * @return	bool
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
            if (! is_numeric(trim($lists[$i]))) {
                //log error
                log_message('error', '[FILE: ' . __file__ . ']  [FUNCTION: ' . __function__ . ']  [LINE: ' . __line__ . "]  [MESSAGE: Bulk Deleting file messages, for projects($clients_projects) failed. Invalid projects list]");
                //exit
                return false;
            }
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        if ($next) {
            $query = $this->db->query("DELETE FROM bugs
                                          WHERE bugs_project_id IN($projects_list)");
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

    // -- validateClientOwner ----------------------------------------------------------------------------------------------
    /**
     * confirm if a given client owns this requested item
     *
     * 
     * @param numeric $resource_id
     * @param   numeric $client_id
     * @return	bool
     */

    function validateClientOwner($resource_id = '', $client_id)
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //validate id
        if (! is_numeric($resource_id) || ! is_numeric($client_id)) {
            $this->__debugging(__line__, __function__, 0, "Invalid Input Data", '');
            return false;
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT *
                                          FROM bugs 
                                          WHERE bugs_id = $resource_id
                                          AND bugs_client_id = $client_id");

        $results = $query->num_rows(); //count rows

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //---return
        if ($results > 0) {
            return true;
        } else {
            return false;
        }
    }
}

/* End of file bugs_model.php */
/* Location: ./application/models/bugs_model.php */
