SET NAMES utf8;
SET foreign_key_checks = 0;
SET time_zone = 'SYSTEM';
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `bugs`;
CREATE TABLE `bugs` (
  `bugs_id` int(11) NOT NULL auto_increment,
  `bugs_project_id` int(11) NOT NULL,
  `bugs_client_id` int(11) NOT NULL,
  `bugs_title` varchar(250) NOT NULL,
  `bugs_description` text NOT NULL,
  `bugs_reported_by_id` int(11) NOT NULL,
  `bugs_date` datetime NOT NULL,
  `bugs_status` varchar(20) NOT NULL default 'new-bug' COMMENT 'new-bug/resolved/not-a-bug/in-progress',
  `bugs_comment` text NOT NULL,
  `bugs_resolved_by_id` int(11) NOT NULL,
  PRIMARY KEY  (`bugs_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `ci_sessions`;
CREATE TABLE `ci_sessions` (
  `session_id` varchar(40) collate utf8_bin NOT NULL default '0' COMMENT 'This Table: Has no default data',
  `ip_address` varchar(45) collate utf8_bin NOT NULL default '0',
  `user_agent` varchar(120) collate utf8_bin NOT NULL,
  `last_activity` int(10) unsigned NOT NULL default '0',
  `user_data` text collate utf8_bin NOT NULL,
  PRIMARY KEY  (`session_id`),
  KEY `last_activity_idx` (`last_activity`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `clients`;
CREATE TABLE `clients` (
  `clients_id` int(11) NOT NULL auto_increment COMMENT 'This Table: Has no default data',
  `clients_date_created` date NOT NULL,
  `clients_company_name` varchar(150) NOT NULL,
  `clients_address` varchar(100) default NULL,
  `clients_city` varchar(50) default NULL,
  `clients_state` varchar(50) default NULL,
  `clients_zipcode` varchar(50) default NULL,
  `clients_country` varchar(50) default NULL,
  `clients_website` varchar(50) default NULL,
  `clients_optionalfield1` text,
  `clients_optionalfield2` text,
  `clients_optionalfield3` text,
  `client_unique_code` varchar(20) default NULL,
  PRIMARY KEY  (`clients_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `clients_optionalfields`;
CREATE TABLE `clients_optionalfields` (
  `clients_optionalfield_name` varchar(100) default NULL COMMENT 'This table has 3 default rows',
  `clients_optionalfield_title` varchar(50) default NULL,
  `clients_optionalfield_status` varchar(10) default NULL,
  `clients_optionalfield_require` varchar(10) default 'no' COMMENT 'yes/no'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `clients_optionalfields` (`clients_optionalfield_name`, `clients_optionalfield_title`, `clients_optionalfield_status`, `clients_optionalfield_require`) VALUES
('clients_optionalfield1',	'Sample Text',	'disabled',	'no'),
('clients_optionalfield2',	'Sample Text',	'disabled',	'no'),
('clients_optionalfield3',	'Sample Text',	'disabled',	'no');

DROP TABLE IF EXISTS `cronjobs`;
CREATE TABLE `cronjobs` (
  `cronjobs_id` varchar(100) NOT NULL,
  `cronjobs_last_run` datetime default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `cronjobs` (`cronjobs_id`, `cronjobs_last_run`) VALUES
('default',	NULL);

DROP TABLE IF EXISTS `file_comments`;
CREATE TABLE `file_comments` (
  `file_comments_id` int(11) NOT NULL auto_increment,
  `file_comments_file_id` int(11) NOT NULL,
  `file_comments_project_id` int(11) NOT NULL,
  `file_comments_client_id` int(11) NOT NULL,
  `file_comments_text` text NOT NULL,
  `file_comments_date` datetime NOT NULL,
  `file_comments_by` varchar(10) NOT NULL COMMENT 'team/client',
  `file_comments_by_id` int(11) NOT NULL,
  PRIMARY KEY  (`file_comments_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `file_messages`;
CREATE TABLE `file_messages` (
  `messages_id` int(11) NOT NULL auto_increment,
  `messages_project_id` int(11) NOT NULL,
  `messages_file_id` int(11) NOT NULL,
  `messages_date` datetime NOT NULL,
  `messages_text` text NOT NULL,
  `messages_by_id` int(11) NOT NULL,
  `messages_by` varchar(20) NOT NULL COMMENT 'client/team',
  PRIMARY KEY  (`messages_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `file_messages_replies`;
CREATE TABLE `file_messages_replies` (
  `messages_replies_id` int(11) NOT NULL auto_increment,
  `messages_replies_message_id` int(11) NOT NULL,
  `messages_replies_date` datetime NOT NULL,
  `messages_replies_text` text NOT NULL,
  `messages_replies_by_id` int(11) NOT NULL,
  `messages_replies_by` varchar(20) NOT NULL,
  PRIMARY KEY  (`messages_replies_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `filedownloads`;
CREATE TABLE `filedownloads` (
  `filedownloads_id` int(11) NOT NULL auto_increment,
  `filedownloads_project_id` int(11) NOT NULL,
  `filedownloads_client_id` int(11) NOT NULL,
  `filedownloads_file_id` int(11) NOT NULL,
  `filedownloads_date` datetime NOT NULL,
  `filedownloads_user_type` varchar(10) NOT NULL COMMENT 'client/team',
  `filedownloads_user_id` int(11) NOT NULL COMMENT 'id of client user/team member',
  PRIMARY KEY  (`filedownloads_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `files`;
CREATE TABLE `files` (
  `files_id` int(11) NOT NULL auto_increment,
  `files_project_id` int(11) NOT NULL,
  `files_client_id` int(11) NOT NULL,
  `files_uploaded_by` varchar(10) NOT NULL COMMENT 'client/team',
  `files_uploaded_by_id` int(11) NOT NULL,
  `files_name` varchar(250) NOT NULL,
  `files_description` text NOT NULL,
  `files_size` int(11) NOT NULL,
  `files_size_human` varchar(20) NOT NULL,
  `files_date_uploaded` date NOT NULL,
  `files_time_uploaded` time NOT NULL,
  `files_foldername` varchar(50) NOT NULL,
  `files_extension` varchar(50) NOT NULL,
  `files_events_id` varchar(50) NOT NULL,
  PRIMARY KEY  (`files_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `groups_id` int(11) NOT NULL auto_increment COMMENT 'This table: Has 1 default row for admin group. Group ID must be [1] & Group Name must be [Administrator]',
  `groups_name` varchar(250) NOT NULL,
  `my_project_details` tinyint(4) NOT NULL default '1',
  `my_project_files` tinyint(4) NOT NULL default '1',
  `my_project_milestones` tinyint(4) NOT NULL default '1',
  `my_project_my_tasks` tinyint(4) NOT NULL default '1',
  `my_project_others_tasks` tinyint(4) NOT NULL default '1',
  `my_project_messages` tinyint(4) NOT NULL default '1',
  `my_project_team_messages` tinyint(4) NOT NULL default '1',
  `my_project_invoices` tinyint(4) NOT NULL default '1',
  `bugs` tinyint(4) NOT NULL default '1',
  `clients` tinyint(4) NOT NULL default '1',
  `tickets` tinyint(4) NOT NULL default '1',
  `quotations` tinyint(4) NOT NULL default '1',
  `groups_allow_delete` tinyint(1) NOT NULL default '1',
  `groups_allow_edit` tinyint(1) NOT NULL default '1',
  `groups_allow_migrate` tinyint(1) NOT NULL default '1',
  `groups_allow_change_permissions` tinyint(1) NOT NULL default '1',
  `groups_allow_zero_members` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`groups_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `groups` (`groups_id`, `groups_name`, `my_project_details`, `my_project_files`, `my_project_milestones`, `my_project_my_tasks`, `my_project_others_tasks`, `my_project_messages`, `my_project_team_messages`, `my_project_invoices`, `bugs`, `clients`, `tickets`, `quotations`, `groups_allow_delete`, `groups_allow_edit`, `groups_allow_migrate`, `groups_allow_change_permissions`, `groups_allow_zero_members`) VALUES
(1,	'Administrator',	4,	4,	4,	4,	4,	4,	4,	4,	4,	4,	4,	4,	0,	0,	0,	0,	0),
(2,	'Staff',	1,	4,	4,	4,	1,	4,	4,	1,	4,	1,	4,	3,	1,	1,	1,	1,	1),
(3,	'Agent',	1,	4,	1,	4,	1,	4,	4,	0,	4,	0,	0,	0,	1,	1,	1,	1,	1);

DROP TABLE IF EXISTS `invoice_items`;
CREATE TABLE `invoice_items` (
  `invoice_items_id` int(11) NOT NULL auto_increment,
  `invoice_items_date_added` date NOT NULL,
  `invoice_items_title` varchar(250) NOT NULL,
  `invoice_items_description` varchar(250) default NULL,
  `invoice_items_amount` decimal(10,2) NOT NULL,
  PRIMARY KEY  (`invoice_items_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `invoice_products`;
CREATE TABLE `invoice_products` (
  `invoice_products_id` int(11) NOT NULL auto_increment,
  `invoice_products_project_id` int(11) NOT NULL,
  `invoice_products_invoice_id` int(11) NOT NULL,
  `invoice_products_title` varchar(250) NOT NULL,
  `invoice_products_description` varchar(250) NOT NULL,
  `invoice_products_quantity` int(11) NOT NULL,
  `invoice_products_rate` decimal(10,2) NOT NULL,
  `invoice_products_total` decimal(10,2) NOT NULL default '0.00',
  PRIMARY KEY  (`invoice_products_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `messages_id` int(11) NOT NULL auto_increment,
  `messages_project_id` int(11) NOT NULL,
  `messages_date` datetime NOT NULL,
  `messages_text` text NOT NULL,
  `messages_by` varchar(15) NOT NULL COMMENT 'client/team',
  `messages_by_id` int(11) NOT NULL,
  PRIMARY KEY  (`messages_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `messages_replies`;
CREATE TABLE `messages_replies` (
  `messages_replies_id` int(11) NOT NULL auto_increment,
  `messages_replies_project_id` int(11) NOT NULL,
  `messages_replies_message_id` int(11) NOT NULL,
  `messages_replies_date` datetime NOT NULL,
  `messages_replies_text` text NOT NULL,
  `messages_replies_by` varchar(15) NOT NULL COMMENT 'client/team',
  `messages_replies_by_id` int(11) NOT NULL,
  PRIMARY KEY  (`messages_replies_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `milestones`;
CREATE TABLE `milestones` (
  `milestones_id` int(11) NOT NULL auto_increment,
  `milestones_project_id` int(11) NOT NULL,
  `milestones_client_id` int(11) NOT NULL,
  `milestones_title` varchar(250) NOT NULL,
  `milestones_start_date` date NOT NULL,
  `milestones_end_date` date NOT NULL,
  `milestones_created_by` int(11) NOT NULL,
  `milestones_status` varchar(50) NOT NULL default 'pending' COMMENT 'pending/completed/behind schedule',
  `milestones_events_id` varchar(40) default NULL,
  PRIMARY KEY  (`milestones_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `online_status`;
CREATE TABLE `online_status` (
  `online_status_id` int(11) NOT NULL COMMENT 'This Table: Has no default data',
  `online_status_userid` int(11) NOT NULL,
  `online_status_usertype` int(11) NOT NULL,
  `online_status_last_seen` time default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `payments_id` int(11) NOT NULL auto_increment,
  `payments_invoice_id` int(11) NOT NULL,
  `payments_project_id` int(11) NOT NULL,
  `payments_client_id` int(11) NOT NULL,
  `payments_amount` decimal(10,2) NOT NULL,
  `payments_currency_code` varchar(25) NOT NULL,
  `payments_transaction_id` varchar(100) default NULL,
  `payments_transaction_status` varchar(50) default NULL,
  `payments_date` datetime NOT NULL,
  `payments_method` varchar(50) NOT NULL,
  `payments_notes` text,
  PRIMARY KEY  (`payments_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `level` tinyint(4) default NULL,
  `view_item` varchar(3) NOT NULL default 'no',
  `add_item` varchar(3) NOT NULL default 'no',
  `edit_item` varchar(3) NOT NULL default 'no',
  `delete_item` varchar(3) NOT NULL default 'no'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `permissions` (`level`, `view_item`, `add_item`, `edit_item`, `delete_item`) VALUES
(0,	'no',	'no',	'no',	'no'),
(1,	'yes',	'no',	'no',	'no'),
(2,	'yes',	'yes',	'no',	'no'),
(3,	'yes',	'yes',	'yes',	'no'),
(4,	'yes',	'yes',	'yes',	'yes');

DROP TABLE IF EXISTS `project_events`;
CREATE TABLE `project_events` (
  `project_events_id` int(11) NOT NULL auto_increment,
  `project_events_project_id` varchar(40) NOT NULL,
  `project_events_date` datetime NOT NULL,
  `project_events_type` varchar(100) default NULL COMMENT 'deleted/milestone/ file/invoice/file-message/project-message/milestone/task/project/bug/payment',
  `project_events_details` varchar(100) default NULL,
  `project_events_action` varchar(100) default NULL,
  `project_events_target_id` varchar(150) default NULL,
  `project_events_user_id` int(11) default NULL,
  `project_events_user_type` varchar(30) default NULL,
  UNIQUE KEY `project_events_id` (`project_events_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `project_members`;
CREATE TABLE `project_members` (
  `project_members_index` tinyint(4) NOT NULL auto_increment,
  `project_members_team_id` int(11) NOT NULL,
  `project_members_project_id` int(11) NOT NULL,
  `project_members_project_lead` varchar(5) NOT NULL default 'no',
  PRIMARY KEY  (`project_members_index`),
  UNIQUE KEY `project_members_unique_index` (`project_members_team_id`,`project_members_project_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `projects`;
CREATE TABLE `projects` (
  `projects_id` int(11) NOT NULL auto_increment,
  `projects_date_created` date NOT NULL,
  `project_deadline` date default NULL,
  `projects_date_completed` date default NULL,
  `projects_clients_id` int(11) NOT NULL,
  `projects_team_lead_id` int(11) default NULL,
  `projects_title` varchar(250) character set utf8 collate utf8_bin default NULL,
  `projects_description` text character set utf8 collate utf8_bin,
  `projects_last_activity` datetime default NULL,
  `projects_progress_percentage` tinyint(3) default '0',
  `projects_status` varchar(30) NOT NULL default 'in progress' COMMENT 'in progress/completed/behind schedule',
  `projects_events_id` varchar(40) default NULL,
  `projects_optionalfield1` text,
  `projects_optionalfield2` text,
  `projects_optionalfield3` text,
  `projects_optionalfield4` text,
  `projects_optionalfield5` text,
  PRIMARY KEY  (`projects_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `projects_optionalfields`;
CREATE TABLE `projects_optionalfields` (
  `projects_optionalfield_name` varchar(100) NOT NULL,
  `projects_optionalfield_title` varchar(50) NOT NULL,
  `projects_optionalfield_status` varchar(10) NOT NULL COMMENT 'enabled/disabled',
  `projects_optionalfield_require` varchar(10) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `projects_optionalfields` (`projects_optionalfield_name`, `projects_optionalfield_title`, `projects_optionalfield_status`, `projects_optionalfield_require`) VALUES
('projects_optionalfield1',	'Website URL',	'enabled',	'yes'),
('projects_optionalfield2',	'FTP User Name',	'enabled',	'yes'),
('projects_optionalfield3',	'FTP Password',	'enabled',	'yes'),
('projects_optionalfield4',	'Sample Text',	'disabled',	'no'),
('projects_optionalfield5',	'Sample Text',	'disabled',	'no');


DROP TABLE IF EXISTS `quotationforms`;
CREATE TABLE `quotationforms` (
  `quotationforms_id` int(11) NOT NULL auto_increment,
  `quotationforms_title` varchar(200) NOT NULL,
  `quotationforms_code` text NOT NULL,
  `quotationforms_date_created` datetime NOT NULL,
  `quotationforms_status` varchar(20) NOT NULL default 'enabled' COMMENT 'enabled/disabled',
  `quotations_created_by_id` int(11) NOT NULL,
  PRIMARY KEY  (`quotationforms_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `quotationforms` (`quotationforms_id`, `quotationforms_title`, `quotationforms_code`, `quotationforms_date_created`, `quotationforms_status`, `quotations_created_by_id`) VALUES
(1,	'Web Design Quotation Form',	'{\"fields\":[{\"label\":\"Do you have your existing site for redesign or you need new website\",\"field_type\":\"paragraph\",\"required\":true,\"field_options\":{\"size\":\"small\"},\"cid\":\"c35\"},{\"label\":\"Can you please describe your business\",\"field_type\":\"paragraph\",\"required\":true,\"field_options\":{\"size\":\"small\"},\"cid\":\"c10\"},{\"label\":\"Who are your competitors\",\"field_type\":\"paragraph\",\"required\":true,\"field_options\":{\"size\":\"small\"},\"cid\":\"c14\"},{\"label\":\"Do you have special features in mind\",\"field_type\":\"paragraph\",\"required\":true,\"field_options\":{\"size\":\"small\"},\"cid\":\"c18\"},{\"label\":\" Is the content ready for your web site\",\"field_type\":\"paragraph\",\"required\":true,\"field_options\":{\"size\":\"small\"},\"cid\":\"c40\"},{\"label\":\"Are there any example websites that you like\",\"field_type\":\"paragraph\",\"required\":true,\"field_options\":{\"size\":\"small\"},\"cid\":\"c30\"},{\"label\":\"What is your approximate budget for this project\",\"field_type\":\"paragraph\",\"required\":true,\"field_options\":{\"size\":\"small\"},\"cid\":\"c26\"},{\"label\":\"What is your deadline for finishing the site\",\"field_type\":\"paragraph\",\"required\":true,\"field_options\":{\"size\":\"small\"},\"cid\":\"c44\"}]}',	'2014-12-11 08:34:00',	'enabled',	1);


DROP TABLE IF EXISTS `quotationforms_templates`;
CREATE TABLE `quotationforms_templates` (
  `quotationforms_templates_id` varchar(100) NOT NULL,
  `quotationforms_templates_title` varchar(150) NOT NULL,
  `quotationforms_templates_content` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `quotations`;
CREATE TABLE `quotations` (
  `quotations_id` int(11) NOT NULL auto_increment,
  `quotations_date` datetime NOT NULL,
  `quotations_form_title` varchar(250) NOT NULL,
  `quotations_post_data` text NOT NULL,
  `quotations_form_data` text NOT NULL,
  `quotations_by_client` varchar(10) default 'no' COMMENT 'yes/no',
  `quotations_client_id` int(11) default NULL,
  `quotations_company_name` varchar(100) default NULL,
  `quotations_name` varchar(100) default NULL,
  `quotations_email` varchar(100) default NULL,
  `quotations_telephone` varchar(100) default NULL,
  `quotations_amount` decimal(10,2) default NULL,
  `quotations_admin_notes` text,
  `quotations_reviewed_by_id` int(11) default NULL,
  `quotations_reviewed_date` date default NULL,
  `quotations_status` varchar(15) default 'pending' COMMENT 'completed/pending',
  PRIMARY KEY  (`quotations_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `search_cache`;
CREATE TABLE `search_cache` (
  `id` int(11) NOT NULL auto_increment COMMENT 'This Table: Has no default data',
  `query_string` text character set utf8 collate utf8_bin,
  `date_added` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `setting_system`;
CREATE TABLE `setting_system` (
  `setting_system_id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`setting_system_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `settings_company`;
CREATE TABLE `settings_company` (
  `settings_id` varchar(20) NOT NULL,
  `company_name` varchar(100) NOT NULL COMMENT 'This Table: Has one default row with place holder company details. [company_sys: default]',
  `company_address_street` varchar(150) default NULL,
  `company_address_city` varchar(100) default NULL,
  `company_address_state` varchar(100) default NULL,
  `company_address_zip` varchar(50) default NULL,
  `company_address_country` varchar(50) default NULL,
  `company_telephone` varchar(25) default NULL,
  `company_email` varchar(100) NOT NULL,
  `company_email_name` varchar(50) NOT NULL,
  `company_email_signature` text,
  UNIQUE KEY `settings_id` (`settings_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `settings_company` (`settings_id`, `company_name`, `company_address_street`, `company_address_city`, `company_address_state`, `company_address_zip`, `company_address_country`, `company_telephone`, `company_email`, `company_email_name`, `company_email_signature`) VALUES
('default',	'Some Company Inc',	'1 Some Street',	'Some City',	'Some State',	'000000',	'Some Country',	'000000000',	'you@somecompnay.ccc',	'Some Company Name',	'');

DROP TABLE IF EXISTS `settings_events`;
CREATE TABLE `settings_events` (
  `settings_events_name` varchar(100) NOT NULL,
  `settings_events_enabled` varchar(5) NOT NULL default 'yes'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `settings_general`;
CREATE TABLE `settings_general` (
  `settings_id` varchar(30) NOT NULL default 'default',
  `language` varchar(50) NOT NULL default 'english',
  `theme` varchar(50) NOT NULL default 'default',
  `date_format` varchar(30) NOT NULL default 'm-d-Y',
  `results_limit` smallint(6) NOT NULL default '25',
  `messages_limit` smallint(6) NOT NULL default '10',
  `timeline_limit` smallint(6) NOT NULL default '25',
  `currency_symbol` varchar(10) NOT NULL default '$',
  `currency_code` varchar(20) NOT NULL default 'USD',
  `dashboard_title` varchar(250) NOT NULL default 'Project Manager',
  `show_information_tips` varchar(10) NOT NULL default 'yes' COMMENT 'yes/no',
  `client_registration` varchar(10) NOT NULL default 'yes' COMMENT 'yes/no',
  `notifications_display_duration` int(11) NOT NULL default '350',
  `product_purchase_code` varchar(100) default NULL,
  `restore_language` varchar(50) NOT NULL default 'english',
  `restore_theme` varchar(50) NOT NULL default 'default',
  `restore_date_format` varchar(30) NOT NULL default 'm-d-Y',
  `restore_results_limit` smallint(6) NOT NULL default '25',
  `restore_messages_limit` smallint(6) NOT NULL default '10',
  `restore_timeline_limit` smallint(6) NOT NULL default '25',
  `restore_currency_code` varchar(20) NOT NULL default 'USD',
  `restore_currency_symbol` varchar(10) NOT NULL default '$',
  `restore_dashboard_title` varchar(100) NOT NULL default 'Project Manager',
  `restore_show_information_tips` varchar(10) NOT NULL default 'yes',
  `restore_notifications_display_duration` int(11) NOT NULL default '350',
  `restore_client_registration` varchar(10) NOT NULL default 'yes',
  `restore_product_purchase_code` varchar(100) default NULL,
  UNIQUE KEY `settings_id` (`settings_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `settings_general` (`settings_id`, `language`, `theme`, `date_format`, `results_limit`, `messages_limit`, `timeline_limit`, `currency_symbol`, `currency_code`, `dashboard_title`, `show_information_tips`, `client_registration`, `notifications_display_duration`, `product_purchase_code`, `restore_language`, `restore_theme`, `restore_date_format`, `restore_results_limit`, `restore_messages_limit`, `restore_timeline_limit`, `restore_currency_code`, `restore_currency_symbol`, `restore_dashboard_title`, `restore_show_information_tips`, `restore_notifications_display_duration`, `restore_client_registration`, `restore_product_purchase_code`) VALUES
('default',	'english',	'default',	'd-m-Y',	25,	10,	100,	'$',	'USD',	'Project Dashboard',	'yes',	'yes',	4500,	NULL,	'english',	'default',	'm-d-Y',	25,	10,	100,	'USD',	'$',	'Project Dashboard',	'yes',	4500,	'yes',	NULL);

DROP TABLE IF EXISTS `settings_invoices`;
CREATE TABLE `settings_invoices` (
  `settings_id` varchar(30) NOT NULL,
  `settings_invoices_notes` text,
  `settings_invoices_allow_partial_payment` varchar(10) default 'yes' COMMENT 'yes/no',
  `settings_invoices_email_overdue_reminder` varchar(10) default 'yes' COMMENT 'yes/no',
  UNIQUE KEY `settings_id` (`settings_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `settings_invoices` (`settings_id`, `settings_invoices_notes`, `settings_invoices_allow_partial_payment`, `settings_invoices_email_overdue_reminder`) VALUES
('default',	'Payment is due upon receipt of the invoice. Thank you for your business.',	'yes',	'yes');

DROP TABLE IF EXISTS `settings_paypal`;
CREATE TABLE `settings_paypal` (
  `settings_id` varchar(20) NOT NULL COMMENT 'This Table: Has 1 default record (settings_id = default)',
  `paypal_active` varchar(10) default 'no' COMMENT 'yes/no',
  `paypal_email_address` varchar(150) default 'USD',
  `paypal_currency` varchar(10) default NULL,
  `paypal_ipn_url` varchar(250) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `settings_paypal` (`settings_id`, `paypal_active`, `paypal_email_address`, `paypal_currency`, `paypal_ipn_url`) VALUES
('default',	'yes',	'paypal@somdomain.ccc',	'USD',	NULL);

DROP TABLE IF EXISTS `system_events`;
CREATE TABLE `system_events` (
  `id` int(11) NOT NULL auto_increment,
  `system_events_id` varchar(40) NOT NULL,
  `system_events_project_id` varchar(40) NOT NULL,
  `system_events_date` datetime NOT NULL,
  `events_item` varchar(100) NOT NULL COMMENT 'client,cron,invoice',
  `events_action` varchar(100) NOT NULL,
  `events_user_id` int(11) default NULL,
  `event_user_type` varchar(30) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `tasks`;
CREATE TABLE `tasks` (
  `tasks_id` int(11) NOT NULL auto_increment,
  `tasks_milestones_id` int(11) NOT NULL,
  `tasks_project_id` int(11) NOT NULL,
  `tasks_client_id` int(11) NOT NULL,
  `tasks_assigned_to_id` int(11) NOT NULL,
  `tasks_text` varchar(250) NOT NULL,
  `tasks_start_date` date NOT NULL,
  `tasks_end_date` date NOT NULL,
  `tasks_created_by_id` int(11) NOT NULL,
  `tasks_status` varchar(50) NOT NULL default 'pending' COMMENT 'pending/completed/behind schedule',
  `tasks_events_id` varchar(40) default NULL,
  PRIMARY KEY  (`tasks_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `team_messages_replies`;
CREATE TABLE `team_messages_replies` (
  `messages_replies_id` int(11) NOT NULL auto_increment,
  `messages_replies_project_id` int(11) NOT NULL,
  `messages_replies_message_id` int(11) NOT NULL,
  `messages_replies_date` datetime NOT NULL,
  `messages_replies_text` text NOT NULL,
  `messages_replies_by_id` int(11) NOT NULL,
  PRIMARY KEY  (`messages_replies_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `team_notes`;
CREATE TABLE `team_notes` (
  `team_notes_id` int(11) NOT NULL auto_increment,
  `team_notes_project_id` int(11) NOT NULL,
  `team_notes_by_id` int(11) NOT NULL,
  `team_notes_date` datetime NOT NULL,
  `team_notes_notes` text NOT NULL,
  PRIMARY KEY  (`team_notes_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `team_profile`;
CREATE TABLE `team_profile` (
  `team_profile_id` int(11) NOT NULL auto_increment COMMENT 'This table: Has 1 default row with placeholder admin',
  `team_profile_groups_id` int(11) NOT NULL,
  `team_profile_uniqueid` varchar(20) character set utf8 collate utf8_bin default NULL,
  `team_profile_avatar_filename` varchar(30) character set utf8 collate utf8_bin default NULL,
  `team_profile_full_name` varchar(50) NOT NULL,
  `team_profile_job_position_title` varchar(50) default NULL,
  `team_profile_email` varchar(75) NOT NULL,
  `team_profile_password` varchar(50) character set utf8 collate utf8_bin NOT NULL default 'case sensitive utf8_bin',
  `team_profile_telephone` varchar(50) character set utf8 collate utf8_bin default NULL,
  `team_profile_reset_code` varchar(50) character set utf8 collate utf8_bin default NULL,
  `team_profile_reset_timestamp` datetime default NULL,
  `team_profile_notifications_system` varchar(10) character set utf8 collate utf8_bin default 'yes' COMMENT 'yes/no',
  `team_profile_last_active` datetime default NULL,
  `team_profile_notify_file_added` varchar(5) character set utf8 collate utf8_bin default 'yes',
  `team_profile_notify_milestone_added` varchar(5) character set utf8 collate utf8_bin default 'yes',
  `team_profile_notify_milestone_completed` varchar(5) character set utf8 collate utf8_bin default 'yes',
  `team_profile_notify_file_message_added` varchar(5) character set utf8 collate utf8_bin default 'yes',
  `team_profile_notify_message_added` varchar(5) character set utf8 collate utf8_bin default 'yes',
  `team_profile_notify_team_message_added` varchar(5) character set utf8 collate utf8_bin default 'yes',
  `team_profile_notify_invoice_added` varchar(5) character set utf8 collate utf8_bin default 'no',
  `team_profile_notify_payment_received` varchar(5) character set utf8 collate utf8_bin default 'no',
  PRIMARY KEY  (`team_profile_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `team_profile` (`team_profile_id`, `team_profile_groups_id`, `team_profile_uniqueid`, `team_profile_avatar_filename`, `team_profile_full_name`, `team_profile_job_position_title`, `team_profile_email`, `team_profile_password`, `team_profile_telephone`, `team_profile_reset_code`, `team_profile_reset_timestamp`, `team_profile_notifications_system`, `team_profile_last_active`, `team_profile_notify_file_added`, `team_profile_notify_milestone_added`, `team_profile_notify_milestone_completed`, `team_profile_notify_file_message_added`, `team_profile_notify_message_added`, `team_profile_notify_team_message_added`, `team_profile_notify_invoice_added`, `team_profile_notify_payment_received`) VALUES
(1,	1,	'3Hgd72sjdg728',	NULL,	'John Doe',	'Manager',	'john@doe.ccc',	'1a1dc91c907325c69271ddf0c944bc72',	'(000)-000-000-000',	NULL,	NULL,	'yes',	NULL,	'yes',	'yes',	'yes',	'yes',	'yes',	'yes',	'yes',	'yes');

DROP TABLE IF EXISTS `tickets`;
CREATE TABLE `tickets` (
  `tickets_id` int(11) NOT NULL auto_increment,
  `tickets_department_id` int(11) NOT NULL,
  `tickets_assigned_to_id` int(11) NOT NULL default '0' COMMENT 'un-assigned tickets have ''0'' value',
  `tickets_date` datetime NOT NULL,
  `tickets_title` varchar(250) NOT NULL,
  `tickets_message` text NOT NULL,
  `tickets_client_id` int(11) NOT NULL,
  `tickets_by_user_id` int(11) NOT NULL,
  `tickets_by_user_type` varchar(20) NOT NULL COMMENT 'client/team',
  `tickets_last_active_date` datetime NOT NULL,
  `tickets_status` varchar(20) NOT NULL default 'new' COMMENT 'new/answered/client-replied/closed',
  `tickets_file_name` varchar(250) default NULL,
  `tickets_file_folder` varchar(250) default NULL,
  `tickets_file_size` varchar(250) default NULL,
  `tickets_file_extension` varchar(250) default NULL,
  `tickets_has_attachment` varchar(250) default 'no',
  PRIMARY KEY  (`tickets_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `tickets_departments`;
CREATE TABLE `tickets_departments` (
  `department_id` int(11) NOT NULL auto_increment COMMENT 'This Table: Has 1 default row. General Support department',
  `department_name` varchar(100) NOT NULL,
  `department_description` text NOT NULL,
  PRIMARY KEY  (`department_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `tickets_departments` (`department_id`, `department_name`, `department_description`) VALUES
(1,	'General Support',	'none');

DROP TABLE IF EXISTS `tickets_mailer`;
CREATE TABLE `tickets_mailer` (
  `tickets_mailer_id` int(11) NOT NULL COMMENT 'default',
  `tickets_mailer_enabled` varchar(50) default 'no' COMMENT 'yes/no',
  `tickets_mailer_delete_read` varchar(50) default 'yes' COMMENT 'yes/no',
  `tickets_mailer_imap_pop` varchar(50) default 'IMAP' COMMENT 'IMAP/POP',
  `tickets_mailer_ssl` varchar(50) default 'no' COMMENT 'yes/no',
  `tickets_mailer_email_address` varchar(100) default NULL,
  `tickets_mailer_server` varchar(100) default 'localhost',
  `tickets_mailer_server_port` varchar(50) default '143',
  `tickets_mailer_username` varchar(100) default NULL,
  `tickets_mailer_password` varchar(250) default NULL,
  `tickets_mailer_flags` varchar(250) default NULL,
  `tickets_mailer_imap_settings` varchar(250) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `tickets_mailer` (`tickets_mailer_id`, `tickets_mailer_enabled`, `tickets_mailer_delete_read`, `tickets_mailer_imap_pop`, `tickets_mailer_ssl`, `tickets_mailer_email_address`, `tickets_mailer_server`, `tickets_mailer_server_port`, `tickets_mailer_username`, `tickets_mailer_password`, `tickets_mailer_flags`, `tickets_mailer_imap_settings`) VALUES
(0,	'no',	'no',	'IMAP',	'no',	'foo@somadomain.ccc',	'mail.foobar.com',	'100',	'foo',	'bar',	'NONE',	'CODE');

DROP TABLE IF EXISTS `tickets_replies`;
CREATE TABLE `tickets_replies` (
  `tickets_replies_id` int(11) NOT NULL auto_increment,
  `tickets_replies_ticket_id` int(11) NOT NULL default '0' COMMENT 'un-assigned ticket_replies have ''0'' value',
  `tickets_replies_date` datetime NOT NULL,
  `tickets_replies_message` text NOT NULL,
  `tickets_replies_by_user_id` int(11) NOT NULL,
  `tickets_replies_by_user_type` varchar(20) NOT NULL COMMENT 'client/team',
  `tickets_replies_file_name` varchar(250) default NULL,
  `tickets_replies_file_folder` varchar(250) default NULL,
  `tickets_replies_file_size` varchar(250) default NULL,
  `tickets_replies_file_extension` varchar(250) default NULL,
  `tickets_replies_has_attachment` varchar(250) default 'no',
  PRIMARY KEY  (`tickets_replies_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `timer`;
CREATE TABLE `timer` (
  `timer_id` int(11) NOT NULL auto_increment,
  `timer_project_id` int(11) NOT NULL,
  `timer_start_datetime` datetime default NULL,
  `timer_seconds` int(11) default '0',
  `timer_team_member_id` int(11) default NULL,
  `timer_status` varchar(30) default 'stopped' COMMENT 'running/stopped',
  PRIMARY KEY  (`timer_id`),
  UNIQUE KEY `unique_timer` (`timer_project_id`,`timer_team_member_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `version`;
CREATE TABLE `version` (
  `id` varchar(30) character set latin1 NOT NULL COMMENT 'This table: Has 1 default row after installation or update',
  `version` varchar(20) character set latin1 NOT NULL,
  `date_installed` datetime NOT NULL,
  `install_type` varchar(20) character set latin1 NOT NULL COMMENT 'new/update'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- ADDED V1.02
DROP TABLE IF EXISTS `settings_bank`;
CREATE TABLE `settings_bank` (
  `settings_id` varchar(20) NOT NULL,
  `bank_active` varchar(20) NOT NULL COMMENT 'yes/no',
  `settings_bank_details` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `settings_bank` (`settings_id`, `bank_active`, `settings_bank_details`) VALUES
('default',	'no',	'To make a bank transfer, please use the following banking details<br />\n<br />\n<strong>Bank Name:</strong> bank pvt ltd<br />\n<strong>Bank Address:</strong> 1 some road, some city, some country<br />\n<strong>Account Number:</strong> 000-000-000-000<br />\n<strong>Sort Code:</strong> 000-000<br />\n<strong>Swift Code:</strong> XYZ-00-0-00<br />\n<br />\nOnce your payment has been received, your invoice will be updated.<br />\n&nbsp;');


-- ADDED V1.02
DROP TABLE IF EXISTS `settings_cash`;
CREATE TABLE `settings_cash` (
  `settings_id` varchar(20) NOT NULL,
  `cash_active` varchar(10) NOT NULL COMMENT 'yes/no',
  `settings_cash_details` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `settings_cash` (`settings_id`, `cash_active`, `settings_cash_details`) VALUES
('default',	'yes',	'Once you have made your cash payment please advise us so that your invoice can be updated.');


-- UPDATED V1.02
DROP TABLE IF EXISTS `settings_payment_methods`;
CREATE TABLE `settings_payment_methods` (
  `settings_payment_methods_name` varchar(100) NOT NULL COMMENT 'Unique ID: Also used in PAYMENTS table ''payments_method'' to identify payment method',
  `settings_payment_methods_status` varchar(20) NOT NULL COMMENT 'enabled/disabled'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `settings_payment_methods` (`settings_payment_methods_name`, `settings_payment_methods_status`) VALUES
('Paypal',	'enabled'),
('Cash',	'enabled'),
('Bank',	'disabled');

-- UPDATED V1.03
DROP TABLE IF EXISTS `team_messages`;
CREATE TABLE `team_messages` (
  `messages_id` int(11) NOT NULL auto_increment,
  `messages_project_id` int(11) NOT NULL,
  `messages_date` datetime NOT NULL,
  `messages_text` text NOT NULL,
  `messages_by_id` int(11) NOT NULL,
  PRIMARY KEY  (`messages_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ADDED V1.04
DROP TABLE IF EXISTS `mynotes`;
CREATE TABLE `mynotes` (
  `mynotes_id` int(11) NOT NULL auto_increment,
  `mynotes_project_id` int(11) NOT NULL,
  `mynotes_team_id` int(11) NOT NULL,
  `mynotes_last_edited` datetime NOT NULL,
  `mynotes_text` text,
  PRIMARY KEY  (`mynotes_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- UPDATED V1.04 (email notifications)
DROP TABLE IF EXISTS `client_users`;
CREATE TABLE `client_users` (
  `client_users_id` int(11) NOT NULL auto_increment COMMENT 'This Table: Has no default data',
  `client_users_clients_id` int(11) NOT NULL,
  `client_users_uniqueid` varchar(20) default NULL,
  `client_users_avatar_filename` varchar(150) default NULL,
  `client_users_full_name` varchar(75) NOT NULL,
  `client_users_job_position_title` varchar(50) default NULL,
  `client_users_email` varchar(75) NOT NULL,
  `client_users_password` varchar(50) character set utf8 collate utf8_bin NOT NULL COMMENT 'case sensitive utf8_bin',
  `client_users_telephone` varchar(50) default NULL,
  `client_users_main_contact` varchar(5) NOT NULL default 'no' COMMENT 'yes/no',
  `client_users_reset_code` varchar(50) default NULL,
  `client_users_reset_timestamp` datetime default NULL,
  `client_users_last_active` datetime default NULL,
  `client_users_file_added` varchar(5) default 'yes',
  `client_users_milestone_added` varchar(5) default 'yes',
  `client_users_milestone_completed` varchar(5) default 'yes',
  `client_users_message_added` varchar(5) default 'yes',
  `client_users_file_message_added` varchar(5) default 'yes',
  `client_users_invoice_added` varchar(5) default 'yes',
  `client_notifications_system` varchar(5) default 'yes',
  PRIMARY KEY  (`client_users_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ADDED V1.04 (email queue)
DROP TABLE IF EXISTS `email_queue`;
CREATE TABLE `email_queue` (
  `email_queue_id` int(11) NOT NULL auto_increment,
  `email_queue_email` varchar(100) NOT NULL,
  `email_queue_subject` varchar(250) NOT NULL,
  `email_queue_message` text NOT NULL,
  `email_queue_date` datetime NOT NULL,
  PRIMARY KEY  (`email_queue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- UPDATES V1.04 (new team member email template)
DROP TABLE IF EXISTS `settings_emailtemplates`;
CREATE TABLE `settings_emailtemplates` (
  `id` int(11) NOT NULL auto_increment,
  `settings_id` varchar(50) NOT NULL,
  `title` varchar(100) NOT NULL,
  `subject` varchar(250) NOT NULL,
  `message` text NOT NULL,
  `restore_subject` varchar(250) NOT NULL COMMENT 'restore data',
  `restore_message` text NOT NULL COMMENT 'restore data',
  `variables` text NOT NULL COMMENT 'available vars',
  `type` varchar(10) NOT NULL COMMENT 'admin/client',
  `DELETE_POST_DEV` text NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `settings_id` (`settings_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `settings_emailtemplates` (`id`, `settings_id`, `title`, `subject`, `message`, `restore_subject`, `restore_message`, `variables`, `type`, `DELETE_POST_DEV`) VALUES
(3,	'new_client_welcome_client',	'lang_new_client',	'Project Dashboard - Welcome ',	'<div style=\"height:7px; background-color:#535353\">&nbsp;</div>\n\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Welcome<br />\n[var.clients_company_name]</div>\n\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span style=\"font-weight:bold;\">[var.client_users_full_name]</span><br />\n<br />\nYour company has just been added to our Project Management Dashboard.<br />\n<br />\nBelow are your primary users login details.<br />\n<br />\nRemember, you can easily add more users to your company account via the Dashboard.<br />\n&nbsp;\n<table cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\" width=\"100%\">\n <tbody>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"150\">Username</td>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"276\">[var.client_users_email]</td>\n  </tr>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\">Password</td>\n   <td style=\"border: 1px solid #DDDDDD;\">[var.client_users_password]</td>\n  </tr>\n </tbody>\n</table>\n&nbsp;\n\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.client_dashboard_url]\">[var.client_dashboard_url]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>\n',	'Project Dashboard - Welcome ',	'<div style=\"height:7px; background-color:#535353\">&nbsp;</div>\n\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Welcome<br />\n[var.clients_company_name]</div>\n\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span style=\"font-weight:bold;\">[var.client_users_full_name]</span><br />\n<br />\nYour company has just been added to our Project Management Dashboard.<br />\n<br />\nBelow are your primary users login details.<br />\n<br />\nRemember, you can easily add more users to your company account via the Dashboard.<br />\n&nbsp;\n<table cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\" width=\"100%\">\n	<tbody>\n		<tr>\n			<td style=\"border: 1px solid #DDDDDD;\" width=\"150\">Username</td>\n			<td style=\"border: 1px solid #DDDDDD;\" width=\"276\">[var.client_users_email]</td>\n		</tr>\n		<tr>\n			<td style=\"border: 1px solid #DDDDDD;\">Password</td>\n			<td style=\"border: 1px solid #DDDDDD;\">[var.client_users_password]</td>\n		</tr>\n	</tbody>\n</table>\n&nbsp;\n\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.client_dashboard_url]\">[var.client_dashboard_url]</a></span></div>\n\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'[var.clients_company_name], [var.client_users_full_name], [var.client_users_email], [var.client_users_password], [var.todays_date], [var.company_email_signature], [var.client_dashboard_url]',	'client',	''),
(4,	'new_invoice_client',	'lang_new_invoice',	'New Invoice',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">INVOICE</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">[var.client_users_full_name]<br />\n</span></span><br /> \n  Please find attched your invoice. You can download the attachment and print it for your records.<br>\n  <br>\n  You can also log into the control panel and manage/pay the invoice.<br />\n  <br />\n  <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Invoice Payment Link </strong><span style=\"font-size:14px;\"><a href=\"[var.client_dashboard_url]\">[var.client_dashboard_url]</a></span><br>\n    <br>\n  [var.invoice_standard_terms]</div>\n  <br>\n  Thank you for your prompt payment<br>\n  <br />\n[var.company_email_signature]\n</div>\n</div>',	'New Invoice',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">INVOICE</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">[var.client_users_full_name]<br />\n</span></span><br /> \n  Please find attched your invoice. You can download the attachment and print it for your records.<br>\n  <br>\n  You can also log into the control panel and manage/pay the invoice.<br />\n  <br />\n  <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Invoice Payment Link </strong><span style=\"font-size:14px;\"><a href=\"[var.client_dashboard_url]\">[var.client_dashboard_url]</a></span><br>\n    <br>\n  [var.invoice_standard_terms]</div>\n  <br>\n  Thank you for your prompt payment<br>\n  <br />\n[var.company_email_signature]\n</div>\n</div>',	'[var.client_users_full_name],[var.company_name], [var.clients_company_name], [var.company_email_signature], [var.todays_date], [var.client_dashboard_url], [var.invoices_id]',	'client',	''),
(5,	'overdue_invoice_client',	'lang_overdue_invoice',	'Overdue Invoice',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">OVERDUE INVOICE</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">[var.client_users_full_name]<br />\n</span></span><br /> \n  This is a notice that an invoice that was generated on<strong> [var.invoices_date] </strong>is now overdue<br />\n  <br />\n  Invoice Details:<br />\n  <br />\n  <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n    <tr>\n      <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Invoice Date</td>\n<td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.invoices_date]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Invoice Invoice Due Date</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.invoices_due_date]</td>\n    </tr>\n    <tr>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>Invoice Amount</strong></td>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>[var.currency_symbol][var.invoices_amount]</strong></td>\n    </tr>\n  </table>\n  <br />\n  Please kindly make payment using the link below<br />\n  <br />\n  <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Invoice Payment Link </strong><span style=\"font-size:14px;\"><a href=\"[var.invoice_payment_link]\">[var.invoice_payment_link]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'Overdue Invoice',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">OVERDUE INVOICE</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">[var.client_users_full_name]<br />\n</span></span><br /> \n  This is a notice that an invoice that was generated on<strong> [var.invoices_date] </strong>is now overdue<br />\n  <br />\n  Invoice Details:<br />\n  <br />\n  <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n    <tr>\n      <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Invoice Date</td>\n<td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.invoices_date]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Invoice Invoice Due Date</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.invoices_due_date]</td>\n    </tr>\n    <tr>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>Invoice Amount</strong></td>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>[var.currency_symbol][var.invoices_amount]</strong></td>\n    </tr>\n  </table>\n  <br />\n  Please kindly make payment using the link below<br />\n  <br />\n  <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Invoice Payment Link </strong><span style=\"font-size:14px;\"><a href=\"[var.invoice_payment_link]\">[var.invoice_payment_link]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'[var.client_users_full_name], [var.invoices_date], [var.invoices_due_date], [var.currency_symbol], [var.invoices_amount], [var.invoice_payment_link], [var.company_name], [var.clients_company_name], [var.company_email_signature], [var.todays_date], [var.client_dashboard_url], [var.project_link], [var.invoices_id]',	'client',	''),
(6,	'new_project_client',	'lang_new_project',	'New Project Created',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">NEW PROJECT</div>\n<div style=\"text-align:center; font-size:24px; font-weight:bold; color:#535353;\">[var.projects_title]</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">[var.client_users_full_name]<br />\n</span></span><br /> \n  A new project has been added to your Project Dashboard.\n  <br />\n  <br />\n  <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n    <tr>\n      <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Project Title</td>\n<td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.projects_title]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Date Created</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.projects_date_created]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Anticipated Completion Date</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.project_deadline]</td>\n    </tr>\n    <tr>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>Project ID</strong></td>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>[var.projects_id]</strong></td>\n    </tr>\n  </table>\n  <br />\n  You can \n  login to the Project Dashboard to keep manage and keep track of this project<br />\n  <br />\n  <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong> Direct Link </strong><span style=\"font-size:14px;\"><a href=\"[var.str_project_link]\">[var.str_project_link]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'New Project Created',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">NEW PROJECT</div>\n<div style=\"text-align:center; font-size:24px; font-weight:bold; color:#535353;\">[var.projects_title]</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">[var.client_users_full_name]<br />\n</span></span><br /> \n  A new project has been added to your Project Dashboard.\n  <br />\n  <br />\n  <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n    <tr>\n      <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Project Title</td>\n<td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.projects_title]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Date Created</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.projects_date_created]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Anticipated Completion Date</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.project_deadline]</td>\n    </tr>\n    <tr>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>Project ID</strong></td>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>[var.projects_id]</strong></td>\n    </tr>\n  </table>\n  <br />\n  You can \n  login to the Project Dashboard to keep manage and keep track of this project<br />\n  <br />\n  <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong> Direct Link </strong><span style=\"font-size:14px;\"><a href=\"[var.str_project_link]\">[var.str_project_link]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'[var.clients_company_name], [var.client_users_full_name], [var.todays_date], [var.company_email_signature], [var.client_dashboard_url], [var.projects_title], [var.projects_date_created], [var.project_deadline], [var.project_link]',	'client',	''),
(7,	'general_notification_client',	'lang_general_notification',	'Project Notification',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">  [var.email_title]</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span style=\"font-weight:bold;\">[var.addressed_to]<br />\n</span><br /> \n  [var.email_message]<br />\n  <br />\n  <br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.client_dashboard_url]\">[var.client_dashboard_url]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'Project Notification',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">  [var.email_title]</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span style=\"font-weight:bold;\">[var.addressed_to]<br />\n</span><br /> \n  [var.email_message]<br />\n  <br />\n  <br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.client_dashboard_url]\">[var.client_dashboard_url]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'[var.company_email_signature], [var.todays_date], [var.client_dashboard_url], [var.notification_message]',	'client',	'completed & tested'),
(10,	'new_user_client',	'lang_new_user',	'Dashboard Login Details',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Dashboard Login Details</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span style=\"font-weight:bold;\">[var.client_users_full_name]<br />\n</span><br /> \n  You have just been added to the Project Dashboard<br />\n  <br />\n  Below are your users login details<br />\n<br>\n<table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n    <tr>\n      <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Username</td>\n      <td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.client_users_email]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Password</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.client_users_password]</td>\n    </tr>\n  </table>\n<br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.client_dashboard_url]\">[var.client_dashboard_url]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'Dashboard Login Details',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Dashboard Login Details</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span style=\"font-weight:bold;\">[var.client_users_full_name]<br />\n</span><br /> \n  You have just been added to the Project Dashboard<br />\n  <br />\n  Below are your users login details<br />\n<br>\n<table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n    <tr>\n      <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Username</td>\n      <td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.client_users_email]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Password</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.client_users_password]</td>\n    </tr>\n  </table>\n<br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.client_dashboard_url]\">[var.client_dashboard_url]</a></span></div>\n<br />\n[var.company_email_signature]\n</div>\n</div>',	'[var.client_users_email], [var.client_users_password], [var.clients_company_name], [var.company_email_signature], [var.str_todays_date], [var.str_client_dashboard_url]',	'client',	'completed & tested'),
(11,	'general_notification_admin',	'lang_general_notification',	'Project Notification',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">  [var.email_title]</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span style=\"font-weight:bold;\">[var.addressed_to]<br />\n</span><br /> \n  [var.email_message]<br />\n  <br />\n  <br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a></span></div>\n<br />\n</div>\n</div>',	'Project Notification',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">  [var.email_title]</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span style=\"font-weight:bold;\">[var.addressed_to]<br />\n</span><br /> \n  [var.email_message]<br />\n  <br />\n  <br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a></span></div>\n<br />\n</div>\n</div>',	'[var.company_email_signature], [var.todays_date], [var.client_dashboard_url], [var.notification_message]',	'admin',	''),
(13,	'new_client_admin',	'lang_new_client',	'New Client Added',	'<div style=\"height:7px; background-color:#535353\">&nbsp;</div>\n\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">New Client</div>\n\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\">Hello,<br />\n<br />\nA new client has just been added to the Project Management Dashboard<br />\n&nbsp;\n<table cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\" width=\"100%\">\n <tbody>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"150\">Username</td>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"276\">[var.client_users_email]</td>\n  </tr>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\">Company Name</td>\n   <td style=\"border: 1px solid #DDDDDD;\">[var.clients_company_name]</td>\n  </tr>\n </tbody>\n</table>\n&nbsp;\n\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a></div><br />\n[var.company_email_signature]\n</div>\n</div>',	'New Client Added',	'<div style=\"height:7px; background-color:#535353\">&nbsp;</div>\n\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">New Client</div>\n\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\">Hello,<br />\n<br />\nA new client has just been added to the Project Management Dashboard<br />\n&nbsp;\n<table cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\" width=\"100%\">\n <tbody>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"150\">Username</td>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"276\">[var.client_users_email]</td>\n  </tr>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\">Company Name</td>\n   <td style=\"border: 1px solid #DDDDDD;\">[var.clients_company_name]</td>\n  </tr>\n </tbody>\n</table>\n&nbsp;\n\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a></div><br />\n[var.company_email_signature]\n</div>\n</div>',	'[var.clients_company_name], [var.client_users_full_name], [var.client_users_email], [var.client_users_password], [var.company_email_signature], [var.todays_date], [var.admin_dashboard_url]',	'admin',	''),
(15,	'new_project_admin',	'lang_new_project',	'New Project Created',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">NEW PROJECT</div>\n<div style=\"text-align:center; font-size:24px; font-weight:bold; color:#535353;\">[var.projects_title]</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\"> [var.team_profile_full_name]<br />\n</span></span><br /> \n  A new project has been added to the Project Dashboard<br />\n  <br />\n  <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n    <tr>\n      <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Project Title</td>\n<td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.projects_title]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Date Created</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.projects_date_created]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Anticipated Completion Date</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.project_deadline]</td>\n    </tr>\n    <tr>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>Project ID</strong></td>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>[var.projects_id]</strong></td>\n    </tr>\n  </table>\n  <br />\n  <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong> Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a></span></div><br />\n[var.company_email_signature]\n</div>\n</div>',	'New Project Created',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">NEW PROJECT</div>\n<div style=\"text-align:center; font-size:24px; font-weight:bold; color:#535353;\">[var.projects_title]</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\"> [var.team_profile_full_name]<br />\n</span></span><br /> \n  A new project has been added to the Project Dashboard<br />\n  <br />\n  <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n    <tr>\n      <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Project Title</td>\n<td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.projects_title]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Date Created</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.projects_date_created]</td>\n    </tr>\n    <tr>\n      <td style=\"border: 1px solid #DDDDDD;\">Anticipated Completion Date</td>\n      <td style=\"border: 1px solid #DDDDDD;\">[var.project_deadline]</td>\n    </tr>\n    <tr>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>Project ID</strong></td>\n      <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\"><strong>[var.projects_id]</strong></td>\n    </tr>\n  </table>\n  <br />\n  <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong> Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a></span></div><br />\n[var.company_email_signature]\n</div>\n</div>',	'[var.clients_company_name], [var.client_users_full_name], [var.todays_date], [var.company_email_signature], [var.client_dashboard_url], [var.projects_title], [var.projects_date_created], [var.project_deadline], [var.project_link], [var.team_profile_full_name]',	'admin',	''),
(16,	'new_user_admin',	'lang_new_user',	'New Client User',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n  <div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">New Client User</div>\n  <div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"> A new Client User  has just been added to the Project Dashboard<br />\n    <br />\n    Below are the user\'s login details<br />\n    <br>\n    <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n      <tr>\n        <td style=\"border: 1px solid #DDDDDD;\">Client Name</td>\n        <td style=\"border: 1px solid #DDDDDD;\">[var.clients_company_name]</td>\n      </tr>\n      <tr>\n        <td style=\"border: 1px solid #DDDDDD;\">New Users Name</td>\n        <td style=\"border: 1px solid #DDDDDD;\">[var.client_users_full_name]</td>\n      </tr>\n      <tr>\n        <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">New Users Email</td>\n        <td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.client_users_email]</td>\n      </tr>\n    </table>\n    <br>\n    <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a> </div>\n  </div>\n</div>',	'Dashboard Login Details',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n  <div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">New Client User</div>\n  <div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"> A new Client User  has just been added to the Project Dashboard<br />\n    <br />\n    Below are the user\'s login details<br />\n    <br>\n    <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n      <tr>\n        <td style=\"border: 1px solid #DDDDDD;\">Client Name</td>\n        <td style=\"border: 1px solid #DDDDDD;\">[var.clients_company_name]</td>\n      </tr>\n      <tr>\n        <td style=\"border: 1px solid #DDDDDD;\">New Users Name</td>\n        <td style=\"border: 1px solid #DDDDDD;\">[var.client_users_full_name]</td>\n      </tr>\n      <tr>\n        <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">New Users Email</td>\n        <td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.client_users_email]</td>\n      </tr>\n    </table>\n    <br>\n    <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a> </div>\n  </div>\n</div>',	'[var.client_users_email], [var.clients_company_name], [var.client_users_name], [var.company_email_signature], [var.str_todays_date], [var.str_client_dashboard_url]',	'admin',	'completed & tested'),
(17,	'password_reset_client',	'lang_reset_password',	'Reset Password',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Password Reset</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">Hello [var.client_users_full_name]<br />\n</span></span><br /> \n  You have requeste to reset your password. You can reset you password using the link below.<br />\n  <br />\n  This link will expire after <strong>30 Minutes</strong>.<br />\n  <br />\n  If you have not requested this email please notify us.<br />\n<br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Password reset link: </strong><span style=\"font-size:14px;\"><a href=\"[var.password_reset_link]\">[var.password_reset_link]</a>\n</div><br />\n[var.company_email_signature]\n</div></div>',	'Reset Password',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Password Reset</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">Hello [var.client_users_full_name]<br />\n</span></span><br /> \n  You have requeste to reset your password. You can reset you password using the link below.<br />\n  <br />\n  This link will expire after <strong>30 Minutes</strong>.<br />\n  <br />\n  If you have not requested this email please notify us.<br />\n<br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Password reset link: </strong><span style=\"font-size:14px;\"><a href=\"[var.password_reset_link]\">[var.password_reset_link]</a>\n</div><br />\n[var.company_email_signature]\n</div></div>',	'[var.password_reset_link], [var.company_email_signature], [var.str_todays_date], [var.str_client_dashboard_url], [var.client_users_full_name]',	'client',	'completed & tested'),
(18,	'password_reset_admin',	'lang_reset_password',	'Reset Password',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Password Reset</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">[var.team_profile_full_name]<br />\n</span></span><br /> \n  You have requeste to reset your password. You can reset you password using the link below.<br />\n  <br />\n  This link will expire after <strong>30 Minutes</strong>.<br />\n  <br />\n  If you have not requested this email please notify us.<br />\n<br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Password reset link: </strong><span style=\"font-size:14px;\"><a href=\"[var.password_reset_link]\">[var.password_reset_link]</a>\n</div><br />\n    [var.company_email_signature]\n</div></div>',	'Reset Password',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Password Reset</div>\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><span class=\"style1\"><span style=\"font-weight:bold;\">[var.team_profile_full_name]<br />\n</span></span><br /> \n  You have requeste to reset your password. You can reset you password using the link below.<br />\n  <br />\n  This link will expire after <strong>30 Minutes</strong>.<br />\n  <br />\n  If you have not requested this email please notify us.<br />\n<br>\n<div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Password reset link: </strong><span style=\"font-size:14px;\"><a href=\"[var.password_reset_link]\">[var.password_reset_link]</a>\n</div><br />\n    [var.company_email_signature]\n</div></div>',	'[var.password_reset_link], [var.team_profile_full_name], [var.company_email_signature], [var.str_todays_date], [var.str_client_dashboard_url]',	'admin',	''),
(19,	'new_quotation_client',	'lang_new_quotation',	'Your Quotation Request',	'<div style=\"height:7px; background-color:#535353\">&nbsp;</div>\n\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">QUOTATION</div>\n\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><strong>[var.client_users_full_name]</strong><br />\n<br />\nThank you for you for filling in our Quotation Request Form.<br />\n<br />\nPlease find below are our quotation:<br />\n&nbsp;\n<table cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\" width=\"100%\">\n <tbody>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"150\">Quotation Date</td>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"276\">[var.todays_date]</td>\n  </tr>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\">Our Quotation</td>\n   <td style=\"border: 1px solid #DDDDDD;\"><strong>[var.currency_symbol][var.quotation_amount]</strong></td>\n  </tr>\n  <tr>\n   <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\">Addtitional Comments</td>\n   <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\">[var.quotation_notes]</td>\n  </tr>\n </tbody>\n</table>\n<br />\nThank you and we look forward to working with you.<br />\n<br />\n[var.company_email_signature]</div>\n</div>',	'Your Quotation Request',	'<div style=\"height:7px; background-color:#535353\">&nbsp;</div>\n\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">QUOTATION</div>\n\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\"><strong>[var.client_users_full_name]</strong><br />\n<br />\nThank you for you for filling in our Quotation Request Form.<br />\n<br />\nPlease find below are our quotation:<br />\n&nbsp;\n<table cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\" width=\"100%\">\n <tbody>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"150\">Quotation Date</td>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"276\">[var.todays_date]</td>\n  </tr>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\">Our Quotation</td>\n   <td style=\"border: 1px solid #DDDDDD;\"><strong>[var.currency_symbol][var.quotation_amount]</strong></td>\n  </tr>\n  <tr>\n   <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\">Addtitional Comments</td>\n   <td bgcolor=\"#F5F5F5\" style=\"border: 1px solid #DDDDDD;\">[var.quotation_notes]</td>\n  </tr>\n </tbody>\n</table>\n<br />\nThank you and we look forward to working with you.<br />\n<br />\n[var.company_email_signature]</div>\n</div>',	'[var.client_users_full_name],[var.currency_symbol], [var.quotation_amount], [var.quotation_notes],[var.company_email_signature], [var.todays_date], [var.client_dashboard_url]',	'client',	'completed & tested'),
(20,	'new_payment_admin',	'lang_new_payment',	'New Payment Received',	'<div style=\"height:7px; background-color:#535353\">&nbsp;</div>\n\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">New Payment</div>\n\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\">Hello,<br />\n<br />\nA new payment has been made.<br />\n&nbsp;\n<table cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\" width=\"100%\">\n <tbody>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"150\">Client Name</td>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"276\">[var.clients_company_name]</td>\n  </tr>\n  <tr>\n    <td style=\"border: 1px solid #DDDDDD;\">Invoice ID</td>\n    <td style=\"border: 1px solid #DDDDDD;\">[var.invoice_id]</td>\n  </tr>\n  <tr>\n    <td style=\"border: 1px solid #DDDDDD;\">Transaction ID</td>\n    <td style=\"border: 1px solid #DDDDDD;\">[var.transaction_id]</td>\n  </tr>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\">Amount</td>\n   <td style=\"border: 1px solid #DDDDDD;\">[var.amount]</td>\n  </tr>\n  <tr>\n    <td style=\"border: 1px solid #DDDDDD;\">Currency</td>\n    <td style=\"border: 1px solid #DDDDDD;\">[var.currency]</td>\n  </tr>\n </tbody>\n</table>\n</div>\n</div>',	'New Payment Received',	'<div style=\"height:7px; background-color:#535353\">&nbsp;</div>\n\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n<div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">New Payment</div>\n\n<div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\">Hello,<br />\n<br />\nA new payment has been made.<br />\n&nbsp;\n<table cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\" width=\"100%\">\n <tbody>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"150\">Client Name</td>\n   <td style=\"border: 1px solid #DDDDDD;\" width=\"276\">[var.clients_company_name]</td>\n  </tr>\n  <tr>\n    <td style=\"border: 1px solid #DDDDDD;\">Invoice ID</td>\n    <td style=\"border: 1px solid #DDDDDD;\">[var.invoice_id]</td>\n  </tr>\n  <tr>\n    <td style=\"border: 1px solid #DDDDDD;\">Transaction ID</td>\n    <td style=\"border: 1px solid #DDDDDD;\">[var.transaction_id]</td>\n  </tr>\n  <tr>\n   <td style=\"border: 1px solid #DDDDDD;\">Amount</td>\n   <td style=\"border: 1px solid #DDDDDD;\">[var.amount]</td>\n  </tr>\n  <tr>\n    <td style=\"border: 1px solid #DDDDDD;\">Currency</td>\n    <td style=\"border: 1px solid #DDDDDD;\">[var.currency]</td>\n  </tr>\n </tbody>\n</table>\n</div>\n</div>',	'[var.clients_company_name], [var.invoice_id], [var.transaction_id], [var.amount], [var.currency]',	'admin',	''),
(22,	'new_team_member',	'lang_new_team_member',	'Your Dashboard Account Details',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n  <div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Welcome<br>\n  - account details -</div>\n  <div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\">[var.team_profile_full_name]<br />\n    <br />\n    Below are your new Dashboard login details<br />\n    <br>\n    <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n      <tr>\n        <td style=\"border: 1px solid #DDDDDD;\">Username</td>\n        <td style=\"border: 1px solid #DDDDDD;\">[var.team_profile_email]</td>\n      </tr>\n      <tr>\n        <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Password</td>\n        <td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.team_profile_password]</td>\n      </tr>\n    </table>\n    <br>\n    <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a> </div>\n  </div>\n</div>',	'Your Dashboard Account Details',	'<div style=\"height:7px; background-color:#535353\"></div>\n<div style=\"background-color:#f5f5f5; margin:0px; padding:55px 20px 40px 20px; font-family:Helvetica, sans-serif; font-size:13px; color:#535353;\">\n  <div style=\"text-align:center; font-size:34px; font-weight:bold; color:#535353;\">Welcome<br>\n  - account details -</div>\n  <div style=\"border-radius: 5px 5px 5px 5px; padding:20px; margin-top:45px; background-color:#FFFFFF; font-family:Arial, Helvetica, sans-serif; font-size:13px;\">[var.team_profile_full_name]<br />\n    <br />\n    Below are your new Dashboard login details<br />\n    <br>\n    <table width=\"100%\" cellpadding=\"8\" style=\"border: 1px solid #DDDDDD; border-collapse: collapse; border-spacing: 0;font-size:13px;\">\n      <tr>\n        <td style=\"border: 1px solid #DDDDDD;\">Username</td>\n        <td style=\"border: 1px solid #DDDDDD;\">[var.team_profile_email]</td>\n      </tr>\n      <tr>\n        <td width=\"150\" style=\"border: 1px solid #DDDDDD;\">Password</td>\n        <td width=\"276\" style=\"border: 1px solid #DDDDDD;\">[var.team_profile_password]</td>\n      </tr>\n    </table>\n    <br>\n    <div style=\" border:#CCCCCC solid 1px; padding:8px;\"><strong>Dashboard Link </strong><span style=\"font-size:14px;\"><a href=\"[var.admin_dashboard_url]\">[var.admin_dashboard_url]</a> </div>\n  </div>\n</div>',	'[var.team_profile_full_name], [var.team_profile_email],  [var.team_profile_password], [var.company_email_signature], [var.str_todays_date], [var.admin_dashboard_url]',	'admin',	'completed & tested');


-- UPDATES V1.05 (changed vat tax rate, to 2 decimal places)
DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices` (
  `invoices_id` int(11) NOT NULL auto_increment,
  `invoices_custom_id` varchar(150) default NULL,
  `invoices_unique_id` varchar(75) character set utf8 collate utf8_bin NOT NULL,
  `invoices_project_id` int(11) NOT NULL,
  `invoices_clients_id` int(11) NOT NULL,
  `invoices_pretax_amount` decimal(10,2) NOT NULL default '0.00',
  `invoices_tax_amount` decimal(10,2) NOT NULL default '0.00',
  `invoices_amount` decimal(10,2) default '0.00',
  `invoices_tax_rate` decimal(10,2) default '0.00',
  `invoices_date` date NOT NULL,
  `invoices_due_date` date NOT NULL,
  `invoices_status` varchar(30) NOT NULL default 'due' COMMENT 'new/paid/due/partpaid/overdue [new is the status of an unpublished/unsent invoice]',
  `invoices_notes` varchar(250) default NULL,
  `invoices_created_by_id` int(11) default NULL,
  `invoices_times_emailed` int(11) default '0',
  `invoices_last_emailed` date default NULL,
  `invoices_events_id` varchar(40) default NULL,
  PRIMARY KEY  (`invoices_id`),
  UNIQUE KEY `invoices_unique_id` (`invoices_unique_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;