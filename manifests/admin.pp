#
# Define mongodb::admin
#
define mongodb::admin(
  $password       = undef,
  $admin_username = undef,
  $admin_password = undef, 
) {
  
  include 'mongodb::params'
  
  $wait = "mongo admin --eval \"db.users.find()\"; while [ $? -ne 0 ];do sleep 5;mongo admin --eval \"db.users.find()\";done"
  exec { "${name}_wait_connection": 
    command   => $wait,
    path      => "/usr/bin:/usr/sbin:/bin:/sbin",
    logoutput => true,
  }
  

  if $version == '2.4.8' 
  {
    $noauth = "mongo admin --eval \"db.addUser(\\\"${name}\\\", \\\"${password}\\\")\""
    $auth = "if [ $? -eq 252 ]; then mongo -u ${admin_username} -p ${admin_password} admin --eval \"db.addUser(\\\"${name}\\\", \\\"${password}\\\")\";fi"
  }
  else
  {
    $noauth = "mongo admin --eval \"db.createUser({user:\\\"${name}\\\",pwd: \\\"${password}\\\", roles: [ \"readWrite\", \"dbAdmin\" ]})\""
    $auth = "if [ $? -eq 252 ]; then mongo -u ${admin_username} -p ${admin_password} admin --eval \"db.createUser({user:\\\"${name}\\\",pwd: \\\"${password}\\\", roles: [ ]})\";fi"
  }
  
  $command = "${noauth};${auth}"
  exec { "${name}_add_user" :
    command   => $command,
    path      => "/usr/bin:/usr/sbin:/bin:/sbin",
    logoutput => true,
    require   => Exec["${name}_wait_connection"],
  }
}
