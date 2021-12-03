<?php

$config_pws_sync__recv_db_base_url = '{{ sync_pub_prefix_f }}/recv_db';
$config_pws_sync__register_db_base_url = '{{ sync_pub_prefix_f }}/register_db';
$config_pws_sync__deploy_db_base_url = '{{ sync_pub_prefix_f }}/deploy_db';
$config_pws_sync__status_db_base_url = '{{ sync_pub_prefix_f }}/status_db';
$config_pws_sync__db_dir = '/opt/sync/db';
$config_pws_sync__backup_dir = '/opt/sync/backup';
$config_pws_sync__db_pwd = '{{ sync_fb_password }}';
$config_pws_sync__log_dir = '/opt/sync/log';
$config_pws_sync__tmp_dir = '/var/tmp/pws_sync';
$config_pws_sync__domain = '{{ sync_int_dom }}';
$config_pws_sync__public_prefix = '{{ sync_pub_prefix }}/';
$config_pws_sync__api_user = 'http://{{ sync_api_dom_f }}/api/user';
#$config_pws_sync__api_user_unrestricted = true;
$config_pws_sync__api_user_unrestricted = false;
$config_pws_sync__api_base = 'http://{{ sync_api_dom_f }}/api/base';
$config_pws_sync__start_ui = '{{ sync_pub_prefix_f }}/sync_ui';
$config_pws_sync__error_ui = '{{ sync_pub_prefix }}/error_ui';
$config_pws_sync__db_host = 'sync.{{ sync_int_dom }}';
$config_pws_sync__mode = 'msg-session';
$config_pws_sync__msg_session_open_url = '{{ sync_pub_prefix }}/open';
$config_pws_sync__db_template = 'std-latest';
