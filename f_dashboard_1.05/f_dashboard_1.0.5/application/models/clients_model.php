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
class Clients_model extends Super_Model
{

    // -- __construct ----------------------------------------------------------------------------------------------
    function __construct()
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        // Call the Model constructor
        parent::__construct();
    }

    // -- countClients ----------------------------------------------------------------------------------------------
    /**
     * count clients
     * @return numeric  [number of rows]
     */
    function countClients()
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT * FROM clients");

        $results = $query->num_rows();

        //---return
        return $results;

    }

    // -- allClients ----------------------------------------------------------------------------------------------
    /**
     * return array of all the rows of clients in table
     * accepts order_by and asc/desc values
     * 
     * @param $orderby sorting
     * @param $sort sort order
     * @return	array
     */

    function allClients($orderby = 'clients_company_name', $sort = 'ASC')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //check if any specifi ordering was passed
        if (! $this->db->field_exists($orderby, 'clients')) {
            $orderby = 'clients_company_name';
        }

        //check if sorting type was passed
        $sort = ($sort == 'asc' || $sort == 'desc') ? $sort : 'ASC';

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT *
                                          FROM clients 
                                          ORDER BY $orderby $sort");

        $results = $query->result_array(); //multi row array

        //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        return $results;

    }

    // -- searchClients ----------------------------------------------------------------------------------------------
    /**
     * search clients table and return results for all matching clients as array
     *
     * @param $offset pagination
     * @param $type searching or counting
     * @return	array
     */

    function searchClients($offset = 0, $type = 'search')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';
        $limiting = '';

        //system page limit or set default 25
        $limit = (is_numeric($this->data['settings_general']['results_limit'])) ? $this->data['settings_general']['results_limit'] : 25;

        //conditional sql
        //determine if any search condition where passed in the search form
        //actual post data is already cached into $this->input->get(), so use that instead of $_post
        if ($this->input->get('client_name')) {
            $client_name = str_replace("'", "", $this->db->escape($this->input->get('client_name')));
            $conditional_sql .= " AND clients_company_name LIKE '%$client_name%'";
        }
        if ($this->input->get('client_email')) {
            $client_email = $this->db->escape($this->input->get('client_email'));
            $conditional_sql .= " AND client_users.client_users_email = $client_email";
        }
        if (is_numeric($this->input->get('client_id'))) {
            $client_id = $this->db->escape($this->input->get('client_id'));
            $conditional_sql .= " AND clients_id = $client_id";
        }

        //create the order by sql additional condition
        //these sorting keys are passed in the url and must be same as the ones used in the controller.
        $sort_order = ($this->uri->segment(5) == 'desc') ? 'desc' : 'asc';
        $sort_columns = array(
            'sortby_clientid' => 'clients.clients_id',
            'sortby_contactname' => 'client_users.client_users_main_contact',
            'sortby_companyname' => 'clients.clients_company_name',
            'sortby_dueinvoices' => 'unpaid_invoices',
            'sortby_allinvoices' => 'all_invoices',
            'sortby_projects' => 'active_projects');
        $sort_by = (array_key_exists('' . $this->uri->segment(6), $sort_columns)) ? $sort_columns[$this->uri->segment(6)] : 'clients.clients_id';
        $sorting_sql = "ORDER BY $sort_by $sort_order";

        //are we searching records or just counting rows
        //row count is used by pagination class
        if ($type == 'search') {
            $limiting = "LIMIT $limit OFFSET $offset";
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT clients.*,
                                          client_users.*,
                                          (SELECT SUM(invoices.invoices_amount)
                                            FROM invoices
                                            WHERE invoices.invoices_clients_id = clients.clients_id
                                            AND invoices.invoices_status NOT IN('paid'))
                                            AS unpaid_invoices,
                                          (SELECT SUM(invoices.invoices_amount)
                                            FROM invoices
                                            WHERE invoices.invoices_clients_id = clients.clients_id)
                                            AS all_invoices,
                                          (SELECT COUNT(projects.projects_id)
                                            FROM projects
                                            WHERE projects.projects_clients_id = clients.clients_id
                                            AND projects.projects_status = 'active')
                                            AS active_projects,
                                          (SELECT COUNT(projects.projects_id)
                                            FROM projects
                                            WHERE projects.projects_clients_id = clients.clients_id)
                                            AS all_projects
                                          FROM clients
                                            LEFT OUTER JOIN client_users
                                            ON client_users.client_users_clients_id = clients.clients_id
                                            AND client_users.client_users_main_contact = 'yes'
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

        //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        return $results;

    }

    // -- clientDetails ----------------------------------------------------------------------------------------------
    /**
     * returns all the data for a single client. Selected by client id.
     * 
     * @param $client_id client id
     * @return	array
     */

    function clientDetails($client_id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //if no valie client id, return false
        if (! is_numeric($client_id)) {
            return false;
        }

        //escape data
        $client_id = $this->db->escape($client_id);

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("SELECT clients.*, client_users.*
                                            FROM clients 
                                            LEFT OUTER JOIN client_users
                                            ON client_users.client_users_clients_id = clients.clients_id
                                            AND client_users.client_users_main_contact = 'yes'
                                            WHERE clients_id = $client_id");

        $results = $query->row_array();

        //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        return $results;

    }

    // -- updateClientDetails ----------------------------------------------------------------------------------------------
    /**
     * clients details, field by field. Input is normaly coming from Modal (editable) as selected by client_id.
     * returns false or true
     *
     * @param $client_id client id
     * @param $field table field affected
     * @param $new_value update value1
     * @return	bool
     */

    function updateClientDetails($client_id = '', $field = '', $new_value = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //if no value client id, return false
        if (! is_numeric($client_id) || $field == '') {
            //ajax-log error to file
            log_message('error', '[FILE: ' . __file__ . ']  [FUNCTION: ' . __function__ . ']  [LINE: ' . __line__ . "]  [MESSAGE: missing data (client_id or field)]");
            return false;
        }

        //check if field exists in database table
        if (! $this->db->field_exists($field, 'clients')) {
            //ajax-log error to file
            log_message('error', '[FILE: ' . __file__ . ']  [FUNCTION: ' . __function__ . ']  [LINE: ' . __line__ . "]  [MESSAGE: field ($field) not found]");
            //return
            return false;
        }

        //escape data
        $new_value = $this->db->escape($new_value);
        $client_id = $this->db->escape($client_id);

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        $query = $this->db->query("UPDATE clients
                                          SET $field = $new_value
                                          WHERE clients_id = $client_id");

        $results = $this->db->affected_rows(); //affected rows

        //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end');

        //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        if (is_numeric($results) || $transaction_result === true) {
            return true;
        } else {
            return false;
        }
    }

    // -- addClients ----------------------------------------------------------------------------------------------
    /**
     * add new client to database
     *
     * @return	bool
     */

    function addClients()
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        /*text formatting - ucwords*/
        $format_input = array(
            'clients_company_name',
            'clients_address',
            'clients_city',
            'clients_state',
            'clients_country');

        //escape all data and set as variable
        foreach ($_POST as $key => $value) {

            //format any applicable text
            if (in_array($key, $format_input)) {
                $$key = $this->db->escape(ucwords(strtolower($this->input->post($key))));
            } else {
                $$key = $this->db->escape($this->input->post($key));
            }

            //remove single quotes from clients_optionalfield.*
            // these will have quotes added in sql below
            if (preg_match("%clients_optionalfield%", $key)) {
                $$key = str_replace("'", "", ($this->input->post($key)));
            }
        }

        //optional fields declare
        $clients_optionalfield1 = (isset($clients_optionalfield1)) ? $clients_optionalfield1 : '';
        $clients_optionalfield2 = (isset($clients_optionalfield2)) ? $clients_optionalfield2 : '';
        $clients_optionalfield3 = (isset($clients_optionalfield3)) ? $clients_optionalfield3 : '';

        //generate client random code
        $client_unique_code = random_string('alnum', 20); //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start'); //_____ADD NEW CLIENT_______
        $query = $this->db->query("INSERT INTO clients (
                                               clients_date_created,
                                               clients_company_name,
                                               clients_address,
                                               clients_city,
                                               clients_state,
                                               clients_zipcode,
                                               clients_country,
                                               clients_website,
                                               clients_optionalfield1,
                                               clients_optionalfield2,
                                               clients_optionalfield3,
                                               client_unique_code
                                               )VALUES(
                                               NOW(),
                                               $clients_company_name,
                                               $clients_address,
                                               $clients_city,
                                               $clients_state,
                                               $clients_zipcode,
                                               $clients_country,
                                               $clients_website,
                                               '$clients_optionalfield1',
                                               '$clients_optionalfield2',
                                               '$clients_optionalfield3',
                                               '$client_unique_code')");
        $results = $this->db->insert_id(); //client_id (last insert item)

        //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end'); //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return new  client_id or false
        if ($results > 0) {
            return $results;
        } else {
            return false;
        }

    }

    // -- clientIdFromCode ----------------------------------------------------------------------------------------------
    /**
     * returns the client id for a given client code
     * 
     * @param	string $client_unique_code clients unique code
     * @return void
     */
    function clientIdFromCode($client_unique_code = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = ''; //check cliet code
        if (strlen($client_unique_code) < 45) {
            return false;
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start'); //_____GET NEW CLIENTS ID_______
        $query = $this->db->query("SELECT clients_id FROM clients
                                                     WHERE client_unique_code = '$client_unique_code'");
        $results = $query->row_array(); //single row array
        $client_id = $results['clients_id']; //benchmark/debug
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end'); //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //return results
        if (is_numeric($client_id)) {
            return $client_id;
        } else {
            return false;
        }

    }

    // -- editProfile ----------------------------------------------------------------------------------------------
    /**
     * edit/update a clients profile
     *
     * 
     * @param numeric $id client id
     * @param string $client_optional_fields optional fields that must be included in sql updae query
     * @return array
     */

    function editProfile($id = '', $client_optional_fields = array())
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $additional_sql = '';
        if (! is_numeric($id)) {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [id=$id]", '');
            return false;
        }

        //escape params items
        $id = $this->db->escape($id); //optional form fields
        foreach ($client_optional_fields as $key) {
            //get the optional fields form post value
            $value = $this->db->escape($this->input->post($key)); //create addional sql to update this optional field
            $additional_sql .= " $key = $value,";
        }

        //escape all post item
        foreach ($_POST as $key => $value) {
            $$key = $this->db->escape($this->input->post($key));
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start'); //_____SQL QUERY_______
        $query = $this->db->query("UPDATE clients
                                          SET
                                          $additional_sql
                                          clients_company_name = $clients_company_name,
                                          clients_address = $clients_address,
                                          clients_city = $clients_city,
                                          clients_state = $clients_state,
                                          clients_zipcode = $clients_zipcode,
                                          clients_country = $clients_country,
                                          clients_website = $clients_website
                                          WHERE clients_id = $id");
        $results = $this->db->insert_id(); //last item insert id

        //----------benchmarking end------------------
        $this->benchmark->mark('code_end');
        $execution_time = $this->benchmark->elapsed_time('code_start', 'code_end'); //debugging data
        $this->__debugging(__line__, __function__, $execution_time, __class__, $results);
        //----------sql & benchmarking end----------

        //---return
        if (is_numeric($results)) {
            return true;
        } else {
            return false;
        }
    }

    // -- deleteClient----------------------------------------------------------------------------------------------
    /**
     * delete a client
     * typically this is the last step in the process of deleting a client (having deleted all other items)
     *
     * @param numeric $id client id
     * @return	bool
     */

    function deleteClient($id = '')
    {

        //profiling::
        $this->debug_methods_trail[] = __function__;

        //declare
        $conditional_sql = '';

        //flow control
        $next = true;

        //if no valie client id, return false
        if (! is_numeric($id)) {
            $this->__debugging(__line__, __function__, 0, "Invalid Data [id: $id]", '');
            return false;
        }

        //----------sql & benchmarking start----------
        $this->benchmark->mark('code_start');

        //_____SQL QUERY_______
        if ($next) {
            $query = $this->db->query("DELETE FROM clients
                                          WHERE clients_id = $id");
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

}
/* End of file clients_model.php */
/* Location: ./application/models/clients_model.php */
