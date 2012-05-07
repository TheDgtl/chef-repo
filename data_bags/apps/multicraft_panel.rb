{
  "id": "multicraft_panel",
  "server_roles": [
	"multicraft_panel"
  ],
  "type": {
    "multicraft_panel": [
	  "php",
	  "mod_php_apache2"
	]
  },
  "database_master_role": [
    "multicraft_database_master"
  ],
  "databases": {
    "_default": {
      "reconnect": "true",
	  "encoding": "utf8",
	  "username": "multicraft",
	  "adapter": "mysql",
	  "database": "multicraft"
	}
  },
  "deploy_to": "/var/www/panel",
  "owner": "",
  "group": "",
  "local_settings_file": "protected/config/config.php"
}
