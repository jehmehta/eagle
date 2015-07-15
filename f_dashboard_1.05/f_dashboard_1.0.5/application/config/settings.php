<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/*
|----------------------------------------------------------------------------------------------------
| SECURITY KEY
|----------------------------------------------------------------------------------------------------
|
| This key is used to enhance the security of your site, such as preventing anyone from runing 
| the cronjobs url.
|
| [WARNING]: Change it to something unique (BUT IT MUST BE ALPHA-NUMERIC ONLY)
| 
| [EXAMPLE]: 'Jfhe0j792j66291aph'
|
*/

$config['security_key'] = 'AHusEwFd8HDg630sk';

/*
|----------------------------------------------------------------------------------------------------
| UPLOAD SETTING - AVATARS
|----------------------------------------------------------------------------------------------------
|
| various file upload settings for avatars
| [files_avatar_max_size]      - set to: 0 for no limit OR set to a number (in kilobytes) e.g. 200
| [files_avatar_max_width]     - set to: 0 for no limit OR set to a number (in pixels) e.g. 100
| [files_avatar_max_height]    - set to: 0 for no limit OR set to a number (in pixels) e.g. 100
|
*/
$config['files_avatar_max_size']	= 500;
$config['files_avatar_max_width']	= 150;
$config['files_avatar_max_height']	= 150;


/*
|----------------------------------------------------------------------------------------------------
| UPLOAD SETTING - PROJECT FILES & TICKET ATTACHMENTS
|----------------------------------------------------------------------------------------------------
|
| various file upload settings for avatars
| [files_max_size]       - set to: 0 for no limit OR set to a number (in kilobytes) e.g. 200
| [files_allowed_types]
|                 - $config['files_allowed_types'] = 'msi|exe|bat|jpg|jpeg'; //file extension
|                 - $config['files_allowed_types'] = 0; //allow ALL file types (NOT RECOMENDED)
*/
$config['files_max_size']	= 20000; //in kilobytes
$config['files_allowed_types']	= 'jpg|jpeg|gif|png|tif|tiff|bmp|psd|zip|txt|html|htm|css|pdf|doc|docx|mp4|mp5|avi|mp3|divx|xls|ppt|mov|wav|flv|wma|txt|m4a|dwg|pub|swf|indd|iso|fla|gz|rtf|vob|3gp|ttf|tgz|log|mid|m4v|ogg|rar|wmv';
/* End of file xyz.php */
/* Location: ./application/controllers/admin/xyz.php */