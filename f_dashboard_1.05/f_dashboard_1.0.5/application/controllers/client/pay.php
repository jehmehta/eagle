<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * class for perfoming all Pay related functions
 *
 * @author   Nextloop.net
 * @access   public
 * @see      http://www.nextloop.net
 */
class Pay extends MY_Controller
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
        $this->data['template_file'] = PATHS_CLIENT_THEME . '/pay.html';

        //css settings
        $this->data['vars']['css_menu_projects'] = 'open'; //menu

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

        //create pulldown lists
        $this->__pulldownLists();

        //uri - action segment
        $action = $this->uri->segment(4);

        //default page titles
        $this->data['vars']['main_title'] = $this->data['lang']['lang_invoices'];
        $this->data['vars']['main_title_icon'] = '<i class="icon-list-alt"></i>';

        $this->data['vars']['sub_title'] = $this->data['lang']['lang_payments'];
        $this->data['vars']['sub_title_icon'] = '<i class="icon-credit-card"></i>';

        //re-route to correct method
        switch ($action) {

            case 'new':
                $this->__newPayment();
                break;

            case 'confirm':
                $this->__confirmPayment();
                break;

            case 'thankyou':
                $this->__thankyou();
                break;

            default:
                $this->__newPayment();
        }

        //load view
        $this->__flmView('client/main');

    }

    /**
     * start a new payment
     *
     */
    function __newPayment()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //flow control
        $next = true;

        //invoice unique id
        $invoice_unique_id = $this->uri->segment(3);

        //get actual invoice id
        if ($next) {
            $invoice_id = $this->invoices_model->getInvoiceID($invoice_unique_id);
            $this->data['debug'][] = $this->invoices_model->debug_data;
            if (!is_numeric($invoice_id)) {
                //error loading invoice
                $this->notifications('wi_notification', $this->data['lang']['lang_request_could_not_be_completed']);
                //halt
                $next = false;
            }
        }

        //check client ownership
        if ($next) {
            /** CLIENT CHECK PERMISSION **/
            if (!$this->permissions->invoicesView($invoice_id)) {
                redirect('/client/error/permission-denied-or-not-found');
            }
        }

        /*--------------------------------------------------------------------
        * REFRESH THIS INVOICE
        *-------------------------------------------------------------------*/
        if ($next) {
            $this->refresh->refreshSingleInvoice($invoice_id);
            $this->data['debug'][] = $this->refresh->debug_data;
        }

        //get invoice details
        if ($next) {
            $this->data['reg_fields'][] = 'invoice';
            $this->data['fields']['invoice'] = $this->invoices_model->getInvoice($invoice_id);
            $this->data['debug'][] = $this->invoices_model->debug_data;
            if (!$this->data['fields']['invoice']) {
                //error loading invoice
                $this->notifications('wi_notification', $this->data['lang']['lang_request_could_not_be_completed']);
                //halt
                $next = false;
            }
        }

        //get invoice payments
        if ($next) {
            //sum payments
            $this->data['vars']['invoice_payments_sum'] = $this->payments_model->sumInvoicePayments($invoice_id);
            $this->data['debug'][] = $this->payments_model->debug_data;

            //amount due
            $this->data['vars']['invoice_balance_due'] = $this->data['fields']['invoice']['invoices_amount'] - $this->data['vars']['invoice_payments_sum'];

        }

        //does this invoice have any amount due
        if ($next) {

            if ($this->data['vars']['invoice_balance_due'] > 0) {
                $this->data['visible']['wi_payment_selector'] = 1;
                $this->data['visible']['wi_payment_summary'] = 1;
            } else {
                $this->notifications('wi_notification', $this->data['lang']['lang_there_is_no_amount_owing_on_invoice']);
            }
        }

        //allow part payment?
        if ($next) {
            if ($this->data['settings_invoices']['settings_invoices_allow_partial_payment'] == 'no') {
                $this->data['vars']['part_payment'] = 'readonly="readonly"';
            }
        }

    }

    /**
     * this is where we setup the payment gateway form
     *
     */
    function __confirmPayment()
    {
        //profiling
        $this->data['controller_profiling'][] = __function__;

        //flow control
        $next = true;

        //reload invoice details
        $this->__newPayment();

        //some vars
        $this->data['vars']['payment_total'] = $this->input->post('payment_amount');
        $this->data['vars']['payment_method'] = strtolower($this->input->post('payment_method'));

        //validate form
        if ($next) {
            if (!$this->__flmFormValidation('new_payment')) {
                //show error
                $this->notices('error', $this->form_processor->error_message, 'html');
                //halt
                $next = false;
            }
        }

        //check payment is not more than due
        if ($next) {
            if ($_POST['payment_amount'] > $this->data['vars']['invoice_balance_due']) {
                //show error
                $this->notices('error', $this->data['lang']['lang_amount_is_more'], 'html');
                //halt
                $next = false;
            }
        }

        /** LOAD PAYPAL GATEWAY **/
        if ($next && $this->data['vars']['payment_method'] == 'paypal') {

            //get payment method settings
            $this->data['reg_fields'][] = 'gateway';
            $this->data['fields']['gateway'] = $this->settings_paypal_model->getSettings();
            $this->data['debug'][] = $this->settings_paypal_model->debug_data;

            //show the [confirm payment] with correct [gateway form]
            if ($this->data['fields']['gateway']) {
                $this->data['visible']['wi_gateway_paypal'] = 1;
                $this->data['visible']['wi_payment_summary'] = 1;
                $this->data['visible']['wi_payment_selector'] = 0;
            } else {
                //show selector
                $this->data['visible']['wi_payment_selector'] = 1;
                //message
                $this->notices('error', $this->data['lang']['lang_requested_item_not_loaded'], 'noty');
            }
        }

        /** LOAD CASH GATEWAY **/
        if ($next && $this->data['vars']['payment_method'] == 'cash') {

            //get payment method settings
            $this->data['reg_fields'][] = 'gateway';
            $this->data['fields']['gateway'] = $this->settings_cash_model->getSettings();
            $this->data['debug'][] = $this->settings_cash_model->debug_data;

            //show the [confirm payment] with correct [gateway form]
            if ($this->data['fields']['gateway']) {
                $this->data['vars']['settings_payment_details'] = $this->data['fields']['gateway']['settings_cash_details'];
                $this->data['visible']['wi_gateway_direct'] = 1;
                $this->data['visible']['wi_payment_summary'] = 1;
                $this->data['visible']['wi_payment_selector'] = 0;
            } else {
                //show selector
                $this->data['visible']['wi_payment_selector'] = 1;
                //message
                $this->notices('error', $this->data['lang']['lang_requested_item_not_loaded'], 'noty');
            }
        }

        /** LOAD BANK GATEWAY **/
        if ($next && $this->data['vars']['payment_method'] == 'bank') {

            //get payment method settings
            $this->data['reg_fields'][] = 'gateway';
            $this->data['fields']['gateway'] = $this->settings_bank_model->getSettings();
            $this->data['debug'][] = $this->settings_bank_model->debug_data;

            //show the [confirm payment] with correct [gateway form]
            if ($this->data['fields']['gateway']) {
                $this->data['vars']['settings_payment_details'] = $this->data['fields']['gateway']['settings_bank_details'];
                $this->data['visible']['wi_gateway_direct'] = 1;
                $this->data['visible']['wi_payment_summary'] = 1;
                $this->data['visible']['wi_payment_selector'] = 0;
            } else {
                //show selector
                $this->data['visible']['wi_payment_selector'] = 1;
                //message
                $this->notices('error', $this->data['lang']['lang_requested_item_not_loaded'], 'noty');
            }
        }

        //show input form
        if (!$next) {
            $this->data['visible']['wi_payment_selector'] = 1;
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

        //[all_payment_methods]
        $data = $this->settings_payment_methods_model->paymentMethods('enabled');
        $this->data['debug'][] = $this->settings_payment_methods_model->debug_data;
        $this->data['lists']['all_payment_methods'] = create_pulldown_list($data, 'payment_methods', 'id');

    }

    /**
     * start a new payment
     *
     */
    function __thankyou()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //todo - maybe check referrer to ensure users dont just load this page?

        //show notification
        $this->notifications('wi_notification', $this->data['lang']['lang_thank_you_for_your_payment']);

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
        if ($form == 'new_payment') {

            //numeric
            $fields = array('payment_amount' => $this->data['lang']['lang_amount']);
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

/* End of file pay.php */
/* Location: ./application/controllers/client/pay.php */
