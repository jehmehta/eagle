<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * class for perfoming all cronjobs related functions
 * [TYPICAl CRON URL] http://www.yourdomain.com/admin/cronjobs/general/AHusEwFd8HDg630sk
 * [SECURITY KEY] This must be changed in /config/settings.php for security
 *
 * @author   Nextloop.net
 * @access   public
 * @see      http://www.nextloop.net
 */
class Cronjobs extends MY_Controller
{

    /**
     * constructor method
     */
    public function __construct()
    {

        parent::__construct();

        //profiling::
        $this->data['controller_profiling'][] = __function__;

    }

    /**
     * This is our re-routing function and is the inital function called
     *
     */
    function index()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //uri - action segment
        $action = $this->uri->segment(3);

        //re-route to correct method
        switch ($action) {
            case 'general':
                $this->__generalCron();
                break;

            default:
                $this->__defaultCron();
        }

    }

    /**
     * run the general cron
     *
     */
    function __generalCron()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //flow control
        $next = true;

        //check authentication key
        if ($this->uri->segment(4) == $this->config->item('security_key')) {

            //refresh milestone
            $this->refresh->milestones('all');

            //refresh tasks
            $this->refresh->taskStatus('all');

            //refresh tasks
            $this->refresh->projectStatus('all');

            //refresh invoice status
            $this->refresh->basicInvoiceStatus();

            //send emails that are in the queue
            $this->__emailQueue();

        } else {
            echo 'Permission Denied';
        }
    }

    /**
     * send emails that are in the queue
     *
     */
    function __emailQueue()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;

        //flow control
        $next = true;

        //get email queue data
        $queue = $this->email_queue_model->getEmailBatch(10);
        $this->data['debug'][] = $this->email_queue_model->debug_data;

        //loop throuh and send emails
        $delete_list = '';
        $found_email = false; //reset
        if ($next && is_array($queue)) {
            for ($i = 0; $i < count($queue); $i++) {

                //reset email settings
                $this->email->clear();

                //send email
                email_default_settings(); //defaults (from emailer helper)

                //send
                $this->email->to($queue[$i]['email_queue_email']);
                $this->email->subject($queue[$i]['email_queue_subject']);
                $this->email->message($queue[$i]['email_queue_message']);
                $this->email->send();

                //comma separated list for later deleting from queue
                $delete_list .= ',' . $queue[$i]['email_queue_id'];

                //we sent some emails
                $found_email = true;
            }
        }

        //delete emails that have been sent
        if ($next && $found_email) {
            //prepre list of email id's
            $delete_list = trim($delete_list, ',');
            //delete emails
            $this->email_queue_model->deleteFromQueue($delete_list);
            $this->data['debug'][] = $this->email_queue_model->debug_data;
        }

    }

    /**
     * nothing to see here
     *
     */
    function __defaultCron()
    {

        //profiling
        $this->data['controller_profiling'][] = __function__;
    }
}

/* End of file cron.php */
/* Location: ./application/controllers/admin/cron.php */
